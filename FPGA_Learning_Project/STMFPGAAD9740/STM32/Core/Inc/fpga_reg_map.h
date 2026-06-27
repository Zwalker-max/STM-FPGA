/**
 ******************************************************************************
 * @file    fpga_reg_map.h
 * @brief   FPGA register map definitions for STM32H723 + AD9740 AWG
 * @note    Shared between STM32 firmware and FPGA documentation
 *
 * FMC Address Space: 0x60000000 (Bank1, NE1)
 *   - 16-bit data, 15-bit address (32K word range)
 *   - Word-addressed: FPGA[reg] maps to FMC_A[14:0] = reg
 *
 * Address Partition:
 *   0x0000 – 0x07FF  →  Waveform RAM (2048 x 16-bit, A14:11=0)
 *   0x0800 – 0x3FFF  →  Unmapped (A14=0, A13:11≠0, reads return 0)
 *   0x4000 – 0x400F  →  Control registers (A14=1)
 *   0x4010 – 0x401F  →  Status registers  (A14=1)
 *
 *   NOTE: Addresses use 0x4xxx not 0x8xxx because FMC_A[15]
 *         is NOT connected to the FPGA (only A[14:0] available).
 *         FMC_A[14]=1 selects the control/status register region.
 ******************************************************************************
 */

#ifndef __FPGA_REG_MAP_H
#define __FPGA_REG_MAP_H

#ifdef __cplusplus
extern "C" {
#endif

/* ============================================================
 * Base Addresses
 *   Note: FPGA_BASE_ADDR and FPGA are defined in main.h
 *         (CubeMX auto-generated, in USER CODE EM section)
 * ============================================================ */
#ifndef FPGA_BASE_ADDR
#define FPGA_BASE_ADDR          0x60000000UL
#define FPGA                    ((volatile uint16_t *)FPGA_BASE_ADDR)
#endif

/* ============================================================
 * Waveform RAM (2048 x 16-bit)
 *   0x0000 – 0x07FF (2048 words)
 *   STM32 writes waveform samples here via FMC
 *   DAC reads from Port B via DDS phase accumulator
 *   Note: addresses 0x0800-0x7FFF are unmapped (read returns 0)
 * ============================================================ */
#define REG_WAVEFORM_START      0x0000
#define REG_WAVEFORM_END        0x07FF
#define REG_WAVEFORM_SIZE       0x0800   /* 2048 words */

/* ============================================================
 * Control Registers (0x4000 – 0x400F, 16 registers)
 *   Note: 0x4000 is used instead of 0x8000 because FMC_A[15]
 *         is NOT connected to the FPGA; only FMC_A[14:0] are
 *         available. With FMC_A[14]=1, the address range is
 *         0x4000–0x7FFF (within the 15-bit FPGA address space).
 * ============================================================ */
#define REG_CONTROL_BASE        0x4000

/* MODE Register (0x4000)
 *   [0]     : start       (1 = DAC running, 0 = idle output mid-scale)
 *   [1]     : dds_en      (1 = DDS mode, 0 = direct address counter)
 *   [2]     : burst_en    (1 = burst mode, single-shot N cycles)
 *   [7:4]   : wave_sel    (waveform type select for future mux)
 */
#define REG_MODE                (REG_CONTROL_BASE + 0)
#define MODE_START_Pos          0
#define MODE_DDS_EN_Pos         1
#define MODE_BURST_EN_Pos       2
#define MODE_WAVE_SEL_Pos       4
#define MODE_START_Msk          (1 << MODE_START_Pos)
#define MODE_DDS_EN_Msk         (1 << MODE_DDS_EN_Pos)
#define MODE_BURST_EN_Msk       (1 << MODE_BURST_EN_Pos)

/* FREQ_H Register (0x4001) – Frequency word [31:16] */
#define REG_FREQ_H              (REG_CONTROL_BASE + 1)

/* FREQ_L Register (0x4002) – Frequency word [15:0] */
#define REG_FREQ_L              (REG_CONTROL_BASE + 2)

/* AMP Register (0x4003) – Amplitude scale [9:0], 0=min, 1023=max */
#define REG_AMP                 (REG_CONTROL_BASE + 3)
#define AMP_MAX                 1023

/* PHASE_H Register (0x4004) – Phase offset [31:16] */
#define REG_PHASE_H             (REG_CONTROL_BASE + 4)

/* PHASE_L Register (0x4005) – Phase offset [15:0] */
#define REG_PHASE_L             (REG_CONTROL_BASE + 5)

/* WAVEFORM_BASE Register (0x4006) – Ping-pong buffer base address [10:0] */
/*   Note: 11-bit due to 2048-word RAM depth */
#define REG_WAVEFORM_BASE       (REG_CONTROL_BASE + 6)

/* Reserved: 0x4007 – 0x400F */

/* ============================================================
 * Status Registers (0x4010 – 0x401F, 16 registers, read-only)
 * ============================================================ */
#define REG_STATUS_BASE         0x4010

/* STATUS Register (0x4010)
 *   [0]     : ram_busy     (1 = RAM write collision)
 *   [1]     : dac_running  (1 = DAC active)
 */
#define REG_STATUS              (REG_STATUS_BASE + 0)
#define STATUS_RAM_BUSY_Pos     0
#define STATUS_DAC_RUNNING_Pos  1

/* CURRENT_SAMPLE Register (0x4011) – Current DAC output sample [9:0] */
#define REG_CURRENT_SAMPLE      (REG_STATUS_BASE + 1)

/* ============================================================
 * Frequency Calculation Macros
 *
 * DDS formula: Fout = FREQ_WORD * Fsample / 2^N
 *   Fsample = 125 MHz (相位累加器每周期推进, 无分频)
 *   N = 32 bits (phase accumulator width)
 *   Resolution = 125e6 / 2^32 ≈ 0.0291 Hz
 *
 * FREQ_WORD = Fout * 2^32 / 125000000
 * ============================================================ */
#define DDS_FSAMPLE             125000000ULL
#define DDS_ACCUM_BITS          32
#define DDS_FREQ_RESOLUTION     0.029103830456733703613

/* Compute DDS frequency word from desired frequency in Hz */
#define DDS_FREQ_TO_WORD(f_hz)  ((uint32_t)(((uint64_t)(f_hz) << DDS_ACCUM_BITS) / DDS_FSAMPLE))

/* Compute output frequency from DDS frequency word */
#define DDS_WORD_TO_FREQ(word)  ((uint32_t)(((uint64_t)(word) * DDS_FSAMPLE) >> DDS_ACCUM_BITS))

/* ============================================================
 * DAC data range
 *   AD9740: 10-bit, straight binary
 * ============================================================ */
#define DAC_MAX_VALUE   1023
#define DAC_MID_VALUE   512
#define DAC_MIN_VALUE   0

/* ============================================================
 * Waveform Types
 * ============================================================ */
#define WAVE_SINE               0
#define WAVE_TRIANGLE           1
#define WAVE_SQUARE             2
#define WAVE_SAWTOOTH           3
#define WAVE_NOISE              4
#define WAVE_DC                 5
#define WAVE_SINC               6
#define WAVE_ARBITRARY          7

/* ============================================================
 * Convenience Inline Helpers
 * ============================================================ */

/** Write to FPGA control register */
static inline void FPGA_WriteReg(uint16_t reg, uint16_t value) {
    FPGA[reg] = value;
}

/** Read from FPGA register */
static inline uint16_t FPGA_ReadReg(uint16_t reg) {
    return FPGA[reg];
}

/** Set DAC start mode */
static inline void FPGA_DAC_Start(void) {
    uint16_t mode = FPGA_ReadReg(REG_MODE);
    FPGA_WriteReg(REG_MODE, mode | MODE_START_Msk);
}

/** Stop DAC (outputs mid-scale) */
static inline void FPGA_DAC_Stop(void) {
    uint16_t mode = FPGA_ReadReg(REG_MODE);
    FPGA_WriteReg(REG_MODE, mode & ~MODE_START_Msk);
}

/** Set DDS frequency (Hz) */
static inline void FPGA_SetFrequency(uint32_t freq_hz) {
    uint32_t freq_word = DDS_FREQ_TO_WORD(freq_hz);
    FPGA_WriteReg(REG_FREQ_H, (uint16_t)(freq_word >> 16));
    FPGA_WriteReg(REG_FREQ_L, (uint16_t)(freq_word & 0xFFFF));
}

/** Set amplitude (0-1023) */
static inline void FPGA_SetAmplitude(uint16_t amp) {
    if (amp > AMP_MAX) amp = AMP_MAX;
    FPGA_WriteReg(REG_AMP, amp);
}

/** Write waveform data to FPGA RAM */
static inline void FPGA_LoadWaveform(uint16_t start_addr,
                                      const uint16_t *data,
                                      uint32_t len) {
    for (uint32_t i = 0; i < len; i++) {
        FPGA[start_addr + i] = data[i];
    }
}

/** Check if DAC is running */
static inline uint8_t FPGA_IsRunning(void) {
    return (FPGA_ReadReg(REG_STATUS) >> STATUS_DAC_RUNNING_Pos) & 1;
}

#ifdef __cplusplus
}
#endif

#endif /* __FPGA_REG_MAP_H */
