/**
  ******************************************************************************
  * @file    adc.h
  * @brief   AD9220 ADC acquisition driver (FIFO-over-FMC + DMA ping-pong)
  *
  * FMC 寄存器偏移与 FPGA stm32_fmc_16bit.v 中的 ADC 译码一一对应：
  *   0x1000 ADC 控制(bit0=使能)   0x1001/0x1002 步进影子 lo/hi
  *   0x1003 步进更新触发           0x1004 FIFO 数据(读一次弹一个)
  *   0x1005 FIFO 状态(bit0空 bit1满 [11:2]usedw)
  *
  * 采样率：FPGA 10MHz 域 32 位相位累加器做抽取（步进 = hz*2^32/10e6）；
  *         STM32 TIM2 以 hz 节拍触发 DMA2_Stream0 从 FIFO 读一个半字，
  *         双方同频 → FIFO 仅吸收 10MHz 域与 APB1 域的慢漂移。
  ******************************************************************************
  */
#ifndef __ADC_H
#define __ADC_H

#include "stm32h7xx_hal.h"
#include "dds.h"        /* FPGA 宏 + FMC 访问 */
#include <stdint.h>

/* ---- FMC 寄存器偏移（16 位字地址）---- */
#define ADC_CTRL_ADDR       0x1000
#define ADC_STEP_LO_ADDR    0x1001
#define ADC_STEP_HI_ADDR    0x1002
#define ADC_STEP_UPD_ADDR   0x1003
#define ADC_FIFO_DATA_ADDR  0x1004
#define ADC_FIFO_STAT_ADDR  0x1005

/* ---- 物理常数 ---- */
#define ADC_SAMPLE_RATE     10000000.0     /* 10 MHz ADC 采样时钟（pll1.c2）*/
#define ADC_STEP_SCALE      4294967296.0   /* 2^32 */

/* ---- DMA 双缓冲（乒乓：HT 处理前半，TC 处理后半）---- */
#define ADC_DMA_BUF_LEN     256            /* 每半缓冲半字数；总缓冲 = 2×N */

/* ---- FIFO 状态寄存器位 ---- */
#define ADC_STAT_EMPTY      0x0001u
#define ADC_STAT_FULL       0x0002u
#define ADC_STAT_USEDM_POS  2
#define ADC_STAT_USEDM_MSK  (0x3FFu << ADC_STAT_USEDM_POS)  /* bits[11:2] */

/* ---- API ---- */
void     ADC_Init(void);
void     ADC_Enable(uint8_t en);
void     ADC_SetSampleRate(double hz);
void     ADC_Start(void);
void     ADC_Stop(void);

uint16_t ADC_GetFIFOData(void);
uint16_t ADC_GetFIFOStatus(void);
uint8_t  ADC_FIFOIsEmpty(uint16_t status);
uint8_t  ADC_FIFOIsFull(uint16_t status);
uint16_t ADC_FIFOUsedWords(uint16_t status);

/* 用户数据处理回调（弱定义；可在 main.c 中以非弱版本重写）*/
void     ADC_ProcessData(uint16_t *buf, uint32_t len);

#endif /* __ADC_H */
