
#ifndef LIN_DSP_MALLOC_H
#define LIN_DSP_MALLOC_H


#include "lin_dsp_conf.h"
#include "lin_dsp_def.h"


#include <stdlib.h>
#include <string.h>

#define DSP_malloc(_size)            malloc(_size)
#define DSP_realloc(_ptr,_size)      realloc(_ptr,_size)
#define DSP_free(_ptr)               free(_ptr)

#define DSP_mem_reset(x)             memset(&(x), 0, sizeof(x))

#ifdef LIN_DSP_C2000
#define DSP_memalign(_aln,_size)     memalign(_aln,_size)
#endif  

#ifdef LIN_DSP_ARM

#ifdef __TI_COMPILER_VERSION__

#define DSP_memalign(_aln,_size)     memalign(_aln,_size)
#endif  

#endif  

#endif
