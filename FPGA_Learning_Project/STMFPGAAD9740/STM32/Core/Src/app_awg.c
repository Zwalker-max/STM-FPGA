/**
 ******************************************************************************
 * @file    app_awg.c
 * @brief   AWG application layer: command processing, waveform loading,
 *          DDS control, FPGA diagnostics, board early init
 *
 * Hardware: STM32H723ZGT6 + EP4CE10E22I7N + AD9740 (10-bit DAC)
 * Communication: FMC async bus (16-bit, Bank1 @ 0x60000000)
 *
 * Features:
 *   - Waveform tables: sine, triangle, square, sawtooth, noise, DC
 *   - DDS frequency control (0.029 Hz resolution @ 125 MHz)
 *   - Amplitude control (0-1023, 10-bit)
 *   - UART command interface (USART1, 115200 baud)
 ******************************************************************************
 */

#include "main.h"
#include "usart.h"
#include "fpga_reg_map.h"
#include "waveform_gen.h"
#include "app_awg.h"
#include <string.h>
#include <stdlib.h>

/* ============================================================
 * Private defines
 * ============================================================ */
#define WAVEFORM_POINTS         2048UL
#define WAVEFORM_BUF_SIZE       WAVEFORM_POINTS
#define FPGA_RAM_START          0x0000
#define CMD_MAX_ARGS            4

#define DEFAULT_FREQ_HZ         1000UL
#define DEFAULT_AMPLITUDE       200
#define DEFAULT_WAVEFORM        WAVE_SINE

/* ============================================================
 * Private variables
 * ============================================================ */

/* Waveform buffer: allocated in DTCM for fastest access */
static uint16_t wave_buf[WAVEFORM_BUF_SIZE] __attribute__((section(".dtcmram")));

/* Current settings */
static uint32_t  g_freq_hz     = DEFAULT_FREQ_HZ;
static uint16_t  g_amplitude   = DEFAULT_AMPLITUDE;
static uint8_t   g_waveform    = DEFAULT_WAVEFORM;
static uint8_t   g_dac_running = 0;

/* Sweep state */
static volatile uint8_t g_sweep_active = 0;

/* ============================================================
 * Private function prototypes
 * ============================================================ */
static void LoadCurrentWaveform(void);
static void Cmd_SetFrequency(uint32_t freq_hz);
static void Cmd_SetAmplitude(uint16_t amp);
static void Cmd_SetWaveform(uint8_t wave);
static void Cmd_Start(void);
static void Cmd_Stop(void);
static void Cmd_Status(void);
static void Cmd_Sweep(uint32_t f1, uint32_t f2, uint32_t step, uint32_t delay_ms);
static void Cmd_Diag(void);

/* ============================================================
 * Board Early Initialization (MPU + Cache)
 *   必须在 HAL_Init() 之前调用
 *   将 MPU 配置从 main.c 移出，避免 CubeMX 覆盖
 * ============================================================ */
void Board_InitEarly(void)
{
    MPU_Region_InitTypeDef MPU_InitStruct = {0};

    /* Disables the MPU */
    HAL_MPU_Disable();

    /** FMC region: device memory, non-cacheable
     */
    MPU_InitStruct.Enable = MPU_REGION_ENABLE;
    MPU_InitStruct.Number = MPU_REGION_NUMBER0;
    MPU_InitStruct.BaseAddress = 0x60000000;
    MPU_InitStruct.Size = MPU_REGION_SIZE_256MB;
    MPU_InitStruct.SubRegionDisable = 0x87;
    MPU_InitStruct.TypeExtField = MPU_TEX_LEVEL0;
    MPU_InitStruct.AccessPermission = MPU_REGION_FULL_ACCESS;
    MPU_InitStruct.DisableExec = MPU_INSTRUCTION_ACCESS_DISABLE;
    MPU_InitStruct.IsShareable = MPU_ACCESS_SHAREABLE;
    MPU_InitStruct.IsCacheable = MPU_ACCESS_NOT_CACHEABLE;
    MPU_InitStruct.IsBufferable = MPU_ACCESS_NOT_BUFFERABLE;

    HAL_MPU_ConfigRegion(&MPU_InitStruct);
    /* Enables the MPU */
    HAL_MPU_Enable(MPU_HFNMI_PRIVDEF);

    /* Enable I-Cache and D-Cache */
    SCB_EnableICache();
    SCB_EnableDCache();
}

/* ============================================================
 * Load current waveform into FPGA RAM
 * ============================================================ */
static void LoadCurrentWaveform(void)
{
    uint32_t offset;
    uint16_t gen_amplitude;

    switch (g_waveform) {
        case WAVE_SINE:     offset = DAC_MID_VALUE; gen_amplitude = 511; break;
        case WAVE_TRIANGLE: offset = DAC_MID_VALUE; gen_amplitude = 511; break;
        case WAVE_SQUARE:   offset = DAC_MID_VALUE; gen_amplitude = 511; break;
        case WAVE_SAWTOOTH: offset = DAC_MID_VALUE; gen_amplitude = 511; break;
        case WAVE_NOISE:    offset = DAC_MID_VALUE; gen_amplitude = 511; break;
        case WAVE_DC:       offset = 0;              gen_amplitude = 1023;break;
        default:            offset = DAC_MID_VALUE; gen_amplitude = 511; break;
    }

    switch (g_waveform) {
        case WAVE_SINE:
            Gen_SineWave(wave_buf, WAVEFORM_POINTS, gen_amplitude, offset);
            break;
        case WAVE_TRIANGLE:
            Gen_TriangleWave(wave_buf, WAVEFORM_POINTS, gen_amplitude, offset);
            break;
        case WAVE_SQUARE:
            Gen_SquareWave(wave_buf, WAVEFORM_POINTS, gen_amplitude, offset, 50);
            break;
        case WAVE_SAWTOOTH:
            Gen_SawtoothWave(wave_buf, WAVEFORM_POINTS, gen_amplitude, offset);
            break;
        case WAVE_NOISE:
            Gen_NoiseWave(wave_buf, WAVEFORM_POINTS, gen_amplitude, offset, 12345);
            break;
        case WAVE_DC:
            Gen_DCLevel(wave_buf, WAVEFORM_POINTS, gen_amplitude);
            break;
        default:
            return;
    }

    /* Write to FPGA RAM via FMC */
    FPGA_LoadWaveform(FPGA_RAM_START, wave_buf, WAVEFORM_POINTS);

    /* Set DDS mode with full table */
    uint16_t mode = MODE_DDS_EN_Msk;
    FPGA_WriteReg(REG_MODE, mode);
}

/* ============================================================
 * FPGA Register Diagnostic
 *   对每个可写寄存器写入测试模式并读回验证
 * ============================================================ */
static void Cmd_Diag(void)
{
    static const struct {
        uint16_t addr;
        uint16_t mask;
        const char *name;
    } regs[] = {
        { REG_MODE,           0x0097, "MODE" },
        { REG_FREQ_H,         0xFFFF, "FREQ_H" },
        { REG_FREQ_L,         0xFFFF, "FREQ_L" },
        { REG_AMP,            0x03FF, "AMP" },
        { REG_PHASE_H,        0xFFFF, "PHASE_H" },
        { REG_PHASE_L,        0xFFFF, "PHASE_L" },
        { REG_WAVEFORM_BASE,  0x07FF, "WAVEFORM_BASE" },
    };

    static const uint16_t patterns[] = {
        0x0000, 0x00FF, 0x0100, 0x0200, 0x0300, 0x03FF, 0xFFFF
    };
    static const char *pat_names[] = {
        "0x0000", "0x00FF", "0x0100", "0x0200", "0x0300", "0x03FF", "0xFFFF"
    };

    const int num_regs = sizeof(regs) / sizeof(regs[0]);
    const int num_pats = sizeof(patterns) / sizeof(patterns[0]);
    int total_errors = 0;

    uint16_t saved_mode = FPGA_ReadReg(REG_MODE);
    FPGA_WriteReg(REG_MODE, saved_mode & ~MODE_START_Msk);

    UART_Console_Printf("\r\n=== FPGA Register Diagnostic ===\r\n");

    for (int r = 0; r < num_regs; r++) {
        int reg_errors = 0;
        for (int p = 0; p < num_pats; p++) {
            uint16_t wr_val = patterns[p] & regs[r].mask;
            FPGA_WriteReg(regs[r].addr, wr_val);
            for (volatile int d = 0; d < 10; d++) { __NOP(); }
            uint16_t rd_val = FPGA_ReadReg(regs[r].addr) & regs[r].mask;

            if (rd_val != wr_val) {
                reg_errors++;
                total_errors++;
                UART_Console_Printf("  FAIL: %-13s  wrote %s -> read 0x%04X [bits:",
                           regs[r].name, pat_names[p], rd_val);
                uint16_t diff = wr_val ^ rd_val;
                for (int b = 15; b >= 0; b--) {
                    if (diff & (1 << b)) {
                        UART_Console_Printf(" D[%d]", b);
                    }
                }
                UART_Console_Printf("]\r\n");
            }
        }
        if (reg_errors == 0) {
            UART_Console_Printf("  PASS: %-13s  all %d patterns OK\r\n",
                       regs[r].name, num_pats);
        } else {
            UART_Console_Printf("  ----: %-13s  %d/%d patterns FAILED\r\n",
                       regs[r].name, reg_errors, num_pats);
        }
    }

    FPGA_WriteReg(REG_MODE, saved_mode);

    UART_Console_Printf("=== ");
    if (total_errors == 0) {
        UART_Console_Printf("ALL PASS");
    } else {
        UART_Console_Printf("TOTAL FAILURES: %d", total_errors);
    }
    UART_Console_Printf(" ===\r\n");
}

/* ============================================================
 * Command: Set Frequency
 * ============================================================ */
static void Cmd_SetFrequency(uint32_t freq_hz)
{
    if (freq_hz == 0 || freq_hz > 62500000UL) {
        UART_Console_Printf("ERR: Frequency out of range (1 - 62500000 Hz)\r\n");
        return;
    }
    g_freq_hz = freq_hz;
    FPGA_SetFrequency(freq_hz);
    UART_Console_Printf("OK: Frequency = %lu Hz (FREQ_WORD = 0x%08lX)\r\n",
                freq_hz, DDS_FREQ_TO_WORD(freq_hz));
}

/* ============================================================
 * Command: Set Amplitude
 * ============================================================ */
static void Cmd_SetAmplitude(uint16_t amp)
{
    if (amp > AMP_MAX) amp = AMP_MAX;
    g_amplitude = amp;
    FPGA_SetAmplitude(amp);
    UART_Console_Printf("OK: Amplitude = %u / %u\r\n", amp, AMP_MAX);
}

/* ============================================================
 * Command: Set Waveform
 * ============================================================ */
static void Cmd_SetWaveform(uint8_t wave)
{
    if (wave > WAVE_DC) {
        UART_Console_Printf("ERR: Waveform type 0-5 (0=sine 1=tri 2=sqr 3=saw 4=noise 5=DC)\r\n");
        return;
    }
    g_waveform = wave;
    LoadCurrentWaveform();
    FPGA_WriteReg(REG_WAVEFORM_BASE, 0);
    const char *names[] = {"Sine", "Triangle", "Square", "Sawtooth", "Noise", "DC"};
    UART_Console_Printf("OK: Waveform = %s\r\n", names[wave]);
}

/* ============================================================
 * Command: Start DAC
 * ============================================================ */
static void Cmd_Start(void)
{
    if (g_dac_running) {
        UART_Console_Printf("WARN: DAC already running\r\n");
        return;
    }
    FPGA_DAC_Start();
    g_dac_running = 1;
    UART_Console_Printf("OK: DAC started\r\n");
}

/* ============================================================
 * Command: Stop DAC
 * ============================================================ */
static void Cmd_Stop(void)
{
    if (!g_dac_running) {
        UART_Console_Printf("WARN: DAC already stopped\r\n");
        return;
    }
    FPGA_DAC_Stop();
    g_dac_running = 0;
    UART_Console_Printf("OK: DAC stopped\r\n");
}

/* ============================================================
 * Command: Print Status
 * ============================================================ */
static void Cmd_Status(void)
{
    const char *wave_names[] = {"Sine", "Triangle", "Square", "Sawtooth", "Noise", "DC"};
    uint16_t mode_reg   = FPGA_ReadReg(REG_MODE);
    uint16_t freq_h     = FPGA_ReadReg(REG_FREQ_H);
    uint16_t freq_l     = FPGA_ReadReg(REG_FREQ_L);
    uint16_t amp_reg    = FPGA_ReadReg(REG_AMP);
    uint16_t status_reg = FPGA_ReadReg(REG_STATUS);
    uint16_t cur_sample = FPGA_ReadReg(REG_CURRENT_SAMPLE);

    uint32_t freq_word = ((uint32_t)freq_h << 16) | freq_l;
    uint32_t actual_freq = DDS_WORD_TO_FREQ(freq_word);

    UART_Console_Printf("\r\n=== AWG Status ===\r\n");
    UART_Console_Printf("Waveform:    %s\r\n", wave_names[g_waveform]);
    UART_Console_Printf("Frequency:   %lu Hz (word: 0x%08lX)\r\n", actual_freq, freq_word);
    UART_Console_Printf("Amplitude:   %u / %u\r\n", amp_reg & 0x3FF, AMP_MAX);
    UART_Console_Printf("DAC Running: %s\r\n", (status_reg & 2) ? "YES" : "NO");
    UART_Console_Printf("DDS Mode:    %s\r\n", (mode_reg & 2) ? "ON" : "OFF");
    UART_Console_Printf("Cur Sample:  0x%03X (%u)\r\n", cur_sample, cur_sample);
    UART_Console_Printf("===================\r\n");
}

/* ============================================================
 * Command: Frequency Sweep
 * ============================================================ */
static void Cmd_Sweep(uint32_t f1, uint32_t f2, uint32_t step, uint32_t delay_ms)
{
    if (f1 == 0 || f2 == 0 || step == 0) return;
    if (f1 > f2) { uint32_t tmp = f1; f1 = f2; f2 = tmp; }

    g_sweep_active = 1;
    UART_Console_Printf("Sweeping %lu → %lu Hz, step %lu Hz, delay %lu ms\r\n",
                f1, f2, step, delay_ms);

    for (uint32_t f = f1; f <= f2 && g_sweep_active; f += step) {
        Cmd_SetFrequency(f);
        HAL_Delay(delay_ms);
    }
    g_sweep_active = 0;
    UART_Console_Printf("Sweep complete\r\n");
}

/* ============================================================
 * Command Parser (called from APP_AWG_Task)
 * ============================================================ */
static void UART_ProcessCommand(char *cmd)
{
    char *nl = strpbrk(cmd, "\r\n");
    if (nl) *nl = '\0';
    if (strlen(cmd) == 0) return;

    char *tok = strtok(cmd, " ");
    if (!tok) return;

    for (char *p = tok; *p; p++) {
        if (*p >= 'a' && *p <= 'z') *p -= 32;
    }

    if (strcmp(tok, "FREQ") == 0) {
        char *arg = strtok(NULL, " ");
        if (arg) Cmd_SetFrequency(atol(arg));
        else UART_Console_Printf("Usage: FREQ <Hz>\r\n");

    } else if (strcmp(tok, "AMP") == 0) {
        char *arg = strtok(NULL, " ");
        if (arg) Cmd_SetAmplitude((uint16_t)atoi(arg));
        else UART_Console_Printf("Usage: AMP <0-1023>\r\n");

    } else if (strcmp(tok, "WAVE") == 0) {
        char *arg = strtok(NULL, " ");
        if (arg) Cmd_SetWaveform((uint8_t)atoi(arg));
        else UART_Console_Printf("Usage: WAVE <0-5>\r\n");

    } else if (strcmp(tok, "START") == 0) {
        Cmd_Start();

    } else if (strcmp(tok, "STOP") == 0) {
        Cmd_Stop();

    } else if (strcmp(tok, "STATUS") == 0) {
        Cmd_Status();

    } else if (strcmp(tok, "SWEEP") == 0) {
        char *a1 = strtok(NULL, " ");
        char *a2 = strtok(NULL, " ");
        char *a3 = strtok(NULL, " ");
        char *a4 = strtok(NULL, " ");
        if (a1 && a2 && a3 && a4) {
            Cmd_Sweep(atol(a1), atol(a2), atol(a3), atol(a4));
        } else {
            UART_Console_Printf("Usage: SWEEP <f1_Hz> <f2_Hz> <step_Hz> <delay_ms>\r\n");
        }

    } else if (strcmp(tok, "DIAG") == 0) {
        Cmd_Diag();

    } else if (strcmp(tok, "HELP") == 0) {
        UART_Console_Printf("\r\n=== Commands ===\r\n");
        UART_Console_Printf("FREQ <Hz>        Set frequency (1-62500000)\r\n");
        UART_Console_Printf("AMP <0-1023>     Set amplitude\r\n");
        UART_Console_Printf("WAVE <0-5>       Select waveform (0=sine 1=tri 2=sqr 3=saw 4=noise 5=DC)\r\n");
        UART_Console_Printf("START            Start DAC\r\n");
        UART_Console_Printf("STOP             Stop DAC\r\n");
        UART_Console_Printf("STATUS           Print settings\r\n");
        UART_Console_Printf("SWEEP f1 f2 s ms Frequency sweep\r\n");
        UART_Console_Printf("DIAG             Run FPGA register diagnostic\r\n");
        UART_Console_Printf("================\r\n");

    } else {
        UART_Console_Printf("ERR: Unknown command '%s'. Type HELP.\r\n", tok);
    }
}

/* ============================================================
 * AWG Application Initialization
 * ============================================================ */
void APP_AWG_Init(void)
{
    UART_Console_Printf("\r\n=======================================\r\n");
    UART_Console_Printf("  STM32H7 + FPGA + AD9740 AWG v1.0\r\n");
    UART_Console_Printf("  FMC @ 0x60000000, DAC @ 125 MSPS\r\n");
    UART_Console_Printf("=======================================\r\n");
    UART_Console_Printf("Type HELP for command list\r\n\r\n");

    /* Load default waveform */
    UART_Console_Printf("Loading default waveform (1 kHz sine)...\r\n");
    LoadCurrentWaveform();
    FPGA_SetFrequency(DEFAULT_FREQ_HZ);
    FPGA_SetAmplitude(DEFAULT_AMPLITUDE);
    // FPGA_DAC_Start();  // 默认不启动
    UART_Console_Printf("Ready.\r\n");

    /* Start UART RX interrupt */
    UART_Console_Init();
}

/* ============================================================
 * AWG Main Loop Task
 * ============================================================ */
void APP_AWG_Task(void)
{
    if (UART_Console_IsCmdReady()) {
        UART_ProcessCommand(UART_Console_GetCmd());
        UART_Console_AckCmd();
    }
}
