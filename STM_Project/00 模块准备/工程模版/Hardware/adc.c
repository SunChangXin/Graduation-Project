#include <stdio.h>
#include "string.h"
#include "adc.h"
#include "sys.h"
#include "delay.h"
#include "stm32_dsp.h"
#include "fft_calculate.h"

u16 ADC_Value[NPT];

void  Adc_Init2(void)
{ 	
	ADC_InitTypeDef ADC_InitStructure; 
	GPIO_InitTypeDef GPIO_InitStructure;

	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA |RCC_APB2Periph_ADC2	, ENABLE );	  //使能ADC1通道时钟
 

	RCC_ADCCLKConfig(RCC_PCLK2_Div6);   //设置ADC分频因子6 72M/6=12,ADC最大时间不能超过14M

	//PA1 作为模拟通道输入引脚                         
	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_0;
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AIN;		//模拟输入引脚
	GPIO_Init(GPIOA, &GPIO_InitStructure);	

	ADC_DeInit(ADC2);  //复位ADC1,将外设 ADC1 的全部寄存器重设为缺省值

	ADC_InitStructure.ADC_Mode = ADC_Mode_Independent;	//ADC工作模式:ADC1和ADC2工作在独立模式
	ADC_InitStructure.ADC_ScanConvMode = DISABLE;	//模数转换工作在单通道模式
	ADC_InitStructure.ADC_ContinuousConvMode = DISABLE;	//模数转换工作在单次转换模式
	ADC_InitStructure.ADC_ExternalTrigConv = ADC_ExternalTrigConv_None;	//转换由软件而不是外部触发启动
	ADC_InitStructure.ADC_DataAlign = ADC_DataAlign_Right;	//ADC数据右对齐
	ADC_InitStructure.ADC_NbrOfChannel = 0;	//顺序进行规则转换的ADC通道的数目
	ADC_Init(ADC2, &ADC_InitStructure);	//根据ADC_InitStruct中指定的参数初始化外设ADCx的寄存器   

  
	ADC_Cmd(ADC2, ENABLE);	//使能指定的ADC1
	
	ADC_ResetCalibration(ADC2);	//使能复位校准  
	 
	while(ADC_GetResetCalibrationStatus(ADC2));	//等待复位校准结束
	
	ADC_StartCalibration(ADC2);	 //开启AD校准
 
	while(ADC_GetCalibrationStatus(ADC2));	 //等待校准结束
 
//	ADC_SoftwareStartConvCmd(ADC1, ENABLE);		//使能指定的ADC1的软件转换启动功能

}		

u16 Get_Adc(u8 ch)   
{
  	//设置指定ADC的规则组通道，一个序列，采样时间
	ADC_RegularChannelConfig(ADC2, ch, 1, ADC_SampleTime_239Cycles5 );	//ADC1,ADC通道,采样时间为239.5周期	  			    
  
	ADC_SoftwareStartConvCmd(ADC2, ENABLE);		//使能指定的ADC1的软件转换启动功能	
	 
	while(!ADC_GetFlagStatus(ADC2, ADC_FLAG_EOC ));//等待转换结束

	return ADC_GetConversionValue(ADC2);	//返回最近一次ADC1规则组的转换结果
}

u16 Get_Adc_Average(u8 ch,u8 times)
{
	u32 temp_val=0;
	u8 t;
	for(t=0;t<times;t++)
	{
		temp_val+=Get_Adc(ch);
		delay_ms(5);
	}
	return temp_val/times;
} 	 

void ADC1_Configuration(void)
{
	GPIO_InitTypeDef  GPIO_InitStructure;
	ADC_InitTypeDef ADC_InitStructure;

	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA | RCC_APB2Periph_ADC1 | RCC_APB2Periph_AFIO ,ENABLE ); //使能 ADC1 通道时钟，各个管脚时钟
	RCC_ADCCLKConfig(RCC_PCLK2_Div6); //72M/6=12,ADC 最大时间不能超过 14M
	RCC_AHBPeriphClockCmd(RCC_AHBPeriph_DMA1, ENABLE);
																		
	GPIO_InitStructure.GPIO_Pin  = GPIO_Pin_0;//PA0 作为模拟通道输入引脚
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AIN; //模拟输入引脚
	GPIO_Init(GPIOA, &GPIO_InitStructure);

	ADC_DeInit(ADC1); //将外设 ADC1 的全部寄存器重设为缺省值
	ADC_InitStructure.ADC_Mode = ADC_Mode_Independent; //ADC 工作模式:ADC1 和 ADC2工作在独立模式
	ADC_InitStructure.ADC_ScanConvMode =DISABLE; //模数转换工作在扫描模式（改成了非扫描！！！！！！！！！！）
	ADC_InitStructure.ADC_ContinuousConvMode =DISABLE; //模数转换工作在连续转换模式（改成了不连续！！！！！！！）
	ADC_InitStructure.ADC_ExternalTrigConv = ADC_ExternalTrigConv_T1_CC1;           //Timer1触发转换开启！！！！！！(定时器T1的CC1通道，控制采样频率)
	ADC_InitStructure.ADC_DataAlign = ADC_DataAlign_Right; //ADC 数据右对齐
	ADC_InitStructure.ADC_NbrOfChannel = 1; //顺序进行规则转换的 ADC 通道的数目
	ADC_Init(ADC1, &ADC_InitStructure); //根据 ADC_InitStruct 中指定的参数初始化外设ADCx 的寄存器

	ADC_RegularChannelConfig(ADC1, ADC_Channel_11, 1, ADC_SampleTime_13Cycles5 );
	
	ADC_ExternalTrigConvCmd(ADC1, ENABLE);   //外部触发	
  
	ADC_DMACmd(ADC1, ENABLE);// 开启 ADC 的 DMA 支持（要实现 DMA 功能，还需独立配置 DMA 通道等参数）
	
	ADC_Cmd(ADC1, ENABLE); //使能指定的 ADC1
	ADC_ResetCalibration(ADC1); //复位指定的 ADC1 的校准寄存器
	while(ADC_GetResetCalibrationStatus(ADC1)); //获取 ADC1 复位校准寄存器的状态,设置状态则等待
	ADC_StartCalibration(ADC1); //开始指定 ADC1 的校准状态
	while(ADC_GetCalibrationStatus(ADC1)); //获取指定 ADC1 的校准程序,设置状态则等待
}


void DMA_Configuration(void)
{
		
	DMA_InitTypeDef DMA_InitStructure;
	NVIC_InitTypeDef NVIC_InitStructure;
	
	RCC_AHBPeriphClockCmd(RCC_AHBPeriph_DMA1, ENABLE);
	
	NVIC_PriorityGroupConfig(NVIC_PriorityGroup_1);

	DMA_DeInit(DMA1_Channel1); //将 DMA 的通道 1 寄存器重设为缺省值
	DMA_InitStructure.DMA_PeripheralBaseAddr = (u32)&ADC1->DR; //DMA 外设 ADC 基地址
	DMA_InitStructure.DMA_MemoryBaseAddr = (u32)&ADC_Value; //DMA 内存基地址
	DMA_InitStructure.DMA_DIR = DMA_DIR_PeripheralSRC; //内存作为数据传输的目的地
	DMA_InitStructure.DMA_BufferSize = NPT; //DMA 通道的 DMA 缓存的大小（1024）
	DMA_InitStructure.DMA_PeripheralInc = DMA_PeripheralInc_Disable; //外设地址寄存器不变
	DMA_InitStructure.DMA_MemoryInc = DMA_MemoryInc_Enable; //内存地址寄存器递增
	DMA_InitStructure.DMA_PeripheralDataSize = DMA_PeripheralDataSize_HalfWord; //数据宽度为 16 位
	DMA_InitStructure.DMA_MemoryDataSize = DMA_MemoryDataSize_HalfWord; //数据宽度为16 位
	DMA_InitStructure.DMA_Mode = DMA_Mode_Normal; //工作在循环缓存模式
	DMA_InitStructure.DMA_Priority = DMA_Priority_High; //DMA 通道 x 拥有高优先级
	DMA_InitStructure.DMA_M2M = DMA_M2M_Disable; //DMA 通道 x 没有设置为内存到内存传输
	DMA_Init(DMA1_Channel1, &DMA_InitStructure); //根据 DMA_InitStruct 中指定的参数初始DMA 的通道
	
/*  因为要显示刷屏，所以没用DMA中断  */	
//	NVIC_InitStructure.NVIC_IRQChannel = DMA1_Channel1_IRQn;
//	NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = 0;
//	NVIC_InitStructure.NVIC_IRQChannelSubPriority = 0;
//	NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;
//	NVIC_Init(&NVIC_InitStructure);	
//	DMA_ITConfig(DMA1_Channel1, DMA_IT_TC , ENABLE);       //开启转换完成中断
		
	DMA_Cmd(DMA1_Channel1, ENABLE);
}


/*  因为要显示刷屏，所以没用DMA中断  */	
void ADC1_DMA1_IT_Hander(void)
{
	int i;
	if(DMA_GetFlagStatus(DMA1_FLAG_TC1)) // 如果DMA转运完成
	{
		for(i=0;i<NPT;i++)
		{
		 InBufArray[i]=ADC_Value[i]<<16;
		}
	}
	
	/* FFT */
	cr4_fft_256_stm32(OutBufArray, InBufArray, NPT);
	GetPowerMag();
	
	
	DMA_ClearITPendingBit(DMA1_FLAG_TC1);
}	

//******??ADC?DMA??????,??????ADC?DMA???,??ADC??????????DMA??,?????????????,?????????????***//
void ADC_DMA_Trigger(){

	DMA_Cmd(DMA1_Channel1,DISABLE);//??????????disable?enable,??????????NDTR????????
//	DMA_SetCurrDataCounter(DMA2_Stream0,AD3_Value_Length);
//	DMA_ClearITPendingBit( DMA2_Stream0 ,DMA_IT_TCIF0|DMA_IT_DMEIF0|DMA_IT_TEIF0|DMA_IT_HTIF0|DMA_IT_TCIF0 );	
	DMA_ClearITPendingBit(DMA1_FLAG_TC1);
	ADC_ClearITPendingBit(ADC1, ADC_IT_EOC);//ADC3->SR = 0;
	DMA_Cmd(DMA1_Channel1,ENABLE);
}

