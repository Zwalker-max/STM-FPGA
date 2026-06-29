#include "vna.h"
#include "vna_cal_fun.h"
#include "module_port.h"

VNA_def my_vna;

static void cal_reset(int calType, float complex val);

VNA_res VNA_init()
{
	my_vna.sweep_n_max = VNA_SWEEP_N_MAX;

    
	if(my_vna.data_usermalloc == 0)  
	{
		my_vna.data.s11 = malloc((my_vna.sweep_n_max) * sizeof(*my_vna.data.s11));
		if(my_vna.thru_enable)
			my_vna.data.s21 = malloc((my_vna.sweep_n_max) * sizeof(*my_vna.data.s21));

		
		if((my_vna.data.s11 == NULL) || (my_vna.data.s21 == NULL && my_vna.thru_enable))
			return VNA_ERROR;
	}
	
	
	for(uint8_t i=0;i<CAL_ENTRIES;i++)
	{
		my_vna.cal.data[i] = malloc((my_vna.sweep_n_max) * sizeof(*my_vna.cal.data[i]));
		if(my_vna.cal.data[i] == NULL)
			return VNA_ERROR;
	}

#ifdef VNA_CAL_ORDER2
	
	my_vna.cal_order2.data[CAL_OPEN] = malloc((my_vna.sweep_n_max) * sizeof(*my_vna.cal_order2.data[CAL_OPEN]));
	if(my_vna.cal_order2.data[CAL_OPEN] == NULL)
		return VNA_ERROR;

	my_vna.cal_order2.data[CAL_SHORT] = malloc((my_vna.sweep_n_max) * sizeof(*my_vna.cal_order2.data[CAL_SHORT]));
	if(my_vna.cal_order2.data[CAL_SHORT] == NULL)
		return VNA_ERROR;

	my_vna.cal_order2.data[CAL_LOAD] = malloc((my_vna.sweep_n_max) * sizeof(*my_vna.cal_order2.data[CAL_LOAD]));
	if(my_vna.cal_order2.data[CAL_LOAD] == NULL)
		return VNA_ERROR;

	
	for(int i=0; i<my_vna.sweep_n_max; i++)
	{
		my_vna.cal_order2.data[CAL_OPEN][i]  =  1.0f;
		my_vna.cal_order2.data[CAL_SHORT][i] = -1.0f;
		my_vna.cal_order2.data[CAL_LOAD][i] = 0.0f;
	}
#endif  

    
	memset(&my_vna.fft, 0, sizeof(my_vna.fft));
	DSP_cfft_setSize(&my_vna.fft,VNA_TDR_FFT_N);
	DSP_cfft_setFs(&my_vna.fft,2.0f);  
	DSP_cfft_enableMagBuff(&my_vna.fft);
	if(DSP_cfft_init(&my_vna.fft) != DSP_OK)  
		return VNA_ERROR;

    VNA_setCalToDefault();  

	return VNA_OK;
}

VNA_res VNA_enableDataUserMalloc()
{
	my_vna.data_usermalloc = 1;
	return VNA_OK;
}
VNA_res VNA_disableDataUserMalloc()
{
	my_vna.data_usermalloc = 0;
	return VNA_OK;
}

VNA_res VNA_enableThru()
{
	my_vna.thru_enable = 1;
	return VNA_OK;
}
VNA_res VNA_disableThru()
{
	my_vna.thru_enable = 0;
	return VNA_OK;
}

VNA_res VNA_setSweepN(uint16_t n)
{
	if(n > my_vna.sweep_n_max)
		return VNA_ERROR;

	my_vna.sweep_n = n;
	my_vna.cal.n = my_vna.sweep_n;
	my_vna.data.n = my_vna.sweep_n;

	return VNA_OK;
}

VNA_res VNA_setS11Buff(float complex *addr)
{
	if(addr == NULL)
		return VNA_ERROR;

	my_vna.data.s11 = addr;
	return VNA_OK;
}

VNA_res VNA_setS21Buff(float complex *addr)
{
	if(addr == NULL)
		return VNA_ERROR;

	my_vna.data.s21 = addr;
	return VNA_OK;
}


VNA_res VNA_setSweepFreqL(float fl)
{
	if(fl <= 0)
		return VNA_ERROR;

	my_vna.sweep_fl = fl;
	return VNA_OK;
}

VNA_res VNA_setSweepFreqH(float fh)
{
	if(fh <= 0)
		return VNA_ERROR;

	my_vna.sweep_fh = fh;
	return VNA_OK;
}

float VNA_index2freq(uint16_t index)
{
	return my_vna.sweep_fl + (float)index * (my_vna.sweep_fh - my_vna.sweep_fl)/(my_vna.sweep_n - 1);
}

VNA_res VNA_setCalToDefault()
{
#ifdef VNA_AUTO_RECAL
	for(int i=0; i<my_vna.sweep_n_max; i++)  
	{
		my_vna.cal.data[CAL_OPEN][i]  = s11_open_real[i]  + I*s11_open_imag[i];
		my_vna.cal.data[CAL_SHORT][i] = s11_short_real[i] + I*s11_short_imag[i];
		my_vna.cal.data[CAL_LOAD][i]  = s11_load_real[i]  + I*s11_load_imag[i];
	}
#else
	cal_reset(CAL_OPEN, 1.0f);
	cal_reset(CAL_SHORT, -1.0f);
	cal_reset(CAL_LOAD, 0.0f);
#endif

	return VNA_OK;
}


VNA_res VNA_setCalOpen(float complex *s11,uint16_t n)   
{
	if(n != my_vna.sweep_n)
		return VNA_ERROR;

	for(int i=0;i<my_vna.sweep_n;i++)
		my_vna.cal.data[CAL_OPEN][i] = s11[i];
	return VNA_OK;
}
VNA_res VNA_setCalShort(float complex *s11,uint16_t n)  
{
	if(n != my_vna.sweep_n)
		return VNA_ERROR;

	for(int i=0;i<my_vna.sweep_n;i++)
		my_vna.cal.data[CAL_SHORT][i] = s11[i];

	return VNA_OK;
}
VNA_res VNA_setCalLoad(float complex *s11,uint16_t n)   
{
	if(n != my_vna.sweep_n)
		return VNA_ERROR;

	for(int i=0;i<my_vna.sweep_n;i++)
		my_vna.cal.data[CAL_LOAD][i] = s11[i];
	return VNA_OK;
}


VNA_res VNA_fillS11(float complex *s11,uint16_t n)
{
	if(n != my_vna.sweep_n)
		return VNA_ERROR;
	
	for(int i=0;i<n;i++)
		my_vna.data.s11[i] = s11[i];
}

float complex *VNA_getS11()
{
	return &my_vna.data.s11[0];
}

VNA_res VNA_calData()
{
	
	
	if(my_vna.data.n != my_vna.cal.n)
		return VNA_ERROR;

	if(my_vna.sweep_n != my_vna.data.n)
		return VNA_ERROR;

	for(uint16_t freqIndex=0;freqIndex<my_vna.sweep_n;freqIndex++)
	{
		float complex refl = my_vna.data.s11[freqIndex];
		float complex newRefl = __CP_REFL(
			my_vna.cal.data[CAL_SHORT][freqIndex],
			my_vna.cal.data[CAL_OPEN][freqIndex],
			my_vna.cal.data[CAL_LOAD][freqIndex],
			refl);
		refl = newRefl;
		my_vna.data.s11[freqIndex] = refl;
	}

	return VNA_OK;
}

static void phase_unwarp(float *x,uint16_t n,float *y);

static void phase_unwarp(float *x,uint16_t n,float *y)
{
	const float K = 0.6f;
	float phase_shift = 0;

	y[0] = x[0];

	float x_last=x[0];  
	for(int i=1;i<n;i++)  
	{
		if( x[i]-x_last > 2*PI_F32*K)
			phase_shift = phase_shift - 2*PI_F32;
		else if( x[i]-x_last < -2*PI_F32*K)
			phase_shift = phase_shift + 2*PI_F32;
		
		x_last = x[i];
		y[i] = x[i] + phase_shift;
	}
}


VNA_res VNA_calData_order2()
{
	for(uint16_t freqIndex=0;freqIndex<my_vna.sweep_n;freqIndex++)
	{
		
		float complex refl = my_vna.data.s11[freqIndex];
		float complex newRefl = __CP_REFL(
			my_vna.cal_order2.data[CAL_SHORT][freqIndex],
			my_vna.cal_order2.data[CAL_OPEN][freqIndex],
			my_vna.cal_order2.data[CAL_LOAD][freqIndex],
			refl);
		refl = newRefl;
		my_vna.data.s11[freqIndex] = refl;
	}

	return VNA_OK;
}


VNA_res VNA_setCalOpen_lowFreq(float complex *s11,uint16_t n)   
{
	if(n != my_vna.sweep_n)
		return VNA_ERROR;

	for(int i=0;i<my_vna.sweep_n;i++)
		my_vna.cal_order2.data[CAL_OPEN][i] = s11[i];
	return VNA_OK;
}
VNA_res VNA_setCalShort_lowFreq(float complex *s11,uint16_t n)  
{
	if(n != my_vna.sweep_n)
		return VNA_ERROR;

	for(int i=0;i<my_vna.sweep_n;i++)
		my_vna.cal_order2.data[CAL_SHORT][i] = s11[i];

	return VNA_OK;
}
VNA_res VNA_setCalLoad_lowFreq(float complex *s11,uint16_t n)   
{
	if(n != my_vna.sweep_n)
		return VNA_ERROR;

	for(int i=0;i<my_vna.sweep_n;i++)
		my_vna.cal_order2.data[CAL_LOAD][i] = s11[i];
	return VNA_OK;
}


float VNA_TDR_index2time(uint16_t index)
{
    double range = (double)my_vna.sweep_n / ( 2*((double)my_vna.sweep_fh - (double)my_vna.sweep_fl) ) ;
	return (double)range / (double)my_vna.fft.size * (double)index;
}
uint16_t VNA_getTDR_n()
{
	return my_vna.fft.size;
}

float *VNA_getTDR_timedom()  
{
	return &my_vna.fft.mag_buff[0];
}

VNA_res VNA_TDR_getTime(float *time)
{
	uint16_t fft_size = my_vna.fft.size;

    if(fft_size != VNA_TDR_FFT_N)
        return DSP_ERROR;  
    if(my_vna.sweep_n > fft_size)
        return DSP_ERROR;  

	float *win_ptr;
	DSP_win_gen(DSP_WIN_KAISER_BETA6,my_vna.sweep_n,&win_ptr);  

    for(int i=0;i<fft_size;i++)
    {
    	if(i<my_vna.sweep_n)
    	{
			my_vna.fft.in_buff[2*i    ] =  crealf(my_vna.data.s11[i]) * win_ptr[i] ;  
			my_vna.fft.in_buff[2*i + 1] = -cimagf(my_vna.data.s11[i]) * win_ptr[i] ;  
    	}
    	else
    	{
    		my_vna.fft.in_buff[2*i    ] = 0;
			my_vna.fft.in_buff[2*i + 1] = 0;
    	}
		
    }

	DSP_cfft_run(&my_vna.fft);  
	DSP_cfft_calcMag(&my_vna.fft);  

	uint16_t k=0;
	DSP_find_max_f32(&my_vna.fft.mag_buff[0],fft_size*3/4,&k);
	if(k<1)
		return VNA_ERROR;  
	else
	{
        double x1,y1,x2,y2,x3,y3;
        double t_res;
		x1=VNA_TDR_index2time(k-1); y1=my_vna.fft.mag_buff[k-1];
		x2=VNA_TDR_index2time(k  ); y2=my_vna.fft.mag_buff[k  ];
		x3=VNA_TDR_index2time(k+1); y3=my_vna.fft.mag_buff[k+1];
		t_res = -((x1*y2 + x3*y2)/((x1 - x2)*(x2 - x3)) - (x2*y1 + x3*y1)/((x1 - x2)*(x1 - x3)) - (x1*y3 + x2*y3)/((x1 - x3)*(x2 - x3)))/(2*(y1/((x1 - x2)*(x1 - x3)) - y2/((x1 - x2)*(x2 - x3)) + y3/((x1 - x3)*(x2 - x3))));
		if(time != NULL)
		{
			*time = t_res;
			return VNA_OK;
		}
		else
			return VNA_ERROR;
	}

	return VNA_ERROR;  
}

VNA_res VNA_getAvgZ(float complex *z);  
VNA_res VNA_getAvgZ_index(float complex *z,uint16_t l,uint16_t r);  


VNA_res VNA_getAvgR(float *R);
VNA_res VNA_getAvgR_index(float *R,uint16_t l,uint16_t r);


VNA_res VNA_getAvgC(float *c);
VNA_res VNA_getAvgC_index(float *c,uint16_t l,uint16_t r);


VNA_res VNA_getAvgZ(float complex *z)
{
	return VNA_getAvgZ_index(z,0,my_vna.sweep_n-1);
}


VNA_res VNA_getAvgZ_index(float complex *z,uint16_t l,uint16_t r)
{

	if(l>my_vna.sweep_n-1)
		return VNA_ERROR;
	if(r>my_vna.sweep_n-1)
		return VNA_ERROR;
	if(l>r)
		return VNA_ERROR;

	
	const float Z0 = 50;  
	float complex z_sum = 0;
	float complex gama = 0;
	int cnt=0;
	for(int i=l ; i<r  ; i++)
	{
		gama = my_vna.data.s11[i];
		z_sum += (1+gama)/(1-gama)*Z0;
		cnt++;
	}

	*z = z_sum / (float)cnt;
	return VNA_OK;
}


VNA_res VNA_getAvgR(float *R)
{
	return VNA_getAvgR_index(R,0,my_vna.sweep_n-1);
}


VNA_res VNA_getAvgR_index(float *R,uint16_t l,uint16_t r)
{
	float complex ZL = 0;

	if(VNA_getAvgZ_index(&ZL,l,r)!=VNA_OK)
		return VNA_ERROR;

	*R = crealf(ZL);

	return VNA_OK;
}


VNA_res VNA_getAvgC(float *c)
{
	return VNA_getAvgC_index(c,0,my_vna.sweep_n-1);
}

VNA_res VNA_getAvgC_index(float *c,uint16_t l,uint16_t r)
{

	if(l>my_vna.sweep_n-1)
		return VNA_ERROR;
	if(r>my_vna.sweep_n-1)
		return VNA_ERROR;
	if(l>r)
		return VNA_ERROR;

	
	const float Z0 = 50;  
	float complex ZL = 0;  
	float f = 0;  
	float complex gama = 0;  

	float c_temp = 0;
	float c_sum = 0;
	
	int cnt=0;
	for(int i=l ; i<r  ; i++)
	{
		f = VNA_index2freq(i);
		gama = my_vna.data.s11[i];
		ZL = (1+gama)/(1-gama)*Z0;
		
        c_temp = -1/(2*PI_F32*f*cimagf(ZL));
		c_sum += c_temp;
		cnt++;
	}

	*c = c_sum / (float)cnt;
	return VNA_OK;
}

static void cal_reset(int calType, float complex val)
{
	float complex *arr = &my_vna.cal.data[calType][0];
	for(int i=0; i<my_vna.sweep_n_max; i++)
		arr[i] = val;
}

void VNA_printf_cal()
{
    printf("-----low freq-----\r\n");
    printf("open,real:\r\n");
    for(int i=0; i<my_vna.sweep_n; i++)
    {
        printf("%e,",crealf(my_vna.cal_order2.data[CAL_OPEN][i]));
    }
    printf("\r\n\r\n");
	printf("open,imag:\r\n");
	for(int i=0; i<my_vna.sweep_n; i++)
	{
		printf("%e,",cimagf(my_vna.cal_order2.data[CAL_OPEN][i]));
	}
	printf("\r\n\r\n");

    printf("short,real:\r\n");
    for(int i=0; i<my_vna.sweep_n; i++)
    {
        printf("%e,",crealf(my_vna.cal_order2.data[CAL_SHORT][i]));
    }
    printf("\r\n\r\n");
	printf("short,imag:\r\n");
	for(int i=0; i<my_vna.sweep_n; i++)
	{
		printf("%e,",cimagf(my_vna.cal_order2.data[CAL_SHORT][i]));
	}
	printf("\r\n\r\n");

    printf("load,real:\r\n");
    for(int i=0; i<my_vna.sweep_n; i++)
    {
        printf("%e,",crealf(my_vna.cal_order2.data[CAL_LOAD][i]));
    }
    printf("\r\n\r\n");
	printf("load,imag:\r\n");
	for(int i=0; i<my_vna.sweep_n; i++)
	{
		printf("%e,",cimagf(my_vna.cal_order2.data[CAL_LOAD][i]));
	}
	printf("\r\n\r\n");

    printf("-----high freq-----\r\n");
    printf("open,real:\r\n");
    for(int i=0; i<my_vna.sweep_n; i++)
    {
        printf("%e,",crealf(my_vna.cal.data[CAL_OPEN][i]));
    }
    printf("\r\n\r\n");
	printf("open,imag:\r\n");
	for(int i=0; i<my_vna.sweep_n; i++)
	{
		printf("%e,",cimagf(my_vna.cal.data[CAL_OPEN][i]));
	}
	printf("\r\n\r\n");

    printf("short,real:\r\n");
    for(int i=0; i<my_vna.sweep_n; i++)
    {
        printf("%e,",crealf(my_vna.cal.data[CAL_SHORT][i]));
    }
    printf("\r\n\r\n");
	printf("short,imag:\r\n");
	for(int i=0; i<my_vna.sweep_n; i++)
	{
		printf("%e,",cimagf(my_vna.cal.data[CAL_SHORT][i]));
	}
	printf("\r\n\r\n");

    printf("load,real:\r\n");
    for(int i=0; i<my_vna.sweep_n; i++)
    {
        printf("%e,",crealf(my_vna.cal.data[CAL_LOAD][i]));
    }
    printf("\r\n\r\n");
	printf("load,imag:\r\n");
	for(int i=0; i<my_vna.sweep_n; i++)
	{
		printf("%e,",cimagf(my_vna.cal.data[CAL_LOAD][i]));
	}
	printf("\r\n\r\n");

}