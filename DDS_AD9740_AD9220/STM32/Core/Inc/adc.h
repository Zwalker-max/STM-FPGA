/**
  ******************************************************************************
  * @file    adc.h
  * @brief   ADC driver for AD9220 acquisition subsystem
  *
  * Provides FMC register access + DMA ping-pong buffering for the FPGA
  * ADC subsystem: sample rate setting, FIFO data read, status polling,
  * and TIM12-paced DMA transfer with half/full interrupt callbacks.
  ******************************************************************************
  */

#ifndef __ADC_H
#define __ADC_H

#include "stm32h7xx_hal.h"
#include <stdint.h>
#include <stdbool.h>

/* FPGA Register Offsets for ADC subsystem (16-bit word offset from 0x60000000) */
#define ADC_CTRL_ADDR         0x1000      /* ADC control: bit0 = enable */
#define ADC_STEP_LO_ADDR      0x1001      /* Sample-rate step [15:0] */
#define ADC_STEP_HI_ADDR      0x1002      /* Sample-rate step [31:16] */
#define ADC_STEP_UPDATE_ADDR  0x1003      /* Step update trigger (write 1 → atomic load) */
#define ADC_FIFO_DATA_ADDR    0x1004      /* FIFO data port (read pops one 16-bit word) */
#define ADC_FIFO_STATUS_ADDR  0x1005      /* FIFO status: bit0=empty, bit1=full, bits[11:2]=rdusedw */

/* ADC Physical Constants */
#define ADC_SAMPLE_CLK_HZ     10000000.0  /* 10 MHz */
#define ADC_PHASE_ACC_BITS    32          /* accumulator width */
#define ADC_STEP_SCALE        4294967296.0 /* 2^32 */

/* FIFO depth (from FPGA async_fifo) */
#define ADC_FIFO_DEPTH        1024

/* DMA buffer size (halfwords — each half is this many 16-bit words) */
#define ADC_DMA_BUF_SIZE      256

/*===============================================================
 * DMA Buffer (ping-pong, placed in AXI SRAM via scatter file)
 *===============================================================*/
extern uint16_t adc_dma_buf[2][ADC_DMA_BUF_SIZE];

/*===============================================================
 * API Functions
 *===============================================================*/

/* Initialization */
void ADC_Init(void);

/* Control */
void ADC_Enable(bool enable);
void ADC_Start(void);
void ADC_Stop(void);
bool ADC_IsEnabled(void);

/* Sample rate — atomic step write (lo→hi→trigger, irq-locked) */
uint32_t ADC_CalcStep(float sample_rate_hz);
void     ADC_SetSampleRate(float sample_rate_hz);
float    ADC_ReadSampleRate(void);

/* FIFO access (non-DMA / debugging) */
uint16_t ADC_GetFIFOData(void);
uint16_t ADC_GetFIFOStatus(void);
bool     ADC_IsFIFOEmpty(void);
bool     ADC_IsFIFOFull(void);
uint16_t ADC_GetFIFOCount(void);

/* DMA management (TIM12-paced, ping-pong) */
void     ADC_DMA_Start(void);
void     ADC_DMA_Stop(void);
bool     ADC_DMA_IsRunning(void);
uint16_t ADC_DMA_GetOverruns(void);

/* DMA IRQ handler (call from DMA2_Stream0_IRQHandler) */
void     ADC_DMA_IRQHandler(void);

/* User data processing callback (__weak — override in application) */
void ADC_ProcessData(const uint16_t *buf, uint16_t len);

#endif /* __ADC_H */
