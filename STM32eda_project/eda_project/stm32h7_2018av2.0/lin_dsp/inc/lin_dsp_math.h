#ifndef LIN_DSP_MATH_H
#define LIN_DSP_MATH_H


#include "lin_dsp_conf.h"
#include "lin_dsp_def.h"


#include <stdio.h>
#include <math.h>
#include <float.h>
#include <complex.h>


#ifdef LIN_DSP_C2000
#include "dsp.h"  
#include "fpu_vector.h"  
#endif 

#ifdef LIN_DSP_ARM
#include "arm_math.h"  
#include "arm_const_structs.h"
#endif 



#ifndef M_PI
	#define M_PI (3.14159265358979323846)
#endif

#define PI_F32 ((float)M_PI)
#define PI_F64 ((double)M_PI)

#define EPS_F32 (FLT_EPSILON)
#define EPS_F64 (DBL_EPSILON)



#define __DSP_ANGLE_STD(x) do{\
                while((x) > PI_F32)(x) -= 2*PI_F32;\
                while((x) < -PI_F32)(x) += 2*PI_F32;\
            }while(0)


#define __DSP_LIMIT(v,d,u) do{\
                if(v>u)v=u;\
                else if(v<d)v=d;\
             }while(0U)


#define DSP_SIGN(x) ( (x)>0?1:((x)<0?-1:0) )  

#define DSP_MAX(a,b) ((a)>(b)?(a):(b))  
#define DSP_MIN(a,b) ((a)<(b)?(a):(b))  

#define DSP_RAD2DEG(x) ( sizeof(x)==sizeof(double) ? ((x)/PI_F64*180.0) : ((x)/PI_F32*180.0f) )
#define DSP_DEG2RAD(x) ( sizeof(x)==sizeof(double) ? ((x)*PI_F64/180.0) : ((x)*PI_F32/180.0f) )

float DSP_cangle_f32(float complex x);  

float DSP_find_max_f32(float *data,uint16_t n,uint16_t *index);  
float DSP_find_min_f32(float *data,uint16_t n,uint16_t *index);  

float DSP_sum_f32(float *in,uint16_t n);  

DSP_res DSP_diff_f32(float *in,uint16_t in_n,float *out);  


float DSP_db_f32(float x);  

uint32_t DSP_log2_u32(uint32_t x);  
uint32_t DSP_pow_u32(uint32_t base, uint16_t exp);  

uint16_t DSP_isPow2_u32(uint32_t size);  

DSP_res DSP_fzero_f32(uint16_t iter_max,float epsilon,float (*func)(float,void*),void* func_parm,float x_min,float x_max,float *x_solve);
DSP_res DSP_fzero_f64(uint16_t iter_max,double epsilon,double (*func)(double,void*),void* func_parm,double x_min,double x_max,double *x_solve);



DSP_res DSP_fmin_f64(uint16_t iter_max,double epsilon,double (*func)(double,void*),void* func_parm,double x_min,double x_max,double *x_res,double *func_res);

DSP_res DSP_fmax_f64(uint16_t iter_max,double epsilon,double (*func)(double,void*),void* func_parm,double x_min,double x_max,double *x_res,double *func_res);

float DSP_sum_hp_f32(float *input,uint16_t size);

void DSP_sort_f32(float *data,uint16_t size);  
void DSP_sort_index_f32(float *data,uint16_t *index,uint16_t size);  



#ifdef LIN_DSP_C2000

#ifndef __TMS320C28XX_TMU__
    #error "Please enable the TMU!"
#endif  
#define DSP_sin_f32(x)  __sin(x)
#define DSP_cos_f32(x)  __cos(x)
#define DSP_atan2_f32(y,x)  __atan2(y,x)
#define DSP_sqrt_f32(x)  __sqrt(x)
#endif  

#ifdef LIN_DSP_ARM
#define DSP_sin_f32(x)  arm_sin_f32(x)
#define DSP_cos_f32(x)  arm_cos_f32(x)

#define DSP_atan2_f32(y,x)  atan2f(y,x)  
#define DSP_sqrt_f32(x)  sqrtf(x)  
#endif  



void DSP_memcpy_fast(void* dst, const void* src, uint16_t N);

void DSP_offset_f32(float *pSrc, float offset, float *pDst, uint16_t blockSize);  
void DSP_add_f32(float *pSrcA, float *pSrcB, float *pDst, uint16_t blockSize);  
void DSP_sub_f32(float *pSrcA, float *pSrcB, float *pDst, uint16_t blockSize);  
void DSP_scale_f32(float *pSrc, float scale, float *pDst, uint16_t blockSize);  
void DSP_mult_f32(float *pSrcA, float *pSrcB, float *pDst, uint16_t blockSize);  




#endif  
