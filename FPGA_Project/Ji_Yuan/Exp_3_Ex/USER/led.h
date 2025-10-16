#ifndef __LED_H
#define __LED_H

#include "stm32f4xx.h"

extern uint8_t led_flow_flag;

void LED_Hardware_Init(void);
void LED_Flow(void);

#endif
