//
// Created by 24016 on 2023/7/29.
//
//#include "main.h"
#include "ads_app.h"
#include "ads131a0x.h"
#include <stdint.h>
#include <stdlib.h>
#include "stdio.h"
#include "tim.h"
//#include "dac.h"
#include "my_dsp.h"

static float y=0;
const float k=0.5;
ADS_obj my_ads;
ADS_state my_ads_state=ADS_Init_WAIT;

//uint32_t filter[2400];
int32_t buf1[1024];
int32_t buf2[1024];


/*-------------------------应用层函数-------------------------*/

//#define MY_IIR_NUM_SOS 4
//float const MY_IIR_SOS_CONST[MY_IIR_NUM_SOS*6]={1.000000000000000e+00,2.000000000000000e+00,1.000000000000000e+00,1.000000000000000e+00,1.860028624534607e+00,-9.128817319869995e-01,1.000000000000000e+00,2.000000000000000e+00,1.000000000000000e+00,1.000000000000000e+00,1.721472859382629e+00,-7.703889012336731e-01,1.000000000000000e+00,2.000000000000000e+00,1.000000000000000e+00,1.000000000000000e+00,1.628620266914368e+00,-6.748977899551392e-01,1.000000000000000e+00,2.000000000000000e+00,1.000000000000000e+00,1.000000000000000e+00,1.582427620887756e+00,-6.273925900459290e-01};
//float const MY_IIR_SCALE_CONST[MY_IIR_NUM_SOS]={1.321326848119497e-02,1.222899649292231e-02,1.156939007341862e-02,1.156939007341862e-02};
//static DSP_iir_obj my_iir;

ADS_res ADS_Fill_Data(int32_t *data){
    if(my_ads.ads_ch_en&0x1){
        my_ads.ads_buff_ch1[my_ads.ads_index]=*(data+1);
    }
    if(my_ads.ads_ch_en&0x2){
        my_ads.ads_buff_ch2[my_ads.ads_index]=*(data+2);
    }
    if(my_ads.ads_ch_en&0x4){
        my_ads.ads_buff_ch3[my_ads.ads_index]=*(data+3);
    }
    if(my_ads.ads_ch_en&0x8){
        my_ads.ads_buff_ch4[my_ads.ads_index]=*(data+4);
    }
//    y=k*(float)(my_ads.ads_buff_ch1[my_ads.ads_index])+(1-k)*y;
//    filter[my_ads.ads_index]=(uint32_t)((y+531585)/250.0);
//    y = DSP_iir_run_once(&my_iir,(float)my_ads.ads_buff_ch1[my_ads.ads_index]);
//    filter[my_ads.ads_index]=(uint32_t)((y+531585)/250.0);
    my_ads.ads_index++;
    if(my_ads.ads_index==my_ads.n){
#if ADS_PP_ENALE==0
        my_ads.ads_index=0;
        my_ads.ads_buff_half_int=0;
        ADS_Stop();
//        ADS_FullPP_Callback();
    }
#else
        my_ads.ads_buff_half_int=1;
    }
    else if(my_ads.ads_index==my_ads.n*2){
        my_ads.ads_buff_half_int=0;
        my_ads.ads_index=0;
    }
#endif
    return ADS_OK;
}

ADS_res ADS_Start(){
    HAL_NVIC_EnableIRQ(EXTI15_10_IRQn);
    my_ads_state=ADS_START;
    return ADS_OK;
}
ADS_res ADS_Stop(){
    HAL_NVIC_DisableIRQ(EXTI15_10_IRQn);
    my_ads_state=ADS_Init_OK;
    return ADS_OK;
}
void ADS_rfft_fill(int32_t * ori , float * res,uint16_t ori_n,uint16_t fft_n)
{
    int32_t max = 0;
    int32_t min = 65535.0;
    for (uint16_t i = 0; i < ori_n; i++)
    {
        if (ori[i] > max)
            max = ori[i];
        else if (ori[i] < min)
            min = ori[i];
    }
    uint16_t dc = (max + min) / 2;

    for (uint32_t i = 0; i < fft_n; i++)
    {
        res[i] = (float)ori[i] - (float)dc;
    }
}
/*-------------------------初始化函数-------------------------*/
ADS_res ADS_Set_n(uint16_t n){
    my_ads.n=n;
    return ADS_OK;
}
ADS_res ADS_Set_CH_Enable(uint8_t ch){

    if(ch&0x1){
#if ADS_PP_ENALE
        my_ads.ads_buff_ch1=malloc((my_ads.n)*2 * sizeof(int32_t));//开辟空间
#else
//        free(my_ads.ads_buff_ch1);
//        my_ads.ads_buff_ch1=malloc((my_ads.n) * sizeof(int32_t));//开辟空间
        my_ads.ads_buff_ch1 = &buf1[0];
#endif
    }
    if(ch&0x2){
#if ADS_PP_ENALE
        my_ads.ads_buff_ch2=malloc((my_ads.n)*2 * sizeof(int32_t));//开辟空间
#else
//        free(my_ads.ads_buff_ch2);
//        my_ads.ads_buff_ch2=malloc((my_ads.n) * sizeof(int32_t));//开辟空间
        my_ads.ads_buff_ch2 = &buf2[0];
#endif
    }
    if(ch&0x4){
#if ADS_PP_ENALE
        my_ads.ads_buff_ch3=malloc((my_ads.n)*2 * sizeof(int32_t));//开辟空间
#else
        free(my_ads.ads_buff_ch3);
        my_ads.ads_buff_ch3=malloc((my_ads.n) * sizeof(int32_t));//开辟空间
#endif
    }
    if(ch&0x8){
#if ADS_PP_ENALE
        my_ads.ads_buff_ch3=malloc((my_ads.n)*2 * sizeof(uint32_t));//开辟空间
#else
        free(my_ads.ads_buff_ch4);
        my_ads.ads_buff_ch4=malloc((my_ads.n) * sizeof(uint32_t));//开辟空间
#endif
    }
    if(ch<=15){
        my_ads.ads_ch_en=ch;
        return ADS_OK;
    }
    else
        return ADS_ERROR;

}
ADS_res ADS131A04_Init(void){
    if(ADS131A04_Power_Up()==ADS_OK)
        my_ads_state=ADS_Init_OK;
//    ADS_Set_n(1200);
    my_ads.ads_index=0;
    my_ads.ads_buff_half_int=3;
//    ADS_Set_CH_Enable(0b0011);//使能通道并且为之分配内存

    return ADS_OK;
}


/*-------------------------中断回调-------------------------*/

void HAL_GPIO_EXTI_Callback(uint16_t GPIO_Pin){
    if(GPIO_Pin==GPIO_PIN_11){
        if(my_ads_state==ADS_START||my_ads_state==ADS_Init_OK){
            int32_t send_Data[5]={ADS_NULL,0,0,0,0};
            int32_t rev_Data[5]={0,0,0,0,0};
            HAL_SPI_TransmitReceive(&hspi2,send_Data,rev_Data,5,300);
            rev_Data[1]=rev_Data[1]>>8;
            rev_Data[2]=rev_Data[2]>>8;

//            printf("%ld\n\r",rev_Data[1]);
            ADS_Fill_Data(rev_Data);
        }
        else
            printf("/n/rADS131A04:INIT NOT FINISHED!/n/r");
    }
    else
        printf("/n/rADS131A04:GPIO INTTERRUPT ERROR!/n/r");
}



//int32_t adc_test_data[]={0,4095,0,4095};

void ADS_HalfPP_Callback(){
    my_ads.ads_buff_half_int=3;
    static uint8_t cnt=0;

    if(cnt==0) {
//        HAL_DAC_Start_DMA(&hdac1, DAC1_CHANNEL_2, filter, 2400, DAC_ALIGN_12B_R);
        cnt++;
    }


}

void ADS_FullPP_Callback(){
    my_ads.ads_buff_half_int=3;
    ADS_Stop();
}


