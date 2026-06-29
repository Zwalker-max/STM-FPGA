#ifndef LIN_DSP_RDTFT_H
#define LIN_DSP_RDTFT_H


#include "lin_dsp_conf.h"
#include "lin_dsp_def.h"


#include "lin_dsp_math.h"


#include "lin_dsp_malloc.h"




DSP_res DSP_rdtft_run(float *x,uint16_t size,float w,float complex *output);


DSP_res DSP_rdtft_getPeak(float *x,uint16_t size,float f0,float fs,float *freq,float *mag,float *phase);



#endif  
