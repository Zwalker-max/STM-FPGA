/**
 ******************************************************************************
 * @file    waveform_gen.c
 * @brief   Waveform generation implementation
 * @note    Uses float math (sin, exp, etc.) on Cortex-M7 with hardware FPU.
 *          Compiled with -O1 or higher for FPU optimization.
 *          All values clamped to 0-1023 for 10-bit DAC.
 ******************************************************************************
 */

#include "main.h"
#include "waveform_gen.h"
#include <math.h>
#include <string.h>

/* Internal helper: clamp to DAC range */
static inline uint16_t clamp_dac(int32_t val) {
    if (val < 0) return 0;
    if (val > DAC_MAX_VALUE) return DAC_MAX_VALUE;
    return (uint16_t)val;
}

/* ============================================================
 * Sine Wave
 *   buf[i] = offset + amplitude * sin(2 * PI * i / points)
 * ============================================================ */
uint32_t Gen_SineWave(uint16_t *buf, uint32_t points,
                      uint16_t amplitude, uint16_t offset) {
    if (!buf || points == 0) return 0;

    for (uint32_t i = 0; i < points; i++) {
        float phase = 2.0f * (float)M_PI * (float)i / (float)points;
        int32_t val = (int32_t)((float)offset +
                                (float)amplitude * sinf(phase) + 0.5f);
        buf[i] = clamp_dac(val);
    }
    return points;
}

/* ============================================================
 * Triangle Wave
 *   Linear ramp 0→amplitude→0→-amplitude→0 over one period
 * ============================================================ */
uint32_t Gen_TriangleWave(uint16_t *buf, uint32_t points,
                          uint16_t amplitude, uint16_t offset) {
    if (!buf || points == 0) return 0;

    uint32_t quarter = points / 4;
    for (uint32_t i = 0; i < points; i++) {
        int32_t val;
        uint32_t phase = i % points;

        if (phase < quarter) {
            /* Rising 0 → +amp */
            val = (int32_t)((int64_t)amplitude * phase / quarter);
        } else if (phase < 2 * quarter) {
            /* Falling +amp → 0 */
            val = (int32_t)((int64_t)amplitude * (2 * quarter - phase) / quarter);
        } else if (phase < 3 * quarter) {
            /* Falling 0 → -amp */
            val = -(int32_t)((int64_t)amplitude * (phase - 2 * quarter) / quarter);
        } else {
            /* Rising -amp → 0 */
            val = -(int32_t)((int64_t)amplitude * (4 * quarter - phase) / quarter);
        }

        buf[i] = clamp_dac((int32_t)offset + val);
    }
    return points;
}

/* ============================================================
 * Square Wave
 *   First duty_pct% of period → +amplitude, rest → -amplitude
 * ============================================================ */
uint32_t Gen_SquareWave(uint16_t *buf, uint32_t points,
                        uint16_t amplitude, uint16_t offset,
                        uint8_t duty_pct) {
    if (!buf || points == 0) return 0;
    if (duty_pct > 100) duty_pct = 100;

    uint32_t high_samples = (uint32_t)points * duty_pct / 100;

    for (uint32_t i = 0; i < points; i++) {
        int32_t val = (i < high_samples)
                      ? (int32_t)offset + amplitude
                      : (int32_t)offset - amplitude;
        buf[i] = clamp_dac(val);
    }
    return points;
}

/* ============================================================
 * Sawtooth Wave (rising)
 *   Linear ramp from -amplitude to +amplitude over one period
 * ============================================================ */
uint32_t Gen_SawtoothWave(uint16_t *buf, uint32_t points,
                          uint16_t amplitude, uint16_t offset) {
    if (!buf || points == 0) return 0;

    for (uint32_t i = 0; i < points; i++) {
        /* -amp → +amp linear over [0, points-1] */
        int32_t val = (int32_t)((int64_t)(2 * amplitude) * i / points) - amplitude;
        buf[i] = clamp_dac((int32_t)offset + val);
    }
    return points;
}

/* ============================================================
 * Reverse Sawtooth Wave (falling)
 * ============================================================ */
uint32_t Gen_RevSawtoothWave(uint16_t *buf, uint32_t points,
                             uint16_t amplitude, uint16_t offset) {
    if (!buf || points == 0) return 0;

    for (uint32_t i = 0; i < points; i++) {
        /* +amp → -amp linear over [0, points-1] */
        int32_t val = (int32_t)amplitude -
                      (int32_t)((int64_t)(2 * amplitude) * i / points);
        buf[i] = clamp_dac((int32_t)offset + val);
    }
    return points;
}

/* ============================================================
 * DC Level
 * ============================================================ */
uint32_t Gen_DCLevel(uint16_t *buf, uint32_t points, uint16_t level) {
    if (!buf || points == 0) return 0;

    uint16_t val = clamp_dac(level);
    for (uint32_t i = 0; i < points; i++) {
        buf[i] = val;
    }
    return points;
}

/* ============================================================
 * Sinc (sin(x)/x) Pulse
 *   Central lobe + N side lobes on each side
 * ============================================================ */
uint32_t Gen_SincWave(uint16_t *buf, uint32_t points,
                      uint16_t amplitude, uint8_t lobes) {
    if (!buf || points == 0) return 0;
    if (lobes < 1) lobes = 1;
    if (lobes > 10) lobes = 10;

    /* Map i=0..points-1 to x = -(lobes+1)*PI .. +(lobes+1)*PI */
    float x_min = -(float)(lobes + 1) * (float)M_PI;
    float x_max =  (float)(lobes + 1) * (float)M_PI;

    for (uint32_t i = 0; i < points; i++) {
        float x = x_min + (x_max - x_min) * (float)i / (float)(points - 1);
        float sinc_val;
        if (fabsf(x) < 0.0001f) {
            sinc_val = 1.0f;   /* sinc(0) = 1 */
        } else {
            sinc_val = sinf(x) / x;
        }
        int32_t val = (int32_t)((float)amplitude * sinc_val + (float)DAC_MID_VALUE + 0.5f);
        buf[i] = clamp_dac(val);
    }
    return points;
}

/* ============================================================
 * Pseudo-Random Noise
 *   LCG: X_{n+1} = (1664525 * X_n + 1013904223) mod 2^32
 * ============================================================ */
uint32_t Gen_NoiseWave(uint16_t *buf, uint32_t points,
                       uint16_t amplitude, uint16_t offset, uint32_t seed) {
    if (!buf || points == 0) return 0;

    uint32_t state = seed;
    for (uint32_t i = 0; i < points; i++) {
        state = 1664525UL * state + 1013904223UL;
        /* Map to signed range, scale, add offset */
        int32_t noise = (int32_t)(state & 0xFFFF) - 32768;   /* -32768 .. +32767 */
        int32_t val = (int32_t)offset + (int32_t)((int64_t)amplitude * noise / 32768);
        buf[i] = clamp_dac(val);
    }
    return points;
}

/* ============================================================
 * Exponential Decay Pulse
 *   buf[i] = offset + amplitude * exp(-i / tau)
 * ============================================================ */
uint32_t Gen_ExpDecay(uint16_t *buf, uint32_t points,
                      uint16_t amplitude, uint32_t tau_samples) {
    if (!buf || points == 0) return 0;
    if (tau_samples < 1) tau_samples = 1;

    for (uint32_t i = 0; i < points; i++) {
        float decay = expf(-(float)i / (float)tau_samples);
        int32_t val = (int32_t)((float)DAC_MID_VALUE +
                                (float)amplitude * decay + 0.5f);
        buf[i] = clamp_dac(val);
    }
    return points;
}

/* ============================================================
 * Gaussian (Bell) Pulse
 *   buf[i] = offset + amplitude * exp(-(i - center)^2 / (2 * sigma^2))
 *   center = points / 2
 * ============================================================ */
uint32_t Gen_GaussianPulse(uint16_t *buf, uint32_t points,
                           uint16_t amplitude, uint32_t sigma_samples) {
    if (!buf || points == 0) return 0;
    if (sigma_samples < 1) sigma_samples = 1;

    float center = (float)points / 2.0f;
    float two_sigma_sq = 2.0f * (float)sigma_samples * (float)sigma_samples;

    for (uint32_t i = 0; i < points; i++) {
        float dx = (float)i - center;
        float gauss = expf(-(dx * dx) / two_sigma_sq);
        int32_t val = (int32_t)((float)DAC_MID_VALUE +
                                (float)amplitude * gauss + 0.5f);
        buf[i] = clamp_dac(val);
    }
    return points;
}

/* ============================================================
 * Custom / Arbitrary Waveform
 *   从用户提供的数组复制数据到输出缓冲区
 *   超出源数据长度的部分默认填充 DAC_MID_VALUE
 * ============================================================ */
uint32_t Gen_CustomWave(uint16_t *buf, uint32_t points,
                        const uint16_t *custom_data, uint32_t data_len) {
    if (!buf || points == 0 || !custom_data || data_len == 0) return 0;

    uint32_t i;
    for (i = 0; i < points && i < data_len; i++) {
        buf[i] = clamp_dac(custom_data[i]);
    }
    /* Fill remaining with mid-scale if custom data is shorter */
    for (; i < points; i++) {
        buf[i] = DAC_MID_VALUE;
    }
    return points;
}
