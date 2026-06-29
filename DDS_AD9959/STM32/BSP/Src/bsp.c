#include "bsp.h"
#include "bsp_gpio.h"
#include "bsp_uart.h"
#include "bsp_lcd.h"
#include "bsp_ad9959.h"

char     guart1_TxMsg[UART_BUF_SIZE];
char     guart1_RxMsg[UART_BUF_SIZE];
char     guart2_TxMsg[UART_BUF_SIZE];
char     guart2_RxMsg[UART_BUF_SIZE];
uint16_t glcd_TxBuf[LCD_BUF_SIZE];

BSP_UART_HandleTypeDef buart1 = {
	.huart  = &huart1,
	.pTxMsg = guart1_TxMsg,
	.pRxMsg = guart1_RxMsg,
};

BSP_UART_HandleTypeDef buart2 = {
	.huart  = &huart2,
	.pTxMsg = guart2_TxMsg,
	.pRxMsg = guart2_RxMsg,
};

LCD_HandleTypeDef blcd = {
	.Instance = &LCD_1_80_inch,
	.hspi     = &hspi4,
	.dir      = LCD_DIR_RIGHT,
	.TxBuf    = glcd_TxBuf,
	.foreColor= WHITE,
	.backColor= BLACK,
};

myDualADC_HandleTypeDef myDualADC = { 
	.hadc_master = &hadc1, 
	.hadc_slave = &hadc2, 
	.htim = &htim6, 
	.ConvFinish = false 
};

static void PeriodicProcess(void);
static void UpdateScreen(void);

void MainProcess(void)
{
	while (1)
	{
		
	}
}


void HAL_UARTEx_RxEventCallback(UART_HandleTypeDef *huart, uint16_t Size)
{
	if (huart == buart1.huart)
	{
		BSP_UART_Transmit_DMA(&buart1, "RxMsg: %s", buart1.pRxMsg);
		BSP_UART_ReceiveToIdle_DMA(&buart1);
	}
}

void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *htim)
{
}

void HAL_ADC_ConvCpltCallback(ADC_HandleTypeDef *hadc)
{
	if(hadc == myDualADC.hadc_master)
	{
	  myDualADC.ConvFinish = true;
	}
}