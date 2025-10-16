#ifndef __ADC_FFT_H
#define __ADC_FFT_H

#include "stm32f10x.h" 

#define AD_FFT_Value_Length 256 //因为采样点数是256，故需要长度为256的数组

extern uint16_t AD_FFT_Value[AD_FFT_Value_Length];

void TIM2_Init(u16 arr,u16 psc);
void DMA1_Init(void);
void GPIO_init(void);
void AD_FFT_Init(void);
void FFT_test(void);
void FIR_test(void);

#endif
