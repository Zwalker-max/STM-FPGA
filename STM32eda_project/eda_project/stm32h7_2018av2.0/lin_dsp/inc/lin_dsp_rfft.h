#ifndef LIN_DSP_RFFT_H
#define LIN_DSP_RFFT_H


#include "lin_dsp_conf.h"
#include "lin_dsp_def.h"


#include "lin_dsp_math.h"


#include "lin_dsp_malloc.h"


#include "lin_dsp_win.h"


#include "lin_dsp_rdtft.h"

#ifdef LIN_DSP_C2000
#include "fpu_rfft.h"  
#endif 


typedef struct
{
    
    uint16_t stages;         
    uint16_t size;           
    float fs;               
    uint16_t mag_buff_used;       
    uint16_t phase_buff_used;       
    uint16_t dtft_used;             

    
    float *in_buff;             
    float *out_buff;            
    float *mag_buff;            
    float *phase_buff;          

    
#ifdef LIN_DSP_C2000
    
    float *coef_buff;           
    RFFT_F32_STRUCT rfft;                    
    RFFT_F32_STRUCT_Handle hnd_rfft;         
#endif 

#ifdef LIN_DSP_ARM
    
    arm_rfft_fast_instance_f32 rfft;         
#endif 

    
    uint16_t mag_done;              
    uint16_t phase_done;            
    DSP_win_type input_win_type;    
    DSP_win_type output_win_type;   

    
    float fs_max;           
}DSP_rfft_obj;

DSP_res DSP_rfft_setSize(DSP_rfft_obj *fft,uint16_t size);
DSP_res DSP_rfft_setFsMax(DSP_rfft_obj *fft,float freq);
DSP_res DSP_rfft_setFs(DSP_rfft_obj *fft,float freq);
DSP_res DSP_rfft_enableMagBuff(DSP_rfft_obj *fft);
DSP_res DSP_rfft_disableMagBuff(DSP_rfft_obj *fft);
DSP_res DSP_rfft_enablePhaseBuff(DSP_rfft_obj *fft);
DSP_res DSP_rfft_disablePhaseBuff(DSP_rfft_obj *fft);
DSP_res DSP_rfft_enableDTFT(DSP_rfft_obj *fft);
DSP_res DSP_rfft_disableDTFT(DSP_rfft_obj *fft);

DSP_res DSP_rfft_init(DSP_rfft_obj *fft);
DSP_res DSP_rfft_deinit(DSP_rfft_obj *fft);
DSP_res DSP_rfft_win(DSP_rfft_obj *fft,DSP_win_type win_type);
DSP_res DSP_rfft_run(DSP_rfft_obj *fft);
DSP_res DSP_rfft_calcMag(DSP_rfft_obj *fft);
DSP_res DSP_rfft_calcPhase(DSP_rfft_obj *fft);

DSP_res DSP_rfft_clearxFFT(DSP_rfft_obj *fft);  
float complex DSP_rfft_getXFFT(DSP_rfft_obj *fft,uint16_t i);  

float DSP_rfft_index2freq(DSP_rfft_obj *fft,float index);  
float DSP_rfft_freq2index(DSP_rfft_obj *fft,float f);  

DSP_res DSP_rfft_getMax(DSP_rfft_obj *fft,uint16_t l,uint16_t r,uint16_t *res);  
DSP_res DSP_rfft_getPeak(DSP_rfft_obj *fft,uint16_t l,uint16_t r,float *freq,float *mag,float *phase);  
DSP_res DSP_rfft_getPeak_cntnsDC(DSP_rfft_obj *fft,uint16_t l,uint16_t r,float *freq,float *mag,float *phase);  
DSP_res DSP_rfft_getPeak_DTFT(DSP_rfft_obj *fft,uint16_t l,uint16_t r,float *freq,float *mag,float *phase);  
DSP_res DSP_rfft_getBase_DTFT(DSP_rfft_obj *fft,uint16_t l,uint16_t r,float *freq,float *mag,float *phase);
DSP_res DSP_rfft_analyzeHarmonic(DSP_rfft_obj *fft,uint16_t h_max,float *f_res,float *a_res,float *p_res,float *rms);  
DSP_res DSP_rfft_analyzeHarmonic_maxBase(DSP_rfft_obj *fft,uint16_t h_max,float *f_res,float *a_res,float *p_res,float *rms);  
DSP_res DSP_rfft_analyzeHarmonic_knowBase(DSP_rfft_obj *fft,float f_base,uint16_t h_max,float *f_res,float *a_res,float *p_res,float *rms);  

DSP_res DSP_rfft_getPower(DSP_rfft_obj *fft,uint16_t l,uint16_t r,float *power);  
DSP_res DSP_rfft_getPowerMainInterval(DSP_rfft_obj *fft,float th,uint16_t *l,uint16_t *r);  
DSP_res DSP_rfft_getPowerMainInterval_cntnsDC(DSP_rfft_obj *fft,float th,uint16_t *l,uint16_t *r);  




float DSP_rfft_getAntiAliasFs(uint16_t h_max,float f0,uint16_t m);

float DSP_rfft_calcFs_auto(DSP_rfft_obj *fft,uint16_t h_max,float f0,uint16_t anti_alias_num);



DSP_res DSP_rfft_f0tofm(float f0,float fs,float *fm,float *km,float *bm);


uint16_t DSP_rfft_multMeas_calcCnt(float fs,uint16_t n,float process_time,float sa_time_max);

DSP_res DSP_rfft_multMeas_clear(uint16_t h_max,float *f_avg,float *a_avg,float *p_avg,float complex *z_avg);

DSP_res DSP_rfft_multMeas_unifyPhase(uint16_t h_max,float *p,float p0);

DSP_res DSP_rfft_multMeas_accum(uint16_t h_max,float *f,float *a,float *p,float *f_avg,float *a_avg,float *p_avg,float complex *z_avg);

DSP_res DSP_rfft_multMeas_getRes(uint16_t cnt,uint16_t h_max,float *f_avg,float *a_avg,float *p_avg,float complex *z_avg,float *f_res,float *a_res,float *p_res);


DSP_res DSP_rfft_rebuildHarmonic(uint16_t h_max,float *a,float *p,uint16_t wav_size,float *wav_data);



#endif
