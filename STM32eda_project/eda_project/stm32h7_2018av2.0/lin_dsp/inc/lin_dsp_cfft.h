#ifndef LIN_DSP_CFFT_H
#define LIN_DSP_CFFT_H


#include "lin_dsp_conf.h"
#include "lin_dsp_def.h"


#include "lin_dsp_math.h"


#include "lin_dsp_malloc.h"


#include "lin_dsp_win.h"


#ifdef LIN_DSP_C2000
#include "fpu_cfft.h"  
#endif 


typedef struct
{
    
    uint16_t stages;         
    uint16_t size;           
    float fs;               
    uint16_t mag_buff_used;       
    uint16_t phase_buff_used;       

    
    float *in_buff;             
    float *out_buff;            
    float *mag_buff;            
    float *phase_buff;          

    
#ifdef LIN_DSP_C2000
    
    
    float *calc_buff;           
    float *coef_buff;           
    CFFT_F32_STRUCT cfft;                    
    CFFT_F32_STRUCT_Handle hnd_cfft;         
#endif 

#ifdef LIN_DSP_ARM
    
    const arm_cfft_instance_f32 *hnd_cfft;         
#endif 

    
    uint16_t mag_done;              
    uint16_t phase_done;            
    DSP_win_type input_win_type;    
    DSP_win_type output_win_type;   


}DSP_cfft_obj;

DSP_res DSP_cfft_setSize(DSP_cfft_obj *fft,uint16_t size);
DSP_res DSP_cfft_setFs(DSP_cfft_obj *fft,float freq);
DSP_res DSP_cfft_enableMagBuff(DSP_cfft_obj *fft);
DSP_res DSP_cfft_disableMagBuff(DSP_cfft_obj *fft);

DSP_res DSP_cfft_init(DSP_cfft_obj *fft);
DSP_res DSP_cfft_deinit(DSP_cfft_obj *fft);
DSP_res DSP_cfft_win(DSP_cfft_obj *fft,DSP_win_type win_type);
DSP_res DSP_cfft_run(DSP_cfft_obj *fft);
DSP_res DSP_cfft_calcMag(DSP_cfft_obj *fft);

DSP_res DSP_cfft_clearxFFT(DSP_cfft_obj *fft);
DSP_res DSP_cfft_setxFFT(DSP_cfft_obj *fft,int16_t i,float complex z);
float complex DSP_cfft_getXFFT(DSP_cfft_obj *fft,int16_t i);
float DSP_cfft_getReXFFT(DSP_cfft_obj *fft,int16_t i);
float DSP_cfft_getImXFFT(DSP_cfft_obj *fft,int16_t i);
DSP_res DSP_cfft_setxFFT_cs(DSP_cfft_obj *fft,uint16_t i,float r,float th);

DSP_res DSP_cfft_getMax(DSP_cfft_obj *fft,int16_t l,int16_t r,int16_t *res);  
DSP_res DSP_cfft_getPeak(DSP_cfft_obj *fft,int16_t l,int16_t r,float *freq,float *mag,float *phase);  




#endif
