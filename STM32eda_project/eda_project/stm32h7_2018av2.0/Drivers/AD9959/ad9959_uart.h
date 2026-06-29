#ifndef __AD9959_UART_H
#define __AD9959_UART_H

#include "main.h"
#include "usart.h"

//ch 通道 0,1,2,3
void AD9959_init();  //初始化
void AD9959_setFreq(uint8_t ch,uint32_t f);  //f  频率 Hz
void AD9959_setAmp(uint8_t ch,uint32_t a);  //a  幅值 [0,1023]
void AD9959_setPhase(uint8_t ch,uint32_t p);  //p  相位 [0,16383]   对应   [0, 2*pi) rad


#endif
