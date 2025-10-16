#ifndef _FFT_CALCULATE_H
#define _FFT_CALCULATE_H

#include "stm32f10x.h"
#include "stm32_dsp.h"


#define NPT 1024

extern u32 InBufArray[NPT];
extern u32 OutBufArray[NPT/2];
extern u32 MagBufArray[NPT/2];


void FFT_Compute(void);
void GetPowerMag(void);

#endif
