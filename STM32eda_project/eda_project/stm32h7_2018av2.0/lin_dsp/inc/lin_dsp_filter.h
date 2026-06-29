#ifndef LIN_DSP_FILTER_H
#define LIN_DSP_FILTER_H


#include "lin_dsp_conf.h"
#include "lin_dsp_def.h"


#include "lin_dsp_math.h"


#include "lin_dsp_malloc.h"


#include "lin_dsp_fir.h"



typedef struct  
{
    uint16_t n;  

    void *filter_buff;  
    uint16_t data_size;  

    uint16_t i;  
    uint16_t run_n;  
}DSP_filter_ma_obj;

DSP_res DSP_filter_ma_init(DSP_filter_ma_obj *filter,uint16_t n,uint16_t data_size);
DSP_res DSP_filter_ma_deinit(DSP_filter_ma_obj *filter);
DSP_res DSP_filter_ma_clear(DSP_filter_ma_obj *filter);
float DSP_filter_ma_run_once_f32(DSP_filter_ma_obj *filter,float val);



typedef struct  
{
    uint16_t n;  

    void *filter_buff;  
    uint16_t data_size;  

    uint16_t *index_buff;  

    uint16_t i;  
    uint16_t run_n;  
}DSP_filter_mm_obj;

DSP_res DSP_filter_mm_init(DSP_filter_mm_obj *filter,uint16_t n,uint16_t data_size);
DSP_res DSP_filter_mm_deinit(DSP_filter_mm_obj *filter);
DSP_res DSP_filter_mm_clear(DSP_filter_mm_obj *filter);
float DSP_filter_mm_run_once_f32(DSP_filter_mm_obj *filter,float val);




typedef struct  
{
    uint16_t n;  

    DSP_fir_obj fir;  
}DSP_filter_gs_obj;

DSP_res DSP_filter_gs_init(DSP_filter_gs_obj *filter,uint16_t n);
DSP_res DSP_filter_gs_deinit(DSP_filter_gs_obj *filter);

DSP_res DSP_filter_gs_run_f32(DSP_filter_gs_obj *filter,float *in,uint16_t in_n,float *out);  


#endif  
