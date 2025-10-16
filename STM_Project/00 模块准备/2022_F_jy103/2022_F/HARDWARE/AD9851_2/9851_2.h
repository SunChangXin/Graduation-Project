#ifndef _AD98512_H_
#define _AD98512_H_
#include "stm32f10x_conf.h"

#define _M					*1000000
#define	_K					*1000
#define Multiplier_DISABLE	RESET
#define Multiplier_ENABLE	SET
#define	Power_Down			RESET
#define Power_On			SET

#define REST_0		GPIO_ResetBits(GPIOF,GPIO_Pin_15)   
#define REST_1		GPIO_SetBits(GPIOF,GPIO_Pin_15)

#define FQ_UP_0		GPIO_ResetBits(GPIOF,GPIO_Pin_14)
#define FQ_UP_1		GPIO_SetBits(GPIOF,GPIO_Pin_14)

#define W_CLK_0		GPIO_ResetBits(GPIOF,GPIO_Pin_12)
#define W_CLK_1		GPIO_SetBits(GPIOF,GPIO_Pin_12)

#define Data_0		GPIO_ResetBits(GPIOF,GPIO_Pin_13)
#define Data_1		GPIO_SetBits(GPIOF,GPIO_Pin_13)

void AD9851_Configuration2(void);
void Write2(u32 Freq,FlagStatus Power_Flag,u8 Cmd);

#endif

