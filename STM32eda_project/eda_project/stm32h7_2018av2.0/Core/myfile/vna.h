#ifndef VNA_H
#define VNA_H

#include "my_dsp.h"

typedef enum
{
	VNA_OK = 0,
	VNA_ERROR,
}VNA_res;

#include "vna_cal_para.h"  

#define VNA_AUTO_RECAL 1
#define VNA_CAL_ORDER2 1
#define VNA_SWEEP_N_MAX 300
#define VNA_TDR_FFT_N 1024

typedef struct
{
	float complex *data[CAL_ENTRIES];

	uint16_t n;  
	uint16_t status;  
}VNA_cal_def;

typedef struct
{
	float complex *s11;
	float complex *s21;

	uint16_t n;  
}VNA_data_def;

typedef struct
{
	uint16_t thru_enable;  
	uint16_t data_usermalloc;  
	
	DSP_cfft_obj fft;

	VNA_data_def data;
	VNA_cal_def cal;
	VNA_cal_def cal_order2;  
	uint16_t sweep_n_max;  

	uint16_t sweep_n;  

	float sweep_fl;
	float sweep_fh;

}VNA_def;


VNA_res VNA_enableDataUserMalloc();
VNA_res VNA_disableDataUserMalloc();

VNA_res VNA_enableThru();
VNA_res VNA_disableThru();

VNA_res VNA_setS11Buff(float complex *addr);
VNA_res VNA_setS21Buff(float complex *addr);

VNA_res VNA_init();

VNA_res VNA_setSweepN(uint16_t n);
VNA_res VNA_setSweepFreqL(float fl);
VNA_res VNA_setSweepFreqH(float fh);

float VNA_index2freq(uint16_t index);

VNA_res VNA_setCalToDefault();  
VNA_res VNA_setCalOpen(float complex *s11,uint16_t n);   
VNA_res VNA_setCalShort(float complex *s11,uint16_t n);  
VNA_res VNA_setCalLoad(float complex *s11,uint16_t n);   

VNA_res VNA_fillS11(float complex *s11,uint16_t n);		
float complex *VNA_getS11();  

VNA_res VNA_calData();		
VNA_res VNA_calData_order2();  

#define VNA_calData_lowFreq  VNA_calData_order2

VNA_res VNA_setCalOpen_lowFreq(float complex *s11,uint16_t n);   
VNA_res VNA_setCalShort_lowFreq(float complex *s11,uint16_t n);  
VNA_res VNA_setCalLoad_lowFreq(float complex *s11,uint16_t n);   

float VNA_TDR_index2time(uint16_t index);

uint16_t VNA_getTDR_n();  
float *VNA_getTDR_timedom();  

VNA_res VNA_TDR_getTime(float *time);

VNA_res VNA_getAvgZ(float complex *z);  
VNA_res VNA_getAvgZ_index(float complex *z,uint16_t l,uint16_t r);  


VNA_res VNA_getAvgR(float *R);
VNA_res VNA_getAvgR_index(float *R,uint16_t l,uint16_t r);


VNA_res VNA_getAvgC(float *c);
VNA_res VNA_getAvgC_index(float *c,uint16_t l,uint16_t r);


void VNA_printf_cal();  


#endif 
