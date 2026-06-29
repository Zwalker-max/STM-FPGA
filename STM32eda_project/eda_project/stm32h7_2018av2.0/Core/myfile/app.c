#include "app.h"


#define SWEEP_N 200
#define SWEEP_START_ROUGH   5e6
#define SWEEP_STOP_ROUGH    175e6


#define SWEEP_LOAD_N 200
#define SWEEP_LOAD_START  100e3
#define SWEEP_LOAD_STOP    100e3

#define F_MID 2500      



#define SA_N 64
#define CH_FC 0
#define CH_FL 1
#define SYNCADC_XCH1_FS_MAX 10000

uint16_t INDEX_N;
float c_light = 3e8;  
float k_cable = 0.6962f;  

extern int uart_ch;

typedef enum
{
    IDLE=1,
    START,
    SWEEP_ROUGH,
    SWEEP_SPEC,
    OUTPUT,

    START_LOAD,
    SWEEP_LOAD,
    OUTPUT_LOAD
}state_task;

static state_task my_sweep_task;
DSP_rfft_obj my_rfft_p;





static uint16_t sa_cnt_now=0;
static uint16_t sa_cnt_need=1;

static uint16_t sweep_cnt_now=0;
__IO static uint16_t sweep_cnt_need_rough=SWEEP_N;
static uint16_t sweep_cnt_need_spec=300;


static float f_t_a[5],p_t_a[5],a_t_a[5];
static float f_avg_a[5],p_avg_a[5],a_avg_a[5];
static float f_res_a[5],p_res_a[5],a_res_a[5];
static float complex z_avg_a[5];

static float f_t_b[5],p_t_b[5],a_t_b[5];
static float f_avg_b[5],p_avg_b[5],a_avg_b[5];
static float f_res_b[5],p_res_b[5],a_res_b[5];
static float complex z_avg_b[5];


static uint32_t sweep_start = SWEEP_START_ROUGH;
static uint32_t sweep_stop = SWEEP_STOP_ROUGH;



static float sweep_gain_f[SWEEP_N];
static float sweep_phase_f[SWEEP_N];
float complex gama_rspd[SWEEP_N];


static float length_res=0;
static uint16_t cap_cal_mode = 0;
__IO static float cap_last = 0;  

static float resistance_res=0;
static float capcity_res=0;

void set_k_cable(float k){
    printf("k=%f\n\r",k);
    k_cable=k;
}

void sweep_task(){
    static uint32_t sweep_now=0;
    switch (my_sweep_task) {
        case IDLE:{

            lv_task_handler();  

            if(get_ui_state() == UI_STATE_LOAD)  
            {
                cap_cal_mode = 0;
                sweep_now=0;
                char text_a[20]={0};
                sprintf(text_a,"正在检测");
                lv_label_set_text(ui_statevalue,text_a);
                my_sweep_task=START_LOAD;
            }
            else if( get_ui_state() != UI_STATE_IDLE)  
            {
                cap_cal_mode = 0;
                sweep_now=0;
                char text_a[20]={0};
                sprintf(text_a,"正在检测");
                lv_label_set_text(ui_statevalue,text_a);
                if(get_ui_state() == UI_STATE_TEST && get_correct_state())  
                    my_sweep_task=START_LOAD;
                else
                    my_sweep_task=START;
            }

        }break;
        case START:{

            sweep_start=SWEEP_START_ROUGH;
            sweep_stop=SWEEP_STOP_ROUGH;
            
            sweep_cnt_now=0;
            sa_cnt_now=0;
            sweep_now=sweep_start;

            
            VNA_setSweepN(SWEEP_N);  
            VNA_setSweepFreqL(SWEEP_START_ROUGH);     
            VNA_setSweepFreqH(SWEEP_STOP_ROUGH);     

            Init_AD9959();

            Write_frequence(CH_FC,sweep_now);
            Write_Amplitude(CH_FC,1023);
            Write_Phase(CH_FC,0);
            

            Write_frequence(CH_FL,F_MID+sweep_now);
            Write_Amplitude(CH_FL,1023);
            Write_Phase(CH_FL,0);
            

            DSP_rfft_multMeas_clear(1,f_avg_a,a_avg_a,p_avg_a,z_avg_a);
            DSP_rfft_multMeas_clear(1,f_avg_b,a_avg_b,p_avg_b,z_avg_b);
            


            my_sweep_task=SWEEP_ROUGH;

            printf("\r\n---------开始测量----------\r\n");
            lv_task_handler();  
            
            ADS_Start();


        }break;
        case SWEEP_ROUGH:{
            if(my_ads.ads_buff_half_int!=3){


                my_ads.ads_buff_half_int=3;

                
                ADS_rfft_fill(my_ads.ads_buff_ch1, my_rfft_p.in_buff,my_ads.n,my_rfft_p.size);
                DSP_rfft_run(&my_rfft_p);
                DSP_rfft_analyzeHarmonic_knowBase(&my_rfft_p, (float)F_MID, 1, f_t_a, a_t_a, p_t_a, NULL);  
                
                ADS_rfft_fill(my_ads.ads_buff_ch2, my_rfft_p.in_buff,my_ads.n,my_rfft_p.size);
                DSP_rfft_run(&my_rfft_p);
                DSP_rfft_analyzeHarmonic_knowBase(&my_rfft_p, (float)F_MID, 1, f_t_b, a_t_b, p_t_b, NULL);  


                
                p_t_b[0] -= p_t_a[0];  
                p_t_a[0]  = 0;

                DSP_rfft_multMeas_accum(1,f_t_a,a_t_a,p_t_a,f_avg_a,a_avg_a,p_avg_a,z_avg_a);
                DSP_rfft_multMeas_accum(1,f_t_b,a_t_b,p_t_b,f_avg_b,a_avg_b,p_avg_b,z_avg_b);


                if(++sa_cnt_now>=sa_cnt_need){
                    
                    float gain,phase;
                    float complex gama;
                    DSP_rfft_multMeas_getRes(sa_cnt_need, 1, f_avg_a, a_avg_a, p_avg_a, z_avg_a, f_res_a, a_res_a, p_res_a);
                    DSP_rfft_multMeas_getRes(sa_cnt_need, 1, f_avg_b, a_avg_b, p_avg_b, z_avg_b, f_res_b, a_res_b, p_res_b);

                    gain=a_res_b[0]/a_res_a[0];
                    phase=p_res_b[0];
                    gama = gain * cexp(-1.0*I * phase); 

                    sweep_gain_f[sweep_cnt_now]=gain;
                    sweep_phase_f[sweep_cnt_now]=DSP_RAD2DEG(phase);
                    gama_rspd[sweep_cnt_now] = gama; 
                   

                    if(++sweep_cnt_now<sweep_cnt_need_rough){

                        sa_cnt_now=0;
                        DSP_rfft_multMeas_clear(1,f_avg_a,a_avg_a,p_avg_a,z_avg_a);  
                        DSP_rfft_multMeas_clear(1,f_avg_b,a_avg_b,p_avg_b,z_avg_b);  


                        
                        sweep_now = VNA_index2freq(sweep_cnt_now);

                        
                        if( sweep_now < 155.0e6)
                            sa_cnt_need = 1;
                        else if(sweep_now < 175.0e6)
                            sa_cnt_need = 3;
                        else 
                            sa_cnt_need = 6;

                        

                        Write_frequence(CH_FC,sweep_now);
                        Write_Amplitude(CH_FC,1023);
                        Write_Phase(CH_FC,0);
                        

                        Write_frequence(CH_FL,F_MID+sweep_now);
                        Write_Amplitude(CH_FL,1023);
                        Write_Phase(CH_FL,0);

                        
                        my_sweep_task = SWEEP_ROUGH;
                        ADS_Start();

                    }else{
                        my_sweep_task=OUTPUT;

                        
                    }
                }else{
                    ADS_Start();
                }
            }
            

        }break;
        case OUTPUT:{

            printf("\r\n---------测量完毕----------\r\n");

            
            VNA_fillS11(&gama_rspd[0],SWEEP_N);

            VNA_calData();  

            float peak_t;
            VNA_TDR_getTime(&peak_t);
            float peak_x = peak_t*c_light*k_cable;

            length_res = peak_x;
            printf("\n\r计算长度:%f\n\r",length_res);
            char text[30]={0};
            sprintf(text,"%.1fcm",length_res*100+0.2);
            lv_label_set_text(ui_lengthvalue,text);
            memset(text,0,sizeof(text));
            sprintf(text,"结果保持");
            lv_label_set_text(ui_statevalue,text);
            set_load_type(UI_LOAD_NONE,0);  

            
            float *tdr_data = VNA_getTDR_timedom();
            uint16_t tdr_data_n = VNA_getTDR_n()/2;

            
            uint16_t tdr_max_index;
            float tdr_max = DSP_find_max_f32(tdr_data,tdr_data_n,&tdr_max_index);
            for(int i=0;i<tdr_data_n;i++)
                tdr_data[i] /= tdr_max;

            if(tdr_max_index<128)
                tdr_max_index = 128;

            if( (int)(tdr_max_index*1.5) < tdr_data_n)
                tdr_data_n = (int)(tdr_max_index*1.5);  

            const uint16_t tdr_draw_n = 256;   
            float tdr_new_tmax = VNA_TDR_index2time(tdr_data_n);
            float *tdr_draw_data = malloc(tdr_draw_n*sizeof(*tdr_draw_data));
            if(tdr_draw_data==NULL)
            {
                lin_printf("MALLOC ERROR\r\n");
                while(1);
            }

            for(int i=0;i<tdr_draw_n;i++)
                tdr_draw_data[i] = DSP_src_run_once(tdr_data,tdr_data_n,tdr_data_n,(float)i/(float)tdr_draw_n);


            float complex *s11_draw = VNA_getS11();

            draw_tdr(tdr_draw_data,tdr_draw_n,tdr_new_tmax);
            draw_smith(SWEEP_N,s11_draw);
            draw_spec(SWEEP_N,SWEEP_START_ROUGH,SWEEP_STOP_ROUGH,s11_draw);
            check_tdr();



            free(tdr_draw_data);

            lv_obj_clear_state(btn_test,LV_STATE_CHECKED);
            lv_obj_clear_state(ui_Button1,LV_STATE_CHECKED);

            
            Write_frequence(CH_FC,SWEEP_START_ROUGH);
            Write_Amplitude(CH_FC,1023);
            Write_Phase(CH_FC,0);
            
            Write_frequence(CH_FL,F_MID+SWEEP_START_ROUGH);
            Write_Amplitude(CH_FL,1023);
            Write_Phase(CH_FL,0);

            
            lv_task_handler();
            lv_task_handler();
            lv_task_handler();
            lv_task_handler();
            lv_task_handler();

            if(get_ui_state() == UI_STATE_LENGTH)  
            {
                set_ui_state(UI_STATE_IDLE);
                my_sweep_task = START_LOAD;
                cap_cal_mode = 1;
            }
            else
            {
                set_ui_state(UI_STATE_IDLE);
                my_sweep_task = IDLE;
                cap_cal_mode = 0;
            }

        }break;
            
        case START_LOAD:{

            sweep_start = SWEEP_LOAD_START;
            sweep_stop = SWEEP_LOAD_STOP;
            
            sweep_cnt_now=0;
            sa_cnt_now=0;
            sweep_now=sweep_start;

            
            VNA_setSweepN(SWEEP_LOAD_N);  
            VNA_setSweepFreqL(SWEEP_LOAD_START);     
            VNA_setSweepFreqH(SWEEP_LOAD_STOP);     

            Init_AD9959();

            Write_frequence(CH_FC,sweep_now);
            Write_Amplitude(CH_FC,1023);
            Write_Phase(CH_FC,0);
            

            Write_frequence(CH_FL,F_MID+sweep_now);
            Write_Amplitude(CH_FL,1023);
            Write_Phase(CH_FL,0);
            

            DSP_rfft_multMeas_clear(1,f_avg_a,a_avg_a,p_avg_a,z_avg_a);
            DSP_rfft_multMeas_clear(1,f_avg_b,a_avg_b,p_avg_b,z_avg_b);
            
            my_sweep_task = SWEEP_LOAD;

            printf("\r\n---------开始测量----------\r\n");
            lv_task_handler();  
            ADS_Start();


        }break;
        case SWEEP_LOAD:{
            if(my_ads.ads_buff_half_int!=3){
                my_ads.ads_buff_half_int=3;

                
                ADS_rfft_fill(my_ads.ads_buff_ch1, my_rfft_p.in_buff,my_ads.n,my_rfft_p.size);
                DSP_rfft_run(&my_rfft_p);
                DSP_rfft_analyzeHarmonic_knowBase(&my_rfft_p, (float)F_MID, 1, f_t_a, a_t_a, p_t_a, NULL);  
                
                ADS_rfft_fill(my_ads.ads_buff_ch2, my_rfft_p.in_buff,my_ads.n,my_rfft_p.size);
                DSP_rfft_run(&my_rfft_p);
                DSP_rfft_analyzeHarmonic_knowBase(&my_rfft_p, (float)F_MID, 1, f_t_b, a_t_b, p_t_b, NULL);  

                
                p_t_b[0] -= p_t_a[0];  
                p_t_a[0]  = 0;

                DSP_rfft_multMeas_accum(1,f_t_a,a_t_a,p_t_a,f_avg_a,a_avg_a,p_avg_a,z_avg_a);
                DSP_rfft_multMeas_accum(1,f_t_b,a_t_b,p_t_b,f_avg_b,a_avg_b,p_avg_b,z_avg_b);


                if(++sa_cnt_now>=sa_cnt_need){
                    
                    float gain,phase;
                    float complex gama;
                    DSP_rfft_multMeas_getRes(sa_cnt_need, 1, f_avg_a, a_avg_a, p_avg_a, z_avg_a, f_res_a, a_res_a, p_res_a);
                    DSP_rfft_multMeas_getRes(sa_cnt_need, 1, f_avg_b, a_avg_b, p_avg_b, z_avg_b, f_res_b, a_res_b, p_res_b);

                    gain=a_res_b[0]/a_res_a[0];
                    phase=p_res_b[0];
                    gama = gain * cexp(-1.0*I * phase); 

                    sweep_gain_f[sweep_cnt_now]=gain;
                    sweep_phase_f[sweep_cnt_now]=DSP_RAD2DEG(phase);
                    gama_rspd[sweep_cnt_now] = gama; 
                   

                    if(++sweep_cnt_now<sweep_cnt_need_rough){

                        sa_cnt_now=0;
                        DSP_rfft_multMeas_clear(1,f_avg_a,a_avg_a,p_avg_a,z_avg_a);  
                        DSP_rfft_multMeas_clear(1,f_avg_b,a_avg_b,p_avg_b,z_avg_b);  

                        
                        sweep_now = VNA_index2freq(sweep_cnt_now);

                        
                        if( sweep_now < 155.0e6)
                            sa_cnt_need = 1;
                        else if(sweep_now < 175.0e6)
                            sa_cnt_need = 3;
                        else 
                            sa_cnt_need = 6;

                        
                        Write_frequence(CH_FC,sweep_now);
                        Write_Amplitude(CH_FC,1023);
                        Write_Phase(CH_FC,0);
                        

                        Write_frequence(CH_FL,F_MID+sweep_now);
                        Write_Amplitude(CH_FL,1023);
                        Write_Phase(CH_FL,0);

                        
                        my_sweep_task = SWEEP_LOAD;
                        ADS_Start();

                    }else{
                        my_sweep_task = OUTPUT_LOAD;
                    }

                }else{
                    ADS_Start();
                }
            }
            

        }break;
        case OUTPUT_LOAD:{

            printf("\r\n---------负载测量完毕----------\r\n");
            if(cap_cal_mode)
            {
                cap_cal_mode = 0;

                VNA_fillS11(&gama_rspd[0],SWEEP_LOAD_N);
                VNA_calData_lowFreq();  

                
                float C_load;
                VNA_getAvgC(&C_load);

                
                cap_last = C_load;

                lin_printf("电容补偿值:%f pF",cap_last*1e12);
                printf("电容补偿值:%f pF",cap_last*1e12);
            }
            else if( (get_ui_state()==UI_STATE_LOAD) || (get_ui_state() == UI_STATE_TEST) )
            {
                VNA_fillS11(&gama_rspd[0],SWEEP_LOAD_N);
                VNA_calData_lowFreq();  

                float complex Z_load;
                float R_load,C_load;
                
                VNA_getAvgR(&R_load);
                VNA_getAvgC(&C_load);

                printf("平均电阻:%f 欧姆\r\n",R_load);
                printf("平均串联电容:%f pF\r\n",C_load*1e12);


                const float R_per_m = 0.153f ;
                

                resistance_res = R_load - R_per_m*length_res;
                
                capcity_res = C_load - cap_last;

                if(resistance_res < 0)
                    resistance_res = 0;

                printf("补偿导线长度后电阻:%f 欧姆\r\n",resistance_res);
                printf("补偿导线长度后电容:%f pF\r\n",capcity_res*1e12);
                
                float f_cneter = (SWEEP_LOAD_START + SWEEP_LOAD_STOP)/2.0f;
                Z_load = resistance_res + 1/(I*2*PI_F32*f_cneter*capcity_res);
                lin_printf("补偿后阻抗 %e + j*%e \r\n",creal(Z_load),cimag(Z_load));
                printf("补偿后阻抗 %e + j*%e \r\n",creal(Z_load),cimag(Z_load));
                if(cabs(Z_load) > 500e3)  
                {
                    set_load_type(UI_LOAD_OPEN,0);
                }
                else
                {
                    if( cimag(Z_load) > 100 ) 
                    {
                        
                        float l_res = cimag(Z_load)/(2*PI_F32*f_cneter);
                        set_load_type(UI_LOAD_L,l_res*1e6);  

                    }
                    else if( cimag(Z_load) < -100 )  
                    {
                        
                        set_load_type(UI_LOAD_CAP,capcity_res*1e12);  

                    }
                    else
                    {
                        
                        set_load_type(UI_LOAD_RES,resistance_res);  
                    }
                }
                

                char text[30]={0};
                memset(text,0,sizeof(text));
                sprintf(text,"结果保持");
                lv_obj_clear_state(ui_Button1,LV_STATE_CHECKED);
                lv_obj_clear_state(ui_Button2,LV_STATE_CHECKED);
                lv_obj_clear_state(btn_test,LV_STATE_CHECKED);
                lv_label_set_text(ui_statevalue,text);
                lv_task_handler();

                
                lv_chart_hide_series(ui_Chart3,ui_Chart3_tdr,1);
                lv_chart_hide_series(ui_Chart3,ui_Chart3_mag,1);
                lv_chart_hide_series(ui_Chart3,ui_Chart3_phase,1);

                float complex *s11_draw = VNA_getS11();
                draw_smith(SWEEP_LOAD_N,s11_draw);
                

            }
            else
            {
                printf("他怎么到这里来的？\r\n");
                while(1);
            }
            
            Write_frequence(CH_FC,SWEEP_START_ROUGH);
            Write_Amplitude(CH_FC,1023);
            Write_Phase(CH_FC,0);
            
            Write_frequence(CH_FL,F_MID+SWEEP_START_ROUGH);
            Write_Amplitude(CH_FL,1023);
            Write_Phase(CH_FL,0);

            
            set_ui_state(UI_STATE_IDLE);
            my_sweep_task = IDLE;

        }break;
        default:{
            printf("\n\rmy sweep statement error!\n\r");
            break;
        }
    }
}


void app_dsp_init(void)
{
    my_sweep_task=IDLE;

    HAL_NVIC_DisableIRQ(EXTI15_10_IRQn);     
    HAL_TIM_PWM_Start(&htim4,TIM_CHANNEL_1);

    
    VNA_disableDataUserMalloc();
    VNA_disableThru();
    
    if (VNA_init() != VNA_OK)
    {
        printf("######\r\n寄!\r\n######\r\n");
        lin_printf("######\r\n寄!\r\n######\r\n");
        while(1)
        {

        }
    }
    VNA_setSweepN(SWEEP_N);  
    VNA_setSweepFreqL(SWEEP_START_ROUGH);     
    VNA_setSweepFreqH(SWEEP_STOP_ROUGH);     

    

    DSP_rfft_setSize(&my_rfft_p, SA_N);
    DSP_rfft_setFsMax(&my_rfft_p, SYNCADC_XCH1_FS_MAX);
    DSP_rfft_setFs(&my_rfft_p,SYNCADC_XCH1_FS_MAX);
    DSP_rfft_enableMagBuff(&my_rfft_p);
    DSP_rfft_disablePhaseBuff(&my_rfft_p); 
    DSP_rfft_disableDTFT(&my_rfft_p);      
    DSP_rfft_init(&my_rfft_p);

    
    ADS_Set_n(SA_N);
    ADS_Set_CH_Enable(0b0011);
    ADS131A04_Init();  

    
    Init_AD9959();

}

void app_vna_setCalOpen();
void app_vna_setCalShort();
void app_vna_setCalLoad();

void app_vna_setCalOpen()
{
    if(get_correct_state())
    {
        VNA_setCalOpen_lowFreq(&gama_rspd[0],SWEEP_LOAD_N);  
    }
    else
    {
        VNA_setCalOpen(&gama_rspd[0],SWEEP_N);
    }
}

void app_vna_setCalShort()
{
    if(get_correct_state())
    {
        VNA_setCalShort_lowFreq(&gama_rspd[0],SWEEP_LOAD_N);  
    }
    else
    {
        VNA_setCalShort(&gama_rspd[0],SWEEP_N);
        printf("高频短路校准 完成\r\n");
    }
}

void app_vna_setCalLoad()
{
    if(get_correct_state())
    {
        VNA_setCalLoad_lowFreq(&gama_rspd[0],SWEEP_LOAD_N);  
    }
    else
    {
        VNA_setCalLoad(&gama_rspd[0],SWEEP_N);
    }
}