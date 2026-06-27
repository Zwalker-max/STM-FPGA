/**
  ******************************************************************************
  * @file    dds.c
  * @brief   DDS driver implementation for AD9740 waveform generator
  ******************************************************************************
  */

#include "dds.h"
#include <math.h>

/* Sine lookup table (global, generated once at init) */
static uint16_t sine_lut[WAVEFORM_RAM_SIZE];
static float M_PI = 3.1415926;

/*===============================================================
 * 1. Sine Wave Lookup Table Generation
 *
 * Generates one full cycle (0 to 2*pi) of sine into lut[].
 * Output range: 0 to 2*amplitude, centered at amplitude.
 * For a 10-bit DAC (0-1023), amplitude=511 gives full-scale
 * centered at 511 (sine center). DAC mid-scale = 512 = 0x200
 * when disabled; there is a negligible 1-LSB offset.
 *
 * Safe range: amplitude <= 511 to avoid clipping.
 * Conservative default: amplitude = 511 (~full scale).
 *===============================================================*/
void DDS_GenerateSineLUT(uint16_t *lut, uint16_t amplitude)
{
    for (uint32_t i = 0; i < WAVEFORM_RAM_SIZE; i++)
    {
        double phase = 2.0 * M_PI * (double)i / (double)WAVEFORM_RAM_SIZE;
        double sin_val = sin(phase);                          /* -1.0 ~ +1.0   */
        double scaled  = (sin_val + 1.0) * (double)amplitude; /* 0 ~ 2*ampl    */
        int32_t sample = (int32_t)(scaled + 0.5);             /* round nearest  */
        if      (sample > 1023) sample = 1023;
        else if (sample < 0)    sample = 0;
        lut[i] = (uint16_t)sample;
    }
}

/*===============================================================
 * 2. Waveform RAM Bulk Write
 *
 * Write `count` samples to FPGA waveform RAM at offsets
 * 0x0000 to 0x03FF. Disables DAC before writing for safety,
 * re-enables after.
 *===============================================================*/
void DDS_WriteWaveformRAM(const uint16_t *data, uint32_t count)
{
    if (count > WAVEFORM_RAM_SIZE) count = WAVEFORM_RAM_SIZE;

    /* Freeze DAC output during bulk write to prevent mixed-data glitch */
    DDS_DisableDAC();

    for (uint32_t i = 0; i < count; i++)
    {
        FPGA[WAVEFORM_RAM_BASE + i] = data[i];
    }

    DDS_EnableDAC();
}

/*===============================================================
 * 3. FTW Computation
 *
 * Formula: FTW = round(f_target * 2^32 / 125_000_000)
 *
 * Verification values:
 *   1 Hz  -> FTW = round(1 * 2^32 / 125M)  = 34    (actual ~0.9897 Hz, -1.03%)
 *  10 Hz  -> FTW = round(10 * 2^32 / 125M) = 344   (actual ~10.01 Hz)
 * 100 Hz  -> FTW = 3436
 *  1 kHz  -> FTW = 34360
 * 10 kHz  -> FTW = 343597
 *  1 MHz  -> FTW = 34359738
 * 10 MHz  -> FTW = 343597384
 * 20 MHz  -> FTW = 687194767   (recommended max, ~6 points/cycle)
 *
 * Resolution ≈ 0.0291 Hz at 125 MHz DACCLK
 *===============================================================*/
uint32_t DDS_CalcFTW(double target_freq)
{
    /* Clamp to valid range */
    if (target_freq < 0.0)  target_freq = 0.0;
    if (target_freq > DAC_SAMPLE_RATE / 2.0) target_freq = DAC_SAMPLE_RATE / 2.0;

    double ftw = target_freq * FTW_SCALE / DAC_SAMPLE_RATE;
    return (uint32_t)(ftw + 0.5);   /* round to nearest integer */
}

/*===============================================================
 * 4. Atomic FTW Update
 *
 * Critical: STM32 writes FTW as two 16-bit halves.
 * Without shadow/update mechanism, DDS core could see a
 * half-updated FTW → glitch frequency.
 *
 * Sequence:
 *   1) Write FTW low 16 bits  → ftw_shadow[15:0]
 *   2) Write FTW high 16 bits → ftw_shadow[31:16]
 *   3) Write 1 to UPDATE_ADDR  → ftw_shadow → ftw_active (atomic)
 *
 * Interrupts disabled + DMB to guarantee write ordering.
 *===============================================================*/
void DDS_SetFrequency(double target_freq)
{
    uint32_t ftw = DDS_CalcFTW(target_freq);

    __disable_irq();
    FPGA[FTW_ADDR_LO] = (uint16_t)(ftw & 0xFFFF);
    FPGA[FTW_ADDR_HI] = (uint16_t)((ftw >> 16) & 0xFFFF);
    __DMB();                              /* barrier: ensure FMC writes complete */
    FPGA[UPDATE_ADDR] = 0x0001;           /* atomic load shadow→active */
    __enable_irq();
}

/*===============================================================
 * 5. Frequency Readback
 *
 * Reads FTW shadow register from FPGA (as written by STM32)
 * and computes equivalent frequency. Useful for verification
 * that the FTW was transmitted correctly.
 *
 * Returns frequency in Hz.
 *===============================================================*/
double DDS_ReadFrequency(void)
{
    uint16_t ftw_lo = FPGA[FTW_ADDR_LO];
    uint16_t ftw_hi = FPGA[FTW_ADDR_HI];
    uint32_t ftw    = ((uint32_t)ftw_hi << 16) | ftw_lo;

    return (double)ftw * DAC_SAMPLE_RATE / FTW_SCALE;
}

/*===============================================================
 * 6. DAC Output Control
 *===============================================================*/
void DDS_EnableDAC(void)
{
    FPGA[DAC_CTRL_ADDR] = 0x0001;    /* bit0=1 → normal DDS output */
}

void DDS_DisableDAC(void)
{
    FPGA[DAC_CTRL_ADDR] = 0x0000;    /* bit0=0 → force mid-scale 0x200 */
}

uint8_t DDS_GetDACState(void)
{
    uint16_t reg = FPGA[DAC_CTRL_ADDR];
    return (uint8_t)(reg & 0x01);
}

/*===============================================================
 * 7. Phase Accumulator Reset
 *
 * Clears the phase accumulator to zero, restarting the waveform
 * from address 0 (sine phase = 0°). Useful for synchronizing
 * multi-DDS systems or deterministic start-of-waveform.
 *===============================================================*/
void DDS_PhaseReset(void)
{
    FPGA[PHASE_RST_ADDR] = 0x0001;
}

/*===============================================================
 * 8. Waveform RAM Verification
 *
 * Reads back waveform RAM entries from FPGA and compares with
 * expected values. Returns number of mismatches.
 *===============================================================*/
uint32_t DDS_VerifyWaveform(const uint16_t *expected, uint32_t count)
{
    uint32_t errors = 0;
    if (count > WAVEFORM_RAM_SIZE) count = WAVEFORM_RAM_SIZE;

    /* If expected is NULL, compare against the internally stored LUT */
    if (expected == NULL) expected = sine_lut;

    for (uint32_t i = 0; i < count; i++)
    {
        uint16_t rd = FPGA[WAVEFORM_RAM_BASE + i];
        if ((rd & 0x03FF) != (expected[i] & 0x03FF)) /* only compare 10 bits */
        {
            errors++;
        }
    }
    return errors;
}

/*===============================================================
 * 9. Checksum of Waveform RAM (for quick validation)
 *===============================================================*/
uint16_t DDS_CalcChecksum(uint32_t start, uint32_t count)
{
    uint32_t sum = 0;
    for (uint32_t i = 0; i < count; i++)
    {
        sum += FPGA[WAVEFORM_RAM_BASE + start + i];
    }
    return (uint16_t)(sum & 0xFFFF);
}

/*===============================================================
 * 10. Initialize DDS Subsystem
 *
 * Generates 1024-point sine LUT, writes to FPGA waveform RAM,
 * sets default 1 kHz frequency, and enables DAC output.
 * Call once from main() after peripheral initialization.
 *===============================================================*/
void DDS_Init(void)
{
    /* Generate sine lookup table (amplitude=511 → full-scale 0-1022 centered at 511) */
    DDS_GenerateSineLUT(sine_lut, 511);

    /* Write waveform to FPGA */
    DDS_WriteWaveformRAM(sine_lut, WAVEFORM_RAM_SIZE);

    /* Default: 1 kHz sine */
    DDS_SetFrequency(1000.0);

    /* Reset phase to known state */
    DDS_PhaseReset();

    /* Enable DAC output */
    DDS_EnableDAC();
}

