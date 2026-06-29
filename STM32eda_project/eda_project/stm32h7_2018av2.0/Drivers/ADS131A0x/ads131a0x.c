//
// Created by 24016 on 2023/7/28.
//
#include "ads131a0x.h"
#include "stdio.h"
/*

├── GPIO_Init,SPI_DMA_Init (cubemx)
├── 通信基本函数
│   ├── 发送命令函数                       ADS131A04_Write_Command
│   └── 读写寄存器函数                     ADS131A04_Write_Reg
│       ├── 设置输入时钟预分频              ADS131A04_ICLK_SET_PREDIV
│       ├── 设置调制时钟预分频和过采样率      ADS131A04_MODULATION_SET_PREDIV
│       ├── 设置通道增益                   ADS131A04_Gain_SET
│       └── 设置参考电压                   ADS131A04_REF_SET
├── 上电初始化
│   └── 手册上电初始化                     ADS131A04_Power_Up
├── 应用函数
│   ├── 通道使能         ADS_Set_CH_Enable
│   ├── 采样点数设置      ADS_Set_n
│   ├── 填充数据函数      ADS_Fill_Data
│   ├── 开始接收函数      ADS_Start
│   ├── 停止接收函数      ADS_Stop
│   └── 应用初始化       ADS131A04_Init
├── 中断函数
│   ├── PP开启时
│   │   ├── ADS_HalfPP_Callback
│   │   └── ADS_FullPP_Callback
│   └── 不开启
│       └── ADS_FullPP_Callback

 */

uint32_t ADS131A04_Write_Command(uint32_t command){
    uint32_t rev=0;
    uint32_t cmd;
    cmd=(uint32_t)command<<16;
    HAL_SPI_TransmitReceive(&hspi2,&cmd,&rev,1,30);
    return rev;
}

uint32_t ADS131A04_Write_Reg(uint8_t reg_add,uint8_t data){
    uint32_t temp=0;
    uint32_t volatile com_t=0;
    com_t=((uint32_t)reg_add<<24)+((uint32_t)data<<16);
    if((reg_add&0x20)==0x20){
        ADS131A04_Write_Command(((uint32_t)reg_add<<24)>>16);
        temp=ADS131A04_Write_Command(ADS_NULL);
    }
    else{
        temp=ADS131A04_Write_Command(com_t>>16);
    }
    return temp;
}

/*-------------------------------------------------------------
  *  @brief     设置调制时钟的预分频系数
  *  @param     pre_divider_mod     设置调制时钟的预分频系数，详细见参数列表
                    ADS_INCLK_DIV_2,ADS_INCLK_DIV_4,ADS_INCLK_DIV_6,ADS_INCLK_DIV_8,ADS_INCLK_DIV_10,ADS_INCLK_DIV_12,ADS_INCLK_DIV_14
  *             pre_divider_osr     设置过采样率
                    ADS_OSR_DIV_4096,ADS_OSR_DIV_2048,ADS_OSR_DIV_1024,ADS_OSR_DIV_800,ADS_OSR_DIV_768,ADS_OSR_DIV_512
                    ADS_OSR_DIV_400,ADS_OSR_DIV_384,ADS_OSR_DIV_256,ADS_OSR_DIV_200,ADS_OSR_DIV_192,ADS_OSR_DIV_128
                    ADS_OSR_DIV_96,ADS_OSR_DIV_64,ADS_OSR_DIV_48,ADS_OSR_DIV_32
  *  @return    已置位数据，将设好的与返回值相或
  *  @note      none
  *  @Sample usage:     ADS131A04_MOD_SET_PREDIV(INCLK_DIV_4)
 -------------------------------------------------------------*/
ADS_res ADS131A04_MODULATION_SET_PREDIV(uint8_t pre_divider_mod,uint8_t pre_divider_osr){
    uint8_t temp=0x00;
    uint32_t rev=ADS131A04_Write_Reg(WRITE_CMD|CLK2,(pre_divider_mod<<5)|pre_divider_osr);
    printf("\n\rMODULATION_SET_PREDIV接收到的回复：%lx\n\r",rev);
    return ADS_OK;
}
/*-------------------------------------------------------------
  *  @brief     设置ADC同步模式时的预分频系数
  *  @param     pre_divider     预分频参数，详细见参数列表
  *             ADS_INCLK_DIV_2,ADS_INCLK_DIV_4,ADS_INCLK_DIV_6,ADS_INCLK_DIV_8,ADS_INCLK_DIV_10,ADS_INCLK_DIV_12,ADS_INCLK_DIV_14
  *  @return    已置位数据
  *  @note      none
  *  @Sample usage:     ADS131A04_ICLK_SET_PREDIV(INCLK_DIV_4)
 -------------------------------------------------------------*/
ADS_res ADS131A04_ICLK_SET_PREDIV(uint8_t pre_divider){
    uint8_t temp=0x00;
    uint32_t rev=ADS131A04_Write_Reg(WRITE_CMD|CLK1,temp|(pre_divider<<1));
    printf("\n\rICLK_SET_PREDIV接收到的回复：%lx\n\r",rev);
    return ADS_OK;
}
/*-------------------------------------------------------------
  *  @brief     设置ADC参考电压模式
  *  @param     ref_mode        0:采用2.442V    1:采用4V
  *             ref_source      0:采用外部参考电压      1:采用内部参考电压
  *  @return    已置位数据，将设好的与返回值相或
  *  @note      none
  *  @Sample usage:     0X60|ADS131A04_REF_SET(1,1)
 -------------------------------------------------------------*/
ADS_res ADS131A04_REF_SET(uint8_t ref_mode,uint8_t ref_source){
    uint8_t temp=0x00;
    switch (ref_mode) {
        case 0:
            temp=temp|0x00;
            break;
        case 1:
            temp=temp|0x10;
            break;
        default:return ADS_ERROR;
    }

    switch (ref_source) {
        case 0:
            temp=temp|0x00;
            break;
        case 1:
            temp=temp|0x08;
            break;
        default:return ADS_ERROR;
    }

    uint32_t rev=ADS131A04_Write_Reg(WRITE_CMD|A_SYS_CFG,0X60|temp);
    printf("\n\rREF_SET接收到的回复：%lx\n\r",rev);
    return ADS_OK;
}
/*-------------------------------------------------------------
  *  @brief     设置ADC对应增益
  *  @param     ch        通道
                ADS_ADC1
                ADS_ADC2
                ADS_ADC3
                ADS_ADC4
  *             gain        增益设置
                ADCX_GAIN_1
                ADCX_GAIN_2
                ADCX_GAIN_4
                ADCX_GAIN_8
                ADCX_GAIN_16
  *  @return    已置位数据，将设好的与返回值相或
  *  @note      none
  *  @Sample usage:     ADS131A04_Gain_SET(ADS_ADC1,ADCX_GAIN_1);
 -------------------------------------------------------------*/
ADS_res ADS131A04_Gain_SET(uint8_t ch,uint8_t gain){
    ADS131A04_Write_Reg(WRITE_CMD|ch,gain);
    return ADS_OK;
}

ADS_res
ADS131A04_Power_Up(void){
    uint32_t rev=0;
    rev=ADS131A04_Write_Command(RESET);//重置
    while(rev!=0xff040000){
        printf("\n\r上电重置接收到的回复：%lx\n\r",rev);
        rev=ADS131A04_Write_Command(RESET);//接收READY信号
    }
    printf("\n\r已接收到READY\n\r");
    rev=ADS131A04_Write_Command(UNLOCK);//解锁
    printf("\n\rUNLOCK接收到的回复：%lx\n\r",rev);
    ADS131A04_REF_SET(1,1);//设置参考电压
    rev=ADS131A04_Write_Reg(READ_CMD|A_SYS_CFG,0);
    printf("\n\rREAD：%lx\n\r",rev);
    ADS131A04_ICLK_SET_PREDIV(ADS_INCLK_DIV_2);//设置输入时钟预分频
    ADS131A04_MODULATION_SET_PREDIV(ADS_INCLK_DIV_2,ADS_OSR_DIV_400);//设置调制时钟预分频与过采样率预分频

    rev=ADS131A04_Gain_SET(ADS_ADC1,ADCX_GAIN_2);
    printf("\n\rREAD：%lx\n\r",rev);
    rev=ADS131A04_Gain_SET(ADS_ADC2,ADCX_GAIN_2);
    printf("\n\rREAD：%lx\n\r",rev);
    //10kHz采样率
    rev=ADS131A04_Write_Reg(WRITE_CMD|ADC_ENA,0X00|ADC_ALL_ENABLE);//开启使能
    printf("\n\r开启使能接收到的回复：%lx\n\r",rev);
    rev=ADS131A04_Write_Command(WAKEUP);//唤醒
    printf("\n\rWAKEUP接收到的回复：%lx\n\r",rev);



    return ADS_OK;
}


