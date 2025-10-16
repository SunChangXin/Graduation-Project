#ifndef __ADCDMA_H__
#define __ADCDMA_H__

#include "stm32f4xx.h"  

#define AD3_Value_Length 256 //因为采样点数是256，故需要长度为256的数组

extern uint16_t AD3_Value[AD3_Value_Length];

void AD3_Init();
void ADC_DMA_Trigger();

#endif
