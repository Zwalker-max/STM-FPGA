#ifndef LIN_DSP_APP_H
#define LIN_DSP_APP_H


#include "lin_dsp_conf.h"
#include "lin_dsp_def.h"


#include "lin_dsp_math.h"


#include "lin_dsp_malloc.h"


#include "lin_dsp_fir.h"


typedef struct
{
    
    uint32_t p_cnt;  
    uint32_t p_inc;  
    

    
    float *i_lut;  

    
    uint16_t addr_rshift;  

    
    uint16_t lut_addr_width;  
    uint16_t lut_n;         

    uint16_t lut_userdef;  

    
    float fs;
    float f;

}DSP_nco_obj;


DSP_res DSP_nco_lut_enableUserDef(DSP_nco_obj *nco);
DSP_res DSP_nco_lut_disableUserDef(DSP_nco_obj *nco);
DSP_res DSP_nco_lut_setN(DSP_nco_obj *nco,uint16_t n);
uint16_t DSP_nco_lut_getN(DSP_nco_obj *nco);


DSP_res DSP_nco_init(DSP_nco_obj *nco);


DSP_res DSP_nco_setFs(DSP_nco_obj *nco,float fs);  
float DSP_nco_getFs(DSP_nco_obj *nco);

DSP_res DSP_nco_reset(DSP_nco_obj *nco);  


DSP_res DSP_nco_setFreq(DSP_nco_obj *nco,float f);  
float DSP_nco_getFreq(DSP_nco_obj *nco);
DSP_res DSP_nco_setPhaseInc(DSP_nco_obj *nco,uint32_t p_inc);  
uint32_t DSP_nco_getPhaseInc(DSP_nco_obj *nco);








DSP_res DSP_nco_run(DSP_nco_obj *nco,float *i_out,float *q_out,uint16_t n);
DSP_res DSP_nco_run_i(DSP_nco_obj *nco,float *i_out,uint16_t n);
DSP_res DSP_nco_run_q(DSP_nco_obj *nco,float *q_out,uint16_t n);

DSP_res DSP_nco_run_once(DSP_nco_obj *nco,float *i_out,float *q_out);
float DSP_nco_run_i_once(DSP_nco_obj *nco);
float DSP_nco_run_q_once(DSP_nco_obj *nco);



typedef struct
{

	
    
	

    
    DSP_fir_obj lpf_real,lpf_imag;  

    
    float fs;  
    float fc;  

    
    
    
    DSP_nco_obj nco;  
    void *nco_para;  

    void (*nco_reset_func)(void*);  

    
    
    
    
    
    void (*nco_iq_func)(void*,float*,float*);


    


    
    uint32_t in_index_acc;  
    uint32_t out_index_acc;

}DSP_ddc_obj;


DSP_res DSP_ddc_lpf_setOrder(DSP_ddc_obj *ddc,uint16_t order);
DSP_res DSP_ddc_lpf_setCoefConst(DSP_ddc_obj *ddc,const float *coef);
DSP_res DSP_ddc_nco_lut_setN(DSP_ddc_obj *ddc,uint16_t n);


DSP_res DSP_ddc_init(DSP_ddc_obj *ddc);


DSP_res DSP_ddc_setFs(DSP_ddc_obj *ddc,float fs);  
DSP_res DSP_ddc_setFc(DSP_ddc_obj *ddc,float f);  

DSP_res DSP_ddc_resetAll(DSP_ddc_obj *ddc);
DSP_res DSP_ddc_lpf_reset(DSP_ddc_obj *ddc);
DSP_res DSP_ddc_nco_reset(DSP_ddc_obj *ddc);
DSP_res DSP_ddc_in_index_reset(DSP_ddc_obj *ddc);
DSP_res DSP_ddc_out_index_reset(DSP_ddc_obj *ddc);


DSP_res DSP_ddc_run_offline(DSP_ddc_obj *ddc,float *in,uint16_t n_in,float *out_real,float *out_imag,uint16_t k_out_dsa,uint16_t n_out_drop);
DSP_res DSP_ddc_run_online(DSP_ddc_obj *ddc,float *in,uint16_t n_in,float *out_real,float *out_imag,uint16_t k_out_dsa);
DSP_res DSP_ddc_run_once_online(DSP_ddc_obj *ddc,float in,float *out_real,float *out_imag,uint16_t k_out_dsa);




#endif  
