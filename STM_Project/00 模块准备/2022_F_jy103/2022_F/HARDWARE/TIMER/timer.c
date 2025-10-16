#include "timer.h"
#include "usart.h"

//通用定时器1中断初始化
//这里时钟选择为APB1的2倍，而APB1为36M
//arr：自动重装值。
//psc：时钟预分频数

//定时器二输入捕获测量占空比 PA1
u8 Edge_Flag;  
u16 Rising,Falling,Rising_Last; 

void TIM1_Int_Init(u16 arr,u16 psc)
{
	TIM_TimeBaseInitTypeDef   TIM_TimeBaseStructure;
	TIM_OCInitTypeDef         TIM_OCInitStructure;
	
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_TIM1, ENABLE);
	
	/* Time Base configuration */
	TIM_TimeBaseStructInit(&TIM_TimeBaseStructure); 
	TIM_TimeBaseStructure.TIM_Period = arr;          
	TIM_TimeBaseStructure.TIM_Prescaler = psc;       
	TIM_TimeBaseStructure.TIM_ClockDivision = TIM_CKD_DIV1;    
	TIM_TimeBaseStructure.TIM_CounterMode = TIM_CounterMode_Up;  
	TIM_TimeBaseInit(TIM1, &TIM_TimeBaseStructure);
	
	/* TIM1 channel1 configuration in PWM mode */
	TIM_OCInitStructure.TIM_OCMode = TIM_OCMode_PWM1; 
	TIM_OCInitStructure.TIM_OutputState = TIM_OutputState_Enable;                
	TIM_OCInitStructure.TIM_Pulse = arr; 
	TIM_OCInitStructure.TIM_OCPolarity = TIM_OCPolarity_Low;         
	TIM_OC1Init(TIM1, &TIM_OCInitStructure);
	
	TIM_CtrlPWMOutputs(TIM1, ENABLE);
	TIM_Cmd(TIM1, ENABLE);
}



void TIM2_Cap_Init()
{
	GPIO_InitTypeDef GPIO_InitStruct;   
	TIM_TimeBaseInitTypeDef TIM_InitStruct;
	TIM_ICInitTypeDef TIM_ICInitStruct;
	NVIC_InitTypeDef NVIC_InitStruct;
	
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA,ENABLE);
	RCC_APB1PeriphClockCmd(RCC_APB1Periph_TIM2,ENABLE);
	
	GPIO_InitStruct.GPIO_Pin=GPIO_Pin_1;
	GPIO_InitStruct.GPIO_Mode=GPIO_Mode_IN_FLOATING;   
	GPIO_InitStruct.GPIO_Speed=GPIO_Speed_50MHz;
	GPIO_Init(GPIOA,&GPIO_InitStruct);
	
	TIM_InitStruct.TIM_ClockDivision=TIM_CKD_DIV1;
	TIM_InitStruct.TIM_CounterMode=TIM_CounterMode_Up; 
	TIM_InitStruct.TIM_Period=0xffff;
	TIM_InitStruct.TIM_Prescaler=36-1;                
	TIM_TimeBaseInit(TIM2,&TIM_InitStruct);
	
	TIM_ICInitStruct.TIM_Channel=TIM_Channel_2;
	TIM_ICInitStruct.TIM_ICFilter=0x00;         
	TIM_ICInitStruct.TIM_ICPolarity=TIM_ICPolarity_Rising;    
	TIM_ICInitStruct.TIM_ICPrescaler=TIM_ICPSC_DIV1;
	TIM_ICInitStruct.TIM_ICSelection=TIM_ICSelection_DirectTI; 
	TIM_ICInit(TIM2,&TIM_ICInitStruct);
	TIM_ITConfig(TIM2,TIM_IT_CC2,ENABLE);
	
	NVIC_InitStruct.NVIC_IRQChannel=TIM2_IRQn;
	NVIC_InitStruct.NVIC_IRQChannelCmd=ENABLE;
	NVIC_InitStruct.NVIC_IRQChannelPreemptionPriority=0x00;    
	NVIC_InitStruct.NVIC_IRQChannelSubPriority=0x01;         
	NVIC_Init(&NVIC_InitStruct);
	
	TIM_Cmd(TIM2,ENABLE);    
}

void TIM2_IRQHandler(void)
{ 
	if(TIM_GetITStatus(TIM2,TIM_IT_CC2)!=RESET)   
	{
		if(Edge_Flag==1)
		{
			Rising=TIM2->CCR2;  
			TIM_OC2PolarityConfig(TIM2,TIM_ICPolarity_Rising);  
			Edge_Flag++; 
		}
		else if(Edge_Flag==2)
		{
			Rising_Last=TIM2->CCR2;
			TIM_OC2PolarityConfig(TIM2,TIM_ICPolarity_Rising);
			Edge_Flag=0;     
			TIM_SetCounter(TIM2,0); 
		}
		else
		{
			Falling=TIM2->CCR2;    
			TIM_OC2PolarityConfig(TIM2,TIM_ICPolarity_Falling);    
			Edge_Flag++;
		}
	}
	TIM_ClearITPendingBit(TIM2,TIM_IT_CC2);   
}






