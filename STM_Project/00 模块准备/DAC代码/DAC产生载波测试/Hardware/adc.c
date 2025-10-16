#include <stdio.h>
#include "string.h"
#include "adc.h"

#define ADC1_DR_Address    ((uint32_t)0x4001244C)

uint16_t ADC_Value[ADC_LEN];

void ADC1_Init(void)
{
    ADC_InitTypeDef ADC_InitStructure;
	GPIO_InitTypeDef GPIO_InitStructure;

    RCC_APB2PeriphClockCmd(RCC_APB2Periph_ADC1, ENABLE); //开启ADC1的时钟

    RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA, ENABLE);//开启GPIOA的时钟

	/*设置ADC时钟*/
	RCC_ADCCLKConfig(RCC_PCLK2_Div6);						//选择时钟6分频，ADCCLK = 72MHz / 6 = 12MHz
	
    GPIO_InitStructure.GPIO_Pin = GPIO_Pin_1;
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AIN;
    GPIO_Init(GPIOA, &GPIO_InitStructure);				//将 PA1 引脚初始化为模拟输入

    ADC_InitStructure.ADC_Mode = ADC_Mode_Independent;	//模式，选择独立模式，即单独使用ADC1
    ADC_InitStructure.ADC_ScanConvMode = DISABLE;
    ADC_InitStructure.ADC_ContinuousConvMode = DISABLE;	
    ADC_InitStructure.ADC_ExternalTrigConv = ADC_ExternalTrigConv_T1_CC1;  //外部触发
    ADC_InitStructure.ADC_DataAlign = ADC_DataAlign_Right;
    ADC_InitStructure.ADC_NbrOfChannel = 1;
    ADC_Init(ADC1, &ADC_InitStructure);

	//规则组序列1的位置，配置为通道0
    ADC_RegularChannelConfig(ADC1, ADC_Channel_0, 1, ADC_SampleTime_1Cycles5);
    ADC_Cmd(ADC1, ENABLE);

    ADC_ExternalTrigConvCmd(ADC1, ENABLE);

    ADC_DMACmd(ADC1, ENABLE);

    ADC_ResetCalibration(ADC1);
    while(ADC_GetResetCalibrationStatus(ADC1));

    ADC_StartCalibration(ADC1);
    while(ADC_GetCalibrationStatus(ADC1));  
}

void ADC1_DMA1_Init(void)
{
    DMA_InitTypeDef DMA_InitStructure;								//定义结构体变量
    NVIC_InitTypeDef NVIC_InitStructure;

    RCC_AHBPeriphClockCmd(RCC_AHBPeriph_DMA1, ENABLE);				//开启DMA1的时钟

    NVIC_PriorityGroupConfig(NVIC_PriorityGroup_1);

    NVIC_InitStructure.NVIC_IRQChannel = DMA1_Channel1_IRQn;
    NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = 0;
    NVIC_InitStructure.NVIC_IRQChannelSubPriority = 0;
    NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;
    NVIC_Init(&NVIC_InitStructure);

    DMA_DeInit(DMA1_Channel1);
    DMA_InitStructure.DMA_PeripheralBaseAddr = ADC1_DR_Address;  	//外设基地址，给定形参AddrA
    DMA_InitStructure.DMA_MemoryBaseAddr = (uint32_t)ADC_Value;		//存储器基地址
    DMA_InitStructure.DMA_DIR = DMA_DIR_PeripheralSRC;				//数据传输方向，选择由外设到存储器
    DMA_InitStructure.DMA_BufferSize = ADC_LEN;
    DMA_InitStructure.DMA_PeripheralInc = DMA_PeripheralInc_Disable;//外设地址自增，选择失能
    DMA_InitStructure.DMA_MemoryInc = DMA_MemoryInc_Enable;			//存储器地址自增，选择使能
    DMA_InitStructure.DMA_PeripheralDataSize = DMA_PeripheralDataSize_HalfWord;
    DMA_InitStructure.DMA_MemoryDataSize = DMA_MemoryDataSize_HalfWord;
    DMA_InitStructure.DMA_Mode = DMA_Mode_Normal;					//模式，选择正常模式
    DMA_InitStructure.DMA_Priority = DMA_Priority_High;				//优先级
    DMA_InitStructure.DMA_M2M = DMA_M2M_Disable;					//存储器到存储器，选择失能，数据由ADC外设触发转运到存储器
    DMA_Init(DMA1_Channel1, &DMA_InitStructure);

    DMA_ITConfig(DMA1_Channel1, DMA_IT_TC | DMA_IT_HT, ENABLE);

    DMA_Cmd(DMA1_Channel1, ENABLE);
}

void TIM1_Init(void)
{
    TIM_TimeBaseInitTypeDef   TIM_TimeBaseStructure;
    TIM_OCInitTypeDef         TIM_OCInitStructure;
	GPIO_InitTypeDef GPIO_InitStructure;

    RCC_APB2PeriphClockCmd(RCC_APB2Periph_TIM1, ENABLE);

    RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA, ENABLE);

    GPIO_InitStructure.GPIO_Pin = GPIO_Pin_8;
    GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AF_PP;
    GPIO_Init(GPIOA, &GPIO_InitStructure);

    TIM_TimeBaseStructInit(&TIM_TimeBaseStructure); 
    TIM_TimeBaseStructure.TIM_Period = ARR;          
    TIM_TimeBaseStructure.TIM_Prescaler = PSC;       
    TIM_TimeBaseStructure.TIM_ClockDivision = 0x00;    
    TIM_TimeBaseStructure.TIM_CounterMode = TIM_CounterMode_Up;  
    TIM_TimeBaseInit(TIM1, &TIM_TimeBaseStructure);

    TIM_OCInitStructure.TIM_OCMode = TIM_OCMode_PWM1; 
    TIM_OCInitStructure.TIM_OutputState = TIM_OutputState_Enable;                
    TIM_OCInitStructure.TIM_Pulse = 8000; 
    TIM_OCInitStructure.TIM_OCPolarity = TIM_OCPolarity_Low;         
    TIM_OC1Init(TIM1, &TIM_OCInitStructure);

    TIM_CtrlPWMOutputs(TIM1, ENABLE);
    TIM_Cmd(TIM1, DISABLE);
}

void DMA1_Channel1_IRQHandler(void)
{	
    DMA_Cmd(DMA1_Channel1, DISABLE);

    DMA_ClearITPendingBit(DMA_IT_HT);
    DMA_ClearITPendingBit(DMA1_IT_TC1);	
	
	DMA_Cmd(DMA1_Channel1, ENABLE);
	
	
}
