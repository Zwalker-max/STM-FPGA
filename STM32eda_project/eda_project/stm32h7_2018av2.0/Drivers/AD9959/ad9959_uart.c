
#include <stdint.h>
#include "ad9959_uart.h"

#define CMD_AD9959_RESET 		0x00
#define CMD_AD9959_SET_FREQ 	0x01
#define CMD_AD9959_SET_AMP 	0x02
#define CMD_AD9959_SET_PHASE 0x03


static void u32_to_u8array(uint32_t data_in,uint8_t *data_out);
static uint32_t u8array_to_u32(uint8_t *data_in);
static uint8_t getChecksum(uint8_t *data,uint8_t len);

static void genAndSendData(uint8_t cmd,uint8_t ch,uint32_t data);

//----------------------------------用户需要实现的接口----------------------------------
//调用串口
//data为数据数组
//len为长度
void AD9959_uart_send(uint8_t *data,uint8_t len)
{
    HAL_UART_Transmit(&huart2,data,len,100);
}

void AD9959_init()
{
    genAndSendData(CMD_AD9959_RESET,0,0);
}

//ch 通道 0,1,2,3
//f  频率 Hz
void AD9959_setFreq(uint8_t ch,uint32_t f)
{
    if(ch>3)
        return;
    genAndSendData(CMD_AD9959_SET_FREQ,ch,f);
}

//ch 通道 0,1,2,3
//a  幅值 [0,1023]
void AD9959_setAmp(uint8_t ch,uint32_t a)
{
    if(ch>3)
        return;
    if(a>1023)
        a=1023;
    genAndSendData(CMD_AD9959_SET_AMP,ch,a);
}

//ch 通道 0,1,2,3
//p  相位 [0,16383]   对应   [0, 2*pi) rad
void AD9959_setPhase(uint8_t ch,uint32_t p)
{
    if(ch>3)
        return;
    if(p>16383)
        p=16383;
    genAndSendData(CMD_AD9959_SET_PHASE,ch,p);
}

//----------------------------------局部函数----------------------------------
static uint8_t AD9959_uart_buff[16];
static void genAndSendData(uint8_t cmd,uint8_t ch,uint32_t data)
{
    uint8_t *buff = AD9959_uart_buff;
    uint8_t temp[4];
    u32_to_u8array(data,temp);

    buff[0] = 0xD0;
    buff[1] = 0xD1;
    buff[2] = cmd;
    buff[3] = ch;
    buff[4] = temp[0];
    buff[5] = temp[1];
    buff[6] = temp[2];
    buff[7] = temp[3];
    buff[8] = getChecksum(buff,8);
    buff[9] = 0xD1;

    AD9959_uart_send(buff,10);
}

static void u32_to_u8array(uint32_t data_in,uint8_t *data_out)
{
    uint32_t temp=data_in;
    data_out[0] =  temp        & 0xFF;  //低字节在低地址 即小端模式
    data_out[1] = (temp >> 8)  & 0xFF;
    data_out[2] = (temp >> 16) & 0xFF;
    data_out[3] = (temp >> 24) & 0xFF;
}

static uint32_t u8array_to_u32(uint8_t *data_in)
{
    uint32_t temp=0;
    temp |= ((uint32_t)data_in[0]) ;
    temp |= ((uint32_t)data_in[1]) << 8;
    temp |= ((uint32_t)data_in[2]) << 16;
    temp |= ((uint32_t)data_in[3]) << 24;
    return temp;
}

uint8_t isCheckOk(uint8_t *data,uint8_t len)
{
	uint8_t sum=0;
	for(uint8_t i=0 ; i< len-2 ; i++)
		sum += data[i];
	
	if(sum == data[len-2])
		return 1;
	else
		return 0;
}

static uint8_t getChecksum(uint8_t *data,uint8_t len)
{
    uint8_t sum=0;
	for(uint8_t i=0 ; i< len ; i++)
		sum += data[i];

    return sum;
}

