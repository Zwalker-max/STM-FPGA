/**
  ******************************************************************************
  * @file    adc.c
  * @brief   AD9220 ADC 采集驱动实现
  *
  * 设计要点：
  *  - FPGA 侧：10MHz 域 32 位相位累加器做抽取，溢出写 FIFO（见 adc_decimator.v）
  *  - STM32 侧：TIM2 以采样率节拍触发 DMA2_Stream0，每次从 FMC FIFO 读一个半字
  *  - DMA 循环模式 + 半传输/全传输中断实现乒乓（HT 处理 buf[0..N-1]，
  *    TC 处理 buf[N..2N-1]），无需 DBM
  *  - 缓冲区置于 AXI SRAM（DTCM 对 DMA2 不可达），且 D-Cache 开启，
  *    故每次回调先 SCB_InvalidateDCache_by_Addr 再读
  ******************************************************************************
  */

#include "adc.h"
#include <string.h>

/*===============================================================
 * DMA 缓冲区：置于 AXI SRAM（0x24000000 段），32 字节对齐
 *   → 见 MDK-ARM/FMC_DEMO/FMC_DEMO.sct 中 ADC_DMA_BUF 执行区
 *==============================================================*/
__attribute__((section("ADC_DMA_BUF"), aligned(32)))
static uint16_t adc_dma_buf[ADC_DMA_BUF_LEN * 2];

/*===============================================================
 * 句柄（DMA2_Stream0_IRQHandler 需访问 hdma_adc → 非静态）
 *==============================================================*/
DMA_HandleTypeDef hdma_adc;
static TIM_HandleTypeDef  htim_adc;

static volatile uint8_t adc_dma_started = 0;

/*===============================================================
 * 弱回调：默认空操作，main.c 可重写为打印峰值/均值等
 *==============================================================*/
__weak void ADC_ProcessData(uint16_t *buf, uint32_t len)
{
    (void)buf; (void)len;
}

/*===============================================================
 * TIM2 时钟计算（APB1 定时器时钟）
 *   D2PPRE1 字段 [10:8]：编码 1xx 表示 APB 分频且定时器时钟 = 2×APB1
 *==============================================================*/
static uint32_t ADC_GetTIM2Clock(void)
{
    uint32_t pclk1 = HAL_RCC_GetPCLK1Freq();
    uint32_t pre   = RCC->D2CFGR & 0x700U;          /* D2PPRE1[10:8] */
    return (pre >= 0x400U) ? (pclk1 * 2U) : pclk1;  /* 分频时定时器×2 */
}

/*===============================================================
 * Msp 初始化：使能 DMA2/TIM2 时钟、配置 NVIC
 *==============================================================*/
static void ADC_DMA_MspInit(void)
{
    __HAL_RCC_DMA2_CLK_ENABLE();
    __HAL_RCC_TIM2_CLK_ENABLE();

    HAL_NVIC_SetPriority(DMA2_Stream0_IRQn, 6, 0);
    HAL_NVIC_EnableIRQ(DMA2_Stream0_IRQn);
}

/*===============================================================
 * DMA2_Stream0 配置：TIM2_UP 请求，外设(FIFO)→内存，循环，半字
 *==============================================================*/
static void ADC_ConfigDMA(void)
{
    hdma_adc.Instance                 = DMA2_Stream0;
    hdma_adc.Init.Request             = DMA_REQUEST_TIM2_UP;
    hdma_adc.Init.Direction           = DMA_PERIPH_TO_MEMORY;
    hdma_adc.Init.PeriphInc           = DMA_PINC_DISABLE;
    hdma_adc.Init.MemInc              = DMA_MINC_ENABLE;
    hdma_adc.Init.PeriphDataAlignment = DMA_PDATAALIGN_HALFWORD;
    hdma_adc.Init.MemDataAlignment    = DMA_MDATAALIGN_HALFWORD;
    hdma_adc.Init.Mode                = DMA_CIRCULAR;     /* 循环 + HT/TC 乒乓 */
    hdma_adc.Init.Priority            = DMA_PRIORITY_HIGH;
    hdma_adc.Init.FIFOMode            = DMA_FIFOMODE_DISABLE;
    hdma_adc.Init.MemBurst            = DMA_MBURST_SINGLE;
    hdma_adc.Init.PeriphBurst         = DMA_PBURST_SINGLE;
    HAL_DMA_Init(&hdma_adc);

    hdma_adc.XferCpltCallback     = 0;
    hdma_adc.XferHalfCpltCallback = 0;
}

/*===============================================================
 * TIM2 配置：上计数，ARR 由 ADC_SetSampleRate 覆盖，更新事件作 DMA 触发
 *==============================================================*/
static void ADC_ConfigTIM2(void)
{
    htim_adc.Instance               = TIM2;
    htim_adc.Init.Prescaler         = 0;
    htim_adc.Init.CounterMode       = TIM_COUNTERMODE_UP;
    htim_adc.Init.Period            = 1000 - 1;           /* 占位，SetSampleRate 覆盖 */
    htim_adc.Init.ClockDivision     = TIM_CLOCKDIVISION_DIV1;
    htim_adc.Init.AutoReloadPreload = TIM_AUTORELOAD_PRELOAD_ENABLE;
    htim_adc.Init.RepetitionCounter = 0;
    HAL_TIM_Base_Init(&htim_adc);
}

/*===============================================================
 * DMA 中断回调：乒乓半区
 *==============================================================*/
static void ADC_DMA_XferHalfCplt(DMA_HandleTypeDef *hdma)
{
    (void)hdma;
    uint16_t *buf = adc_dma_buf;                        /* 前半 */
    SCB_InvalidateDCache_by_Addr((uint32_t *)buf, ADC_DMA_BUF_LEN * 2);
    ADC_ProcessData(buf, ADC_DMA_BUF_LEN);
}

static void ADC_DMA_XferCplt(DMA_HandleTypeDef *hdma)
{
    (void)hdma;
    uint16_t *buf = &adc_dma_buf[ADC_DMA_BUF_LEN];      /* 后半 */
    SCB_InvalidateDCache_by_Addr((uint32_t *)buf, ADC_DMA_BUF_LEN * 2);
    ADC_ProcessData(buf, ADC_DMA_BUF_LEN);
}

/*===============================================================
 * DMA2_Stream0 中断（覆盖启动文件中的弱定义）
 *==============================================================*/
void DMA2_Stream0_IRQHandler(void)
{
    HAL_DMA_IRQHandler(&hdma_adc);
}

/*===============================================================
 * 公共 API
 *==============================================================*/
void ADC_Init(void)
{
    /* FMC 已由 fmc.c 初始化；此处仅配 TIM2+DMA 与默认寄存器 */
    ADC_DMA_MspInit();
    ADC_ConfigDMA();
    ADC_ConfigTIM2();

    /* 默认禁用 ADC，清零步进影子并触发一次让 ADC 域锁存 0 */
    FPGA[ADC_CTRL_ADDR]     = 0x0000;
    FPGA[ADC_STEP_LO_ADDR]  = 0x0000;
    FPGA[ADC_STEP_HI_ADDR]  = 0x0000;
    __DMB();
    FPGA[ADC_STEP_UPD_ADDR] = 0x0001;

    ADC_SetSampleRate(1000000.0);   /* 默认 1 MSPS */
}

void ADC_Enable(uint8_t en)
{
    FPGA[ADC_CTRL_ADDR] = (en & 1u) ? 0x0001 : 0x0000;
}

void ADC_SetSampleRate(double hz)
{
    if (hz < 0.0)         hz = 0.0;
    if (hz > ADC_SAMPLE_RATE) hz = ADC_SAMPLE_RATE;     /* 上限 10 MSPS */

    /* ---- 1) FPGA 抽取步进（原子：关中断+内存屏障）---- */
    uint32_t step = (uint32_t)(hz * ADC_STEP_SCALE / ADC_SAMPLE_RATE + 0.5);
    __disable_irq();
    FPGA[ADC_STEP_LO_ADDR]  = (uint16_t)(step & 0xFFFFu);
    FPGA[ADC_STEP_HI_ADDR]  = (uint16_t)((step >> 16) & 0xFFFFu);
    __DMB();
    FPGA[ADC_STEP_UPD_ADDR] = 0x0001;                   /* 翻转 → ADC 域锁存 */
    __enable_irq();

    /* ---- 2) TIM2 节拍 = hz（DMA 读取节奏匹配抽取速率）---- */
    uint32_t timclk = ADC_GetTIM2Clock();
    uint32_t arr;
    if (hz < 1.0 || timclk == 0U) {
        arr = 0xFFFFFFFFU;                              /* 极慢 */
    } else {
        double a = (double)timclk / hz;
        if (a > 4294967295.0) a = 4294967295.0;
        arr = (uint32_t)(a + 0.5) - 1U;
    }
    __disable_irq();
    TIM2->ARR = arr;
    TIM2->EGR = TIM_EGR_UG;                             /* 立即重载 */
    __enable_irq();
}

void ADC_Start(void)
{
    if (adc_dma_started) return;

    /* 注册回调（HAL_DMA_Init 之后、启动之前）*/
    hdma_adc.XferCpltCallback     = ADC_DMA_XferCplt;
    hdma_adc.XferHalfCpltCallback = ADC_DMA_XferHalfCplt;

    /* 先开 ADC 让 FIFO 有数据，再装 DMA，再启动 TIM2 节拍 */
    ADC_Enable(1);

    HAL_DMA_Start_IT(&hdma_adc,
                     (uint32_t)&FPGA[ADC_FIFO_DATA_ADDR],
                     (uint32_t)adc_dma_buf,
                     ADC_DMA_BUF_LEN * 2);

    HAL_TIM_Base_Start(&htim_adc);
    /* 允许 TIM2 更新事件产生 DMA 请求（HAL_TIM_Base_Start 不置 UDE）*/
    __HAL_TIM_ENABLE_DMA(&htim_adc, TIM_DMA_UPDATE);
    adc_dma_started = 1;
}

void ADC_Stop(void)
{
    if (!adc_dma_started) return;
    __HAL_TIM_DISABLE_DMA(&htim_adc, TIM_DMA_UPDATE);
    HAL_TIM_Base_Stop(&htim_adc);
    HAL_DMA_Abort(&hdma_adc);
    ADC_Enable(0);
    adc_dma_started = 0;
}

uint16_t ADC_GetFIFOData(void)
{
    return FPGA[ADC_FIFO_DATA_ADDR];
}

uint16_t ADC_GetFIFOStatus(void)
{
    return FPGA[ADC_FIFO_STAT_ADDR];
}

uint8_t ADC_FIFOIsEmpty(uint16_t status)
{
    return (status & ADC_STAT_EMPTY) ? 1 : 0;
}

uint8_t ADC_FIFOIsFull(uint16_t status)
{
    return (status & ADC_STAT_FULL) ? 1 : 0;
}

uint16_t ADC_FIFOUsedWords(uint16_t status)
{
    return (uint16_t)((status & ADC_STAT_USEDM_MSK) >> ADC_STAT_USEDM_POS);
}
