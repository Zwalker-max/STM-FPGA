#ifndef STM32H7_ORTH_DEMO_MODULE_PORT_H
#define STM32H7_ORTH_DEMO_MODULE_PORT_H

#define AD9959 1
#define ADS131A04 1


#include "stdlib.h"
#include "stdio.h"
#include "stdint.h"


#include "tim.h"
#include "usart.h"


#include "lvgl.h"
#include "ui_events.h"


#include "ui.h"


#include "my_dsp.h"
#include "vna.h"



#include "app.h"



#if AD9959

#include "ad9959.h"
#endif

#if ADS131A04
#include "ads_app.h"
#include "ads131a0x.h"
#endif










#endif 
