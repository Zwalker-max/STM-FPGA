#ifndef STM32H7_ORTH_DEMO_APP_H
#define STM32H7_ORTH_DEMO_APP_H

#include "module_port.h"
void app_dsp_init(void);
void sweep_task(void);

extern float c_light;
extern float k_cable;



void app_vna_setCalOpen();
void app_vna_setCalShort();
void app_vna_setCalLoad();
void set_k_cable(float k);

#endif 
