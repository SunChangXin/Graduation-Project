#ifndef _AD9851_H_
#define _AD9851_H_
#include "stm32f10x_conf.h"

#define _M					*1000000
#define	_K					*1000
#define Multiplier_DISABLE	RESET
#define Multiplier_ENABLE	SET
#define	Power_Down			RESET
#define Power_On			SET

#define REST_0		GPIO_ResetBits(GPIOE,GPIO_Pin_1)   
#define REST_1		GPIO_SetBits(GPIOE,GPIO_Pin_1)

#define FQ_UP_0		GPIO_ResetBits(GPIOE,GPIO_Pin_2)
#define FQ_UP_1		GPIO_SetBits(GPIOE,GPIO_Pin_2)

#define W_CLK_0		GPIO_ResetBits(GPIOE,GPIO_Pin_6)
#define W_CLK_1		GPIO_SetBits(GPIOE,GPIO_Pin_6)

#define Data_0		GPIO_ResetBits(GPIOE,GPIO_Pin_0)
#define Data_1		GPIO_SetBits(GPIOE,GPIO_Pin_0)
void RCC_Configuration(void);
void AD9851_Configuration(void);
void Write(u32 Freq,FlagStatus Power_Flag,u8 Cmd);

#endif

