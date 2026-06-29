//
// Created by 24016 on 2023/7/29.
//

#ifndef STM32H7_ORTH_DEMO_ADS_APP_H
#define STM32H7_ORTH_DEMO_ADS_APP_H

#include "stdint.h"
#include "ads131a0x.h"

#define ADS_PP_ENALE 0
#define ADS_TRANS(x)  ((2*x)/16777216-1)*3.9935

typedef enum {
    ADS_Init_WAIT=1,
    ADS_Init_OK,
    ADS_START
}ADS_state;

typedef struct
{
    uint32_t n;  //采集总点数
    uint32_t ads_index;
    uint8_t ads_ch_en;
    //0b0001,0b0011,0b0010...位置x置1代表CH开

    int32_t *ads_buff_ch1;  //ads采集数组
    int32_t *ads_buff_ch2;  //ads采集数组
    int32_t *ads_buff_ch3;  //ads采集数组
    int32_t *ads_buff_ch4;  //ads采集数组

#ifdef ADS_PP_ENALE
    uint8_t ads_buff_half_int;  //乒乓模式 buff半满中断标志
#endif

}ADS_obj;

extern ADS_obj      my_ads;
extern ADS_state    my_ads_state;

ADS_res ADS_Stop();
ADS_res ADS_Start();
ADS_res ADS_Set_n(uint16_t n);
ADS_res ADS_Set_CH_Enable(uint8_t ch);

ADS_res ADS131A04_Init(void);
void ADS_HalfPP_Callback();
void ADS_FullPP_Callback();
void ADS_rfft_fill(int32_t * ori , float * res,uint16_t ori_n,uint16_t fft_n);

#endif //STM32H7_ORTH_DEMO_ADS_APP_H
