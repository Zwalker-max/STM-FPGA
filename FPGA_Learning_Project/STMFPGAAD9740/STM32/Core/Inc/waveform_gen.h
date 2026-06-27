/**
 ******************************************************************************
 * @file    waveform_gen.h
 * @brief   Waveform generation library for AD9740 AWG
 * @note    Generates uint16_t waveform tables for the 10-bit DAC
 *          All samples range 0-1023 (10-bit, mapped to DAC_DATA[9:0])
 *
 * Memory: the FPGA dual-port RAM is 2048 x 16-bit.
 *   Buffer size: up to 2048 words (fits in one M9K block)
 ******************************************************************************
 */

#ifndef __WAVEFORM_GEN_H
#define __WAVEFORM_GEN_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* ============================================================
 * DAC data range
 *   AD9740: 10-bit, straight binary
 *   0x000 = min (0 mA), 0x3FF = max (20 mA with 2k RSET)
 *   Mid-scale = 0x200 (512)
 * ============================================================ */
#define DAC_MAX_VALUE   1023
#define DAC_MID_VALUE   512
#define DAC_MIN_VALUE   0

/* ============================================================
 * Waveform generation functions
 *
 * Each fills buf[0..points-1] with 0-1023 range samples.
 * Returns actual number of samples written (== points).
 * ============================================================ */

/**
 * @brief  Generate sine wave table
 * @param  buf       Output buffer (caller-allocated)
 * @param  points    Number of samples (e.g. 256, 1024, 4096)
 * @param  amplitude Peak amplitude (0-511, where 511 = full swing from mid-scale)
 * @param  offset    DC offset (typically 512 = mid-scale)
 * @return Number of samples written
 */
uint32_t Gen_SineWave(uint16_t *buf, uint32_t points,
                      uint16_t amplitude, uint16_t offset);

/**
 * @brief  Generate triangle wave table (linear ramp up/down)
 */
uint32_t Gen_TriangleWave(uint16_t *buf, uint32_t points,
                          uint16_t amplitude, uint16_t offset);

/**
 * @brief  Generate square wave table
 * @param  duty_pct  Duty cycle in percent (0-100, typically 50)
 */
uint32_t Gen_SquareWave(uint16_t *buf, uint32_t points,
                        uint16_t amplitude, uint16_t offset,
                        uint8_t duty_pct);

/**
 * @brief  Generate sawtooth wave table (rising ramp)
 */
uint32_t Gen_SawtoothWave(uint16_t *buf, uint32_t points,
                          uint16_t amplitude, uint16_t offset);

/**
 * @brief  Generate reverse sawtooth wave table (falling ramp)
 */
uint32_t Gen_RevSawtoothWave(uint16_t *buf, uint32_t points,
                             uint16_t amplitude, uint16_t offset);

/**
 * @brief  Generate constant DC level
 * @param  level  DC value (0-1023)
 */
uint32_t Gen_DCLevel(uint16_t *buf, uint32_t points, uint16_t level);

/**
 * @brief  Generate sinc (sin(x)/x) pulse table
 * @param  lobes  Number of side lobes (1-10)
 */
uint32_t Gen_SincWave(uint16_t *buf, uint32_t points,
                      uint16_t amplitude, uint8_t lobes);

/**
 * @brief  Generate white noise table (pseudo-random)
 * @param  seed   RNG seed
 */
uint32_t Gen_NoiseWave(uint16_t *buf, uint32_t points,
                       uint16_t amplitude, uint16_t offset, uint32_t seed);

/**
 * @brief  Generate exponential decay pulse
 * @param  tau_samples Decay time constant in samples
 */
uint32_t Gen_ExpDecay(uint16_t *buf, uint32_t points,
                      uint16_t amplitude, uint32_t tau_samples);

/**
 * @brief  Generate Gaussian (bell) pulse
 * @param  sigma_samples Standard deviation in samples
 */
uint32_t Gen_GaussianPulse(uint16_t *buf, uint32_t points,
                           uint16_t amplitude, uint32_t sigma_samples);

#ifdef __cplusplus
}
#endif

#endif /* __WAVEFORM_GEN_H */
