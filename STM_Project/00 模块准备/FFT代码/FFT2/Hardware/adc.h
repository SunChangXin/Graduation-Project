#ifndef _adc_H
#define _adc_H

#include "system.h"

#define ARR 10000-1
#define PSC 720-1
#define ADC_LEN    256

void ADC_Configuration(void);

void ADC1_Init(void);
void ADC1_DMA1_Init(void);
void TIM1_Init(void);

#endif
