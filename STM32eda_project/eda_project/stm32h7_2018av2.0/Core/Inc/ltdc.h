/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file    ltdc.h
  * @brief   This file contains all the function prototypes for
  *          the ltdc.c file
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2023 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  ******************************************************************************
  */
/* USER CODE END Header */
/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef __LTDC_H__
#define __LTDC_H__

#ifdef __cplusplus
extern "C" {
#endif

/* Includes ------------------------------------------------------------------*/
#include "main.h"

/* USER CODE BEGIN Includes */

/* USER CODE END Includes */

extern LTDC_HandleTypeDef hltdc;

/* USER CODE BEGIN Private defines */
#define LCD_LED(n)              (n?HAL_GPIO_WritePin(GPIOB,GPIO_PIN_5,GPIO_PIN_SET):HAL_GPIO_WritePin(GPIOB,GPIO_PIN_5,GPIO_PIN_RESET))   //LCD背光PD13              //LCD背光PD13
#define u8 uint8_t
#define u16 uint16_t
#define u32 uint32_t

typedef struct
{
    u32 pwidth;
    u32 pheight;
    u16 hsw;
    u16 vsw;
    u16 hbp;
    u16 vbp;
    u16 hfp;
    u16 vfp;
    u8 activelayer;
    u8 dir;
    u16 width;
    u16 height;
    u32 pixsize;
}_ltdc_dev;

extern _ltdc_dev lcdltdc;
extern LTDC_HandleTypeDef LTDC_Handler;
extern DMA2D_HandleTypeDef DMA2D_Handler;
extern u32 *ltdc_framebuf[2];

#define LCD_PIXEL_FORMAT_ARGB8888       0X00
#define LCD_PIXEL_FORMAT_RGB888         0X01
#define LCD_PIXEL_FORMAT_RGB565         0X02
#define LCD_PIXEL_FORMAT_ARGB1555       0X03
#define LCD_PIXEL_FORMAT_ARGB4444       0X04
#define LCD_PIXEL_FORMAT_L8             0X05
#define LCD_PIXEL_FORMAT_AL44           0X06
#define LCD_PIXEL_FORMAT_AL88           0X07

#define WHITE         	 0xFFFF
#define BLACK         	 0x0000
#define BLUE         	 	 0x001F
#define BRED             0XF81F
#define GRED 			 			  0XFFE0
#define GBLUE			 				0X07FF
#define RED           	 0xF800
#define MAGENTA       	 0xF81F
#define GREEN         	 0x07E0
#define CYAN          	 0x7FFF
#define YELLOW        	 0xFFE0
#define BROWN 			    0XBC40
#define BRRED 			    0XFC07
#define GRAY  			    0X8430

#define LCD_PIXFORMAT				LCD_PIXEL_FORMAT_RGB565

#define LTDC_BACKLAYERCOLOR			0X00000000

#define LCD_FRAME_BUF_ADDR			0XC0000000

//LCD参数

/* USER CODE END Private defines */

void MX_LTDC_Init(void);

/* USER CODE BEGIN Prototypes */

void LTDC_Init(void);
void LTDC_Fill(uint16_t sx,uint16_t sy,uint16_t ex,uint16_t ey,uint32_t color);
void LTDC_Clear(uint32_t color);

void LTDC_Color_Fill(u16 sx,u16 sy,u16 ex,u16 ey,u16 *color);
void LTDC_Switch(u8 sw);
void LTDC_Select_Layer(u8 layerx);
void LTDC_Display_Dir(u8 dir);
void LTDC_Draw_Point(u16 x,u16 y,u32 color);
u32 LTDC_Read_Point(u16 x,u16 y);
/* USER CODE END Prototypes */

#ifdef __cplusplus
}
#endif

#endif /* __LTDC_H__ */

