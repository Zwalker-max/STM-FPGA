/**
  ******************************************************************************
  * @file    adc.c
  * @brief   ADC driver implementation for AD9220 acquisition subsystem
  *          FMC-mapped FPGA registers + TIM12-paced DMA ping-pong.
  *
  *          TIM12 (PSC=0, ARR=274) → TRGO → DMAMUX ReqGen0 → DMA2_Stream0
  *
  *          STM32H723: TIM12 is on APB1 (D2 domain).
  *          APB1 clock = HCLK/16 = 137.5 MHz / 16 = 8.59375 MHz
  *          Timer clock (APB prescaler ≠ 1): 2x APB1 = 17.1875 MHz
  *          f_TRGO = 17.1875 MHz / (274+1) ≈ 62.5 kHz
  *          Actual DMA rate ≈ 62.5 kSPS per stream.
  *
  *          如需 1 MSPS DMA，需通过 CubeMX 将 TIM12 挂到更快的 APB
  *          (APB2 或调整 APB1 分频)，或使用 D1 域定时器 (TIM2)。
  *
  *          Ping-pong: half-complete → buf[0], full-complete → buf[1].
  *          Buffer in AXI SRAM (ADC_DMA_BUF section), 32-byte aligned.
  ******************************************************************************
  */

#include "adc.h"
#include "dds.h"        /* for FPGA macro and __disable_irq / __DMB pattern */
#include "dma.h"        /* for hdma_dma_generator0 */
#include "tim.h"        /* for htim12 */
#include <math.h>
#include <string.h>

//===============================================================
// DMA ping-pong buffer (AXI SRAM, 32-byte aligned for cache)
//===============================================================
uint16_t adc_dma_buf[2][ADC_DMA_BUF_SIZE]
    __attribute__((section("ADC_DMA_BUF"), aligned(32)));

// Track which half was just completed
static volatile uint8_t  adc_dma_running = 0;
static volatile uint16_t adc_dma_overruns = 0;

//===============================================================
// 1. Initialization
//===============================================================
void ADC_Init(void)
{
    /* Ensure ADC is stopped at power-up */
    ADC_Stop();
    adc_dma_running = 0;
    adc_dma_overruns = 0;
    memset(adc_dma_buf, 0, sizeof(adc_dma_buf));
}

//===============================================================
// 2. Enable / Disable
//===============================================================
void ADC_Enable(bool enable)
{
    FPGA[ADC_CTRL_ADDR] = enable ? 0x0001 : 0x0000;
}

void ADC_Start(void)
{
    ADC_Enable(true);
}

void ADC_Stop(void)
{
    ADC_Enable(false);
}

bool ADC_IsEnabled(void)
{
    return (FPGA[ADC_CTRL_ADDR] & 0x0001) ? true : false;
}

//===============================================================
// 3. Sample-Rate Step Computation
//    step = sample_rate_hz * 2^32 / 10_000_000
//===============================================================
uint32_t ADC_CalcStep(float sample_rate_hz)
{
    if (sample_rate_hz <= 0.0f)  sample_rate_hz = 1.0f;
    if (sample_rate_hz > ADC_SAMPLE_CLK_HZ) sample_rate_hz = (float)ADC_SAMPLE_CLK_HZ;

    double step = (double)sample_rate_hz * ADC_STEP_SCALE / ADC_SAMPLE_CLK_HZ;
    return (uint32_t)(step + 0.5);
}

//===============================================================
// 4. Atomic Sample-Rate Update
//===============================================================
void ADC_SetSampleRate(float sample_rate_hz)
{
    uint32_t step = ADC_CalcStep(sample_rate_hz);

    __disable_irq();
    FPGA[ADC_STEP_LO_ADDR]     = (uint16_t)(step & 0xFFFF);
    FPGA[ADC_STEP_HI_ADDR]     = (uint16_t)((step >> 16) & 0xFFFF);
    __DMB();
    FPGA[ADC_STEP_UPDATE_ADDR] = 0x0001;
    __enable_irq();
}

//===============================================================
// 5. Sample Rate Readback
//===============================================================
float ADC_ReadSampleRate(void)
{
    uint16_t step_lo = FPGA[ADC_STEP_LO_ADDR];
    uint16_t step_hi = FPGA[ADC_STEP_HI_ADDR];
    uint32_t step    = ((uint32_t)step_hi << 16) | step_lo;

    return (float)((double)step * ADC_SAMPLE_CLK_HZ / ADC_STEP_SCALE);
}

//===============================================================
// 6. FIFO Data Read (non-DMA, single word pop)
//===============================================================
uint16_t ADC_GetFIFOData(void)
{
    return FPGA[ADC_FIFO_DATA_ADDR];
}

//===============================================================
// 7. FIFO Status
//===============================================================
uint16_t ADC_GetFIFOStatus(void)
{
    return FPGA[ADC_FIFO_STATUS_ADDR];
}

bool ADC_IsFIFOEmpty(void)
{
    return (FPGA[ADC_FIFO_STATUS_ADDR] & 0x0001) ? true : false;
}

bool ADC_IsFIFOFull(void)
{
    return (FPGA[ADC_FIFO_STATUS_ADDR] & 0x0002) ? true : false;
}

uint16_t ADC_GetFIFOCount(void)
{
    return (FPGA[ADC_FIFO_STATUS_ADDR] >> 2) & 0x03FF;
}

//===============================================================
// 8. DMA Start / Stop (TIM12-paced ping-pong)
//
//    Peripheral address = fixed FMC register at 0x60000000 + 0x1004*2
//                       = 0x60002008 (byte address for 16-bit FMC)
//    Memory: adc_dma_buf (auto-wraps in circular mode)
//    Length: 2 * ADC_DMA_BUF_SIZE (both halves together)
//
//    Interrupts: HT (half-transfer) + TC (transfer complete)
//    HT → buf[0] full → process it
//    TC → buf[1] full → process it
//===============================================================
void ADC_DMA_Start(void)
{
    HAL_StatusTypeDef status;

    /* Invalidate cache for DMA buffer before DMA starts writing to it */
    SCB_InvalidateDCache_by_Addr(
        (uint32_t *)adc_dma_buf,
        2 * ADC_DMA_BUF_SIZE * sizeof(uint16_t));

    /*
     * FMC address for ADC_FIFO_DATA:
     *   Base = 0x60000000, offset = 0x1004 16-bit words
     *   Byte address = 0x60000000 + 0x1004 * 2 = 0x60002008
     */
    uint32_t periph_addr = FPGA_BASE_ADDR + (uint32_t)(ADC_FIFO_DATA_ADDR * 2);

    /* Enable HT + TC interrupts on DMA stream */
    __HAL_DMA_ENABLE_IT(&hdma_dma_generator0, DMA_IT_HT);
    __HAL_DMA_ENABLE_IT(&hdma_dma_generator0, DMA_IT_TC);

    /* Enable DMA2_Stream0 IRQ in NVIC */
    HAL_NVIC_SetPriority(DMA2_Stream0_IRQn, 1, 0);
    HAL_NVIC_EnableIRQ(DMA2_Stream0_IRQn);

    /*
     * Start DMA in circular mode: peripheral-to-memory, halfword.
     * Total buffer = 2 * ADC_DMA_BUF_SIZE halfwords (ping-pong both halves).
     */
    status = HAL_DMA_Start(&hdma_dma_generator0,
                           periph_addr,
                           (uint32_t)adc_dma_buf,
                           2 * ADC_DMA_BUF_SIZE);
    if (status != HAL_OK) {
        Error_Handler();
    }

    adc_dma_running = 1;

    /* Start TIM12 — begins triggering DMA via DMAMUX ReqGen */
    HAL_TIM_Base_Start(&htim12);
}

void ADC_DMA_Stop(void)
{
    /* Stop timer first — no more DMA triggers */
    HAL_TIM_Base_Stop(&htim12);

    /* Disable DMA interrupts */
    __HAL_DMA_DISABLE_IT(&hdma_dma_generator0, DMA_IT_HT);
    __HAL_DMA_DISABLE_IT(&hdma_dma_generator0, DMA_IT_TC);

    /* Abort DMA stream */
    HAL_DMA_Abort(&hdma_dma_generator0);

    adc_dma_running = 0;
}

bool ADC_DMA_IsRunning(void)
{
    return (adc_dma_running != 0);
}

uint16_t ADC_DMA_GetOverruns(void)
{
    return adc_dma_overruns;
}

//===============================================================
// 9. DMA2_Stream0 IRQ Handler
//    Must be called from DMA2_Stream0_IRQHandler() in stm32h7xx_it.c
//===============================================================
void ADC_DMA_IRQHandler(void)
{
    uint32_t flags = DMA2->LISR;   /* Stream 0 is in the low ISR */
    uint32_t src   = flags & (DMA_LISR_HTIF0 | DMA_LISR_TCIF0);

    if (src == 0) return;

    /* Half-transfer: buf[0] full */
    if (src & DMA_LISR_HTIF0) {
        DMA2->LIFCR = DMA_LIFCR_CHTIF0;   /* clear HT flag */
        /* Cache coherence: invalidate buf[0] before CPU reads */
        SCB_InvalidateDCache_by_Addr(
            (uint32_t *)adc_dma_buf[0],
            ADC_DMA_BUF_SIZE * sizeof(uint16_t));
        ADC_ProcessData(adc_dma_buf[0], ADC_DMA_BUF_SIZE);
    }

    /* Transfer-complete: buf[1] full */
    if (src & DMA_LISR_TCIF0) {
        DMA2->LIFCR = DMA_LIFCR_CTCIF0;   /* clear TC flag */
        SCB_InvalidateDCache_by_Addr(
            (uint32_t *)adc_dma_buf[1],
            ADC_DMA_BUF_SIZE * sizeof(uint16_t));
        ADC_ProcessData(adc_dma_buf[1], ADC_DMA_BUF_SIZE);
    }

    /* Overflow check: TEIF0 wraps past the 512-hw buffer */
    if (flags & DMA_LISR_TEIF0) {
        DMA2->LIFCR = DMA_LIFCR_CTEIF0;   /* clear TE flag */
        adc_dma_overruns++;
    }
}

//===============================================================
// 10. User Data Processing Callback (weak — override in main.c)
//===============================================================
__weak void ADC_ProcessData(const uint16_t *buf, uint16_t len)
{
    /* Default: do nothing. Override in application code. */
    (void)buf;
    (void)len;
}
