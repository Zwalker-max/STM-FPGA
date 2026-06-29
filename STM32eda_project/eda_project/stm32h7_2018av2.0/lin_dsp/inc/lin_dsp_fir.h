#ifndef LIN_DSP_FIR_H
#define LIN_DSP_FIR_H


#include "lin_dsp_conf.h"
#include "lin_dsp_def.h"


#include "lin_dsp_math.h"


#include "lin_dsp_malloc.h"

#ifdef LIN_DSP_C2000
#include "fpu_filter.h"  
#endif 


typedef struct
{
    
    uint16_t order;         
    uint16_t init_coef_noload;  

    
    const float *coef_const;    
    float *coef_buff;            

    
#ifdef LIN_DSP_C2000
    FIR_f32 fir;
    FIR_f32_Handle hnd_fir;
    float *delay_buff;        
    float *input;             
    float *output;            
#endif 

#ifdef LIN_DSP_ARM
    arm_fir_instance_f32 fir;
    float *delay_buff;        
#endif 

}DSP_fir_obj;

DSP_res DSP_fir_setOrder(DSP_fir_obj *fir,uint16_t order);
DSP_res DSP_fir_setCoefConst(DSP_fir_obj *fir,const float *coef);
DSP_res DSP_fir_enableInitCoefLoad(DSP_fir_obj *fir);
DSP_res DSP_fir_disableInitCoefLoad(DSP_fir_obj *fir);

DSP_res DSP_fir_init(DSP_fir_obj *fir);
DSP_res DSP_fir_deinit(DSP_fir_obj *fir);

DSP_res DSP_fir_clearDelayLine(DSP_fir_obj *fir);
float DSP_fir_run_once(DSP_fir_obj *fir,float in);


#endif
