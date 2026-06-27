/**
  ******************************************************************************
  * @file    dds.h
  * @brief   DDS driver for AD9740 waveform generator
  *
  * Provides sine LUT generation, FTW computation, waveform RAM write,
  * DAC control, and USART command processing.
  ******************************************************************************
  */

#ifndef __DDS_H
#define __DDS_H

#include "stm32h7xx_hal.h"
#include <stdint.h>

/* FPGA Register Offsets (FMC address, 16-bit word offset from 0x60000000) */
#define FPGA_BASE_ADDR      0x60000000
#define FPGA                ((volatile uint16_t *)FPGA_BASE_ADDR)

#define WAVEFORM_RAM_SIZE   1024
#define WAVEFORM_RAM_BASE   0x0000      /* 0x0000-0x03FF */
#define FTW_ADDR_LO         0x0400      /* FTW[15:0] */
#define FTW_ADDR_HI         0x0401      /* FTW[31:16] */
#define UPDATE_ADDR         0x0404      /* update enable (write 1) */
#define PHASE_RST_ADDR      0x0408      /* phase reset (write 1) */
#define DAC_CTRL_ADDR       0x040C      /* DAC control (bit0=1 normal, 0 mid-scale) */

/* DDS Physical Constants */
#define DAC_SAMPLE_RATE     125000000.0  /* 125 MHz */
#define PHASE_ACC_BITS      32           /* accumulator width */
#define FTW_SCALE           4294967296.0 /* 2^32 */

/* USART handle (for TX output) */
extern UART_HandleTypeDef huart1;

/*===============================================================
 * API Functions
 *===============================================================*/

/* Waveform generation */
void    DDS_GenerateSineLUT(uint16_t *lut, uint16_t amplitude);
void    DDS_WriteWaveformRAM(const uint16_t *data, uint32_t count);

/* Frequency tuning */
uint32_t DDS_CalcFTW(double target_freq);
void     DDS_SetFrequency(double target_freq);
double   DDS_ReadFrequency(void);

/* DAC control */
void     DDS_EnableDAC(void);
void     DDS_DisableDAC(void);
uint8_t  DDS_GetDACState(void);

/* Phase reset */
void     DDS_PhaseReset(void);

/* Verification */
uint32_t DDS_VerifyWaveform(const uint16_t *expected, uint32_t count);
uint16_t DDS_CalcChecksum(uint32_t start, uint32_t count);

/* Initialization */
void     DDS_Init(void);

#endif /* __DDS_H */
