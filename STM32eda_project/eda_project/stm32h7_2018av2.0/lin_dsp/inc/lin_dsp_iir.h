#ifndef LIN_DSP_IIR_H
#define LIN_DSP_IIR_H


#include "lin_dsp_conf.h"
#include "lin_dsp_def.h"


#include "lin_dsp_math.h"


#include "lin_dsp_malloc.h"

#ifdef LIN_DSP_C2000
#include "fpu_filter.h"  
#endif 


typedef struct
{
    
    uint16_t num_sos;           
    uint16_t init_coef_noload;  

    
    const float *sos_const;         
    const float *scale_const;       



    
#ifdef LIN_DSP_C2000
    IIR_f32 iir;
    IIR_f32_Handle hnd_iir;
    float *coefb_buff;         
    float *coefa_buff;         
    float *scale_buff;        
    float *delay_buff;        
#endif 

#ifdef LIN_DSP_ARM
    arm_biquad_cascade_df2T_instance_f32 iir;
    float *coef_buff;         
    float *delay_buff;        
#endif 

}DSP_iir_obj;

DSP_res DSP_iir_setNumSOS(DSP_iir_obj *iir,uint16_t num_sos);  
DSP_res DSP_iir_setSOSConst(DSP_iir_obj *iir,const float *sos_const);
DSP_res DSP_iir_setScaleConst(DSP_iir_obj *iir,const float *scale_const);
DSP_res DSP_iir_enableInitCoefLoad(DSP_iir_obj *iir);
DSP_res DSP_iir_disableInitCoefLoad(DSP_iir_obj *iir);

DSP_res DSP_iir_loadCoef(DSP_iir_obj *iir,uint16_t num_sos,const float *sos_const,const float *scale_const);  

DSP_res DSP_iir_init(DSP_iir_obj *iir);

DSP_res DSP_iir_clearDelayLine(DSP_iir_obj *iir);
float DSP_iir_run_once(DSP_iir_obj *iir,float in);
DSP_res DSP_iir_run(DSP_iir_obj *iir,uint16_t n,float *in,float *out);



float IIR_notch_H_mag_f32(float w,float w0,float r);
float IIR_notch_bw_func_r_f32(float r,void *parm);
DSP_res DSP_iir_notch_design_f32(float f0,float bw,float fs,float *w0,float *r);  
DSP_res DSP_iir_notch_genCoef_f32(DSP_iir_obj *iir,float w0,float r);  



#endif
