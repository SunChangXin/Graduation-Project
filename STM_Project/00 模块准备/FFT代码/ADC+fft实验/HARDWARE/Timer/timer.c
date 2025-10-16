#include "Timer.h"

//主频84M

//TIM2 32bit
void TIM2_Init(uint16_t arr, uint16_t psc){
	TIM_TimeBaseInitTypeDef TIM_TimeBaseInitStructure;		//时基结构体
	RCC_APB1PeriphClockCmd(RCC_APB1Periph_TIM2,ENABLE);       		//TIM2 时钟使能
	TIM_InternalClockConfig(TIM2);	
	TIM_TimeBaseInitStructure.TIM_Period = arr; 					//设置自动重装载值
	TIM_TimeBaseInitStructure.TIM_Prescaler =psc; 					//设置预分频值
	TIM_TimeBaseInitStructure.TIM_ClockDivision = TIM_CKD_DIV1; 	//设置时钟分割
	TIM_TimeBaseInitStructure.TIM_CounterMode = TIM_CounterMode_Up; //向上计数模式
	
	TIM_SelectOutputTrigger(TIM2,TIM_TRGOSource_Update);			//更新溢出向外触发
	TIM_TimeBaseInit(TIM2, &TIM_TimeBaseInitStructure); 			//时基初始化
	TIM_Cmd(TIM2, ENABLE);											//定时器使能
}
