#ifndef _adc_H
#define _adc_H

#include "system.h"

#define ARR 300 - 1
#define PSC 24 - 1 
#define ADC_LEN    256

// ADC采样频率 fs = 72M /（（ARR+1）（PSC+1）

void ADC_Configuration(void);

void ADC1_Init(void);
void ADC1_DMA1_Init(void);
void TIM1_Init(void);

#endif
