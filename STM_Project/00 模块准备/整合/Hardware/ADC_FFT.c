#include "ADC_FFT.h"
#include "fft_calculate.h"
#include "OLED.h"
#include "Serial.h"
#include "MyFIR.h"

//PF3 ADC3:IN9

uint16_t AD_FFT_Value[AD_FFT_Value_Length];
#define ADC1_DR_Address    ((u32)0x4001244C)		//ADC1的地址

void ADC_GPIO_Configuration(void)
{
	GPIO_InitTypeDef GPIO_InitStructure;
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA, ENABLE);				//使能GPIOA时钟
	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_1;		//管脚
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AIN;						//模拟输入模式
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
	GPIO_Init(GPIOA, &GPIO_InitStructure);								//GPIO组
}

void ADC_TIM3_Configuration(void)
{
    TIM_TimeBaseInitTypeDef TIM_TimeBaseInitStructure; 
    RCC_APB1PeriphClockCmd(RCC_APB1Periph_TIM3, ENABLE);
    // 时钟分频（预分频器值）和周期值设置为满足 256 kHz 采样频率的配置
    TIM_TimeBaseInitStructure.TIM_Period = 280; // 修改为满足采样频率的周期值
    TIM_TimeBaseInitStructure.TIM_Prescaler = 0; // 修改为满足采样频率的预分频器值
    TIM_TimeBaseInitStructure.TIM_ClockDivision = TIM_CKD_DIV1;
    TIM_TimeBaseInitStructure.TIM_CounterMode = TIM_CounterMode_Up;
    TIM_TimeBaseInit(TIM3, &TIM_TimeBaseInitStructure);
    TIM_SelectOutputTrigger(TIM3, TIM_TRGOSource_Update);
    TIM_Cmd(TIM3, ENABLE);
}

void ADC_DMA_NVIC_Configuration(void)
{
	NVIC_InitTypeDef NVIC_InitStructure;
	NVIC_InitStructure.NVIC_IRQChannel					 = DMA1_Channel1_IRQn;
	NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = 2;
	NVIC_InitStructure.NVIC_IRQChannelSubPriority		 = 1;
	NVIC_InitStructure.NVIC_IRQChannelCmd                = ENABLE;
	NVIC_Init(&NVIC_InitStructure);
	DMA_ClearITPendingBit(DMA1_IT_TC1);
	DMA_ITConfig(DMA1_Channel1,DMA1_IT_TC1,ENABLE);
}

void ADC_DMA_Configuration(void)
{
	DMA_InitTypeDef  DMA_InitStructure;
	RCC_AHBPeriphClockCmd(RCC_AHBPeriph_DMA1,ENABLE);
	DMA_DeInit(DMA1_Channel1);
	DMA_InitStructure.DMA_PeripheralBaseAddr = (u32)&ADC1->DR;
	DMA_InitStructure.DMA_MemoryBaseAddr     = (u32)AD_FFT_Value;
	DMA_InitStructure.DMA_DIR                = DMA_DIR_PeripheralSRC;
	DMA_InitStructure.DMA_BufferSize         = AD_FFT_Value_Length;
	DMA_InitStructure.DMA_PeripheralInc      = DMA_PeripheralInc_Disable;
	DMA_InitStructure.DMA_MemoryInc          = DMA_MemoryInc_Enable;
	DMA_InitStructure.DMA_PeripheralDataSize = DMA_PeripheralDataSize_HalfWord;
	DMA_InitStructure.DMA_MemoryDataSize     = DMA_MemoryDataSize_HalfWord;
	DMA_InitStructure.DMA_Mode               = DMA_Mode_Circular;
	DMA_InitStructure.DMA_Priority           = DMA_Priority_High;
	DMA_InitStructure.DMA_M2M                = DMA_M2M_Disable;
	DMA_Init(DMA1_Channel1, &DMA_InitStructure);
	DMA_Cmd(DMA1_Channel1, ENABLE);//使能DMA	
	ADC_DMA_NVIC_Configuration();
}

void ADC_Init_Configuration(void)//ADC配置函数
{
	ADC_InitTypeDef  ADC_InitStructure;
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_ADC1, ENABLE);
	RCC_ADCCLKConfig(RCC_PCLK2_Div4);//分频
	ADC_DeInit(ADC1);
	ADC_InitStructure.ADC_Mode               = ADC_Mode_Independent;
	ADC_InitStructure.ADC_ScanConvMode       = DISABLE;			
	ADC_InitStructure.ADC_ContinuousConvMode = DISABLE;
	ADC_InitStructure.ADC_ExternalTrigConv   = ADC_ExternalTrigConv_T3_TRGO;
	ADC_InitStructure.ADC_DataAlign          = ADC_DataAlign_Right;
	ADC_InitStructure.ADC_NbrOfChannel       = 1;
	ADC_Init(ADC1, &ADC_InitStructure);

	ADC_RegularChannelConfig(ADC1, ADC_Channel_1,  1, ADC_SampleTime_7Cycles5);	//最后一个参数为
	ADC_DMACmd(ADC1, ENABLE);
	ADC_Cmd(ADC1, ENABLE);
	ADC_ResetCalibration(ADC1);
	while(ADC_GetResetCalibrationStatus(ADC1));
	ADC_StartCalibration(ADC1);
	while(ADC_GetCalibrationStatus(ADC1));
	ADC_ExternalTrigConvCmd(ADC1, ENABLE);
	//ADC_SoftwareStartConvCmd(ADC1, ENABLE);
}


void AD_FFT_Init(void)	
{
	ADC_GPIO_Configuration();

	ADC_TIM3_Configuration();

	ADC_DMA_Configuration();

	ADC_Init_Configuration();
}

//ADC_DMA中断服务程序
void DMA1_Channel1_IRQHandler()
{
	if(DMA_GetITStatus(DMA1_IT_TC1) != RESET)
	{
		u16 i;

		for(i=0; i<AD_FFT_Value_Length; i++)
		{
			InBufArray[i] = ((signed short)AD_FFT_Value[i]) << 16;
		}
		DMA_ClearITPendingBit(DMA1_IT_TC1);
	}
}

void Get_FFT_Source_Data()
{
	u16 i;

	for(i=0; i<AD_FFT_Value_Length; i++)
	{
		InBufArray[i] = (AD_FFT_Value[i]) << 16;
		printf("%d,", (AD_FFT_Value[i]));
	}
}

void Get_FIR_Source_Data()
{
	u16 i;
	
	for(i=0; i<AD_FFT_Value_Length; i++)
	{
		testInput_f32_1024Hz[i] = (float32_t)AD_FFT_Value[i];
	}
}

void FFT_test()
{
    Get_FFT_Source_Data();
    cr4_fft_256_stm32(OutBufArray, InBufArray, AD_FFT_Value_Length);
    GetPowerMag();
}

void FIR_test()
{
    Get_FIR_Source_Data();
}

#define NUM_SAMPLES 10
uint16_t performEquivalentSampling(void)
{
	uint32_t sum = 0;
	uint16_t sample =0;
	for(int i=0;i< NUM_SAMPLES; i++)
	{
		// 启动ADC转换
		ADC_SoftwareStartConvCmd(ADC1, 1);
		// 等待转换完成
		while(!ADC_GetFlagStatus(ADC1,ADC_FLAG_EOC));
		// 获取采样值
		sum += ADC_GetConversionValue(ADC1);
		// 计算平均值
		sample =sum /NUM_SAMPLES;
		return sample;
	}
}
