#ifndef LIN_DSP_WIN_H
#define LIN_DSP_WIN_H


#include "lin_dsp_conf.h"
#include "lin_dsp_def.h"


#include "lin_dsp_math.h"


#include "lin_dsp_malloc.h"


#include "lin_dsp_win_conf.h"

typedef enum  
{
    DSP_WIN_RECT = 0,
    DSP_WIN_HANN,
    DSP_WIN_KAISER_BETA6,
}DSP_win_type;


DSP_res DSP_win_gen(DSP_win_type win_type,uint16_t size,float **win_data);

DSP_res DSP_win_ram_gen(DSP_win_type win_type,uint16_t size);
DSP_res DSP_win_ram_free(void);


#endif
