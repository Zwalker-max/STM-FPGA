/**
 ******************************************************************************
 * @file    app_awg.h
 * @brief   AWG application layer interface
 * @note    Board_InitEarly must be called before HAL_Init();
 *          APP_AWG_Init after all peripheral inits;
 *          APP_AWG_Task in the main loop.
 ******************************************************************************
 */

#ifndef __APP_AWG_H
#define __APP_AWG_H

#ifdef __cplusplus
extern "C" {
#endif

/* ============================================================
 * Public API
 * ============================================================ */

/** Early board initialization (MPU + Cache), call before HAL_Init */
void Board_InitEarly(void);

/** AWG application init: banner, default waveform, UART console */
void APP_AWG_Init(void);

/** Main loop task: poll UART commands and dispatch */
void APP_AWG_Task(void);

#ifdef __cplusplus
}
#endif

#endif /* __APP_AWG_H */
