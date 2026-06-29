
#ifndef LIN_DSP_CONF_H
#define LIN_DSP_CONF_H





#define LIN_DSP_ARM

#ifdef MY_DSP_C2000
#define LIN_DSP_C2000
#endif

#ifdef MY_DSP_ARM
#define LIN_DSP_ARM
#endif

#if !( defined(LIN_DSP_C2000) || defined(LIN_DSP_ARM) )
    #error "DSP_LIB:Please select a platform!"
#endif

#endif
