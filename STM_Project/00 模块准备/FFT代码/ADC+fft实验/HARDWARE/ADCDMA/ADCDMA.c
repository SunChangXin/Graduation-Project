#include "ADCDMA.h"

//PF3 ADC3:IN9

uint16_t AD3_Value[AD3_Value_Length];

void AD3_Init(){
	//结构体
	GPIO_InitTypeDef  GPIO_InitStructure; 				//GPIO结构体	
	DMA_InitTypeDef DMA_InitStructure;					//DMA结构体	
	ADC_CommonInitTypeDef ADC_CommonInitStructure; 		//ADCcommon结构体
	ADC_InitTypeDef ADC_InitStructure;					//ADC结构体
	
	//时钟开启
	RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOF, ENABLE);	//使能GPIOF时钟
	RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_DMA2,ENABLE);		//使能DMA2时钟
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_ADC3, ENABLE);	//使能ADC3时钟
	
	//GPIO配置
	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_3;		
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AN;			//模拟模式
//	GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;			//推挽输出
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_100MHz;		//100MHz
	GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_NOPULL;		//浮空
	GPIO_Init(GPIOF, &GPIO_InitStructure);					//GPIO初始化
	
	//ADCcommon配置
	ADC_CommonInitStructure.ADC_Mode = ADC_Mode_Independent;					//独立模式
	ADC_CommonInitStructure.ADC_DMAAccessMode = ADC_DMAAccessMode_Disabled;		//非多重模式，多重模式下才开启此配置的DMA
	ADC_CommonInitStructure.ADC_Prescaler = ADC_Prescaler_Div4;					//采样频率4分频		84MHz/4 = 21MHz
	ADC_CommonInitStructure.ADC_TwoSamplingDelay = ADC_TwoSamplingDelay_5Cycles;
	ADC_CommonInit(&ADC_CommonInitStructure);									//ADCcommon结构体初始化
	
	//ADC配置
	ADC_InitStructure.ADC_ContinuousConvMode = DISABLE;							//是否连续转换
	ADC_InitStructure.ADC_DataAlign = ADC_DataAlign_Right;						//数据对齐：右对齐
	ADC_InitStructure.ADC_ExternalTrigConv = ADC_ExternalTrigConv_T2_TRGO;//
	ADC_InitStructure.ADC_ExternalTrigConvEdge = ADC_ExternalTrigConvEdge_RisingFalling   ;	//
	ADC_InitStructure.ADC_NbrOfConversion = AD3_Value_Length;					//转换数量：一波采集采集的AD值个数,多通道时一般为通道数量
	ADC_InitStructure.ADC_Resolution = ADC_Resolution_12b;						//12bit
	ADC_InitStructure.ADC_ScanConvMode = DISABLE;  								//是否扫描：多通道需扫描
	ADC_Init(ADC3, &ADC_InitStructure);											//ADC3初始化


	//ADC序列 转换顺序
	ADC_RegularChannelConfig(ADC3,ADC_Channel_9, 1,ADC_SampleTime_84Cycles);


	//DMA配置
	DMA_InitStructure.DMA_Channel = DMA_Channel_2;							//DMA_CH2	
	DMA_InitStructure.DMA_Mode = DMA_Mode_Normal; 							//非循环
	DMA_InitStructure.DMA_DIR = DMA_DIR_PeripheralToMemory;					//外设到内存
	DMA_InitStructure.DMA_BufferSize = AD3_Value_Length;					//传输次数，数组长度
	DMA_InitStructure.DMA_Priority = DMA_Priority_Medium;					//优先级
		//DMA_FIFO
	DMA_InitStructure.DMA_FIFOMode = DMA_FIFOMode_Disable;
	DMA_InitStructure.DMA_FIFOThreshold = DMA_FIFOThreshold_HalfFull;
	
	DMA_InitStructure.DMA_Memory0BaseAddr =	(uint32_t)AD3_Value;	 			//内存地址：收集AD值得数组		
	DMA_InitStructure.DMA_MemoryBurst = DMA_MemoryBurst_Single;
	DMA_InitStructure.DMA_MemoryDataSize = DMA_MemoryDataSize_HalfWord;			//16 bit
	DMA_InitStructure.DMA_MemoryInc = DMA_MemoryInc_Enable;						//内存自增

	DMA_InitStructure.DMA_PeripheralBaseAddr = (uint32_t)&(ADC3->DR);			//外设地址，ADC3地址，多通道但仅有一个寄存器
	DMA_InitStructure.DMA_PeripheralBurst = DMA_PeripheralBurst_Single;
	DMA_InitStructure.DMA_PeripheralDataSize = DMA_PeripheralDataSize_HalfWord;	//16 bit
	DMA_InitStructure.DMA_PeripheralInc = DMA_PeripheralInc_Disable; 			//外设不自增，始终为ADC3地址
	DMA_Init(DMA2_Stream0,&DMA_InitStructure);									//DMA2_Stream0 初始化

	DMA_Cmd(DMA2_Stream0,ENABLE);						//DMA2_Stream0 使能	
	ADC_DMARequestAfterLastTransferCmd(ADC3, ENABLE);	//源数据变化时开启DMA传输
	ADC_DMACmd(ADC3, ENABLE);							//ADC3_DMA使能
	ADC_Cmd(ADC3, ENABLE);								//ADC3 使能
	
//	ADC_SoftwareStartConv(ADC3);						//软件触发ADC转换
}

//******清空ADC与DMA的中断标志位，起到再次触发ADC与DMA的作用，否则ADC只会采集一波数据然后DMA搬运，若需多次采集必须使用次函数，可在数据处理完成后再次使用***//
void ADC_DMA_Trigger(){

	DMA_Cmd(DMA2_Stream0,DISABLE);//若用循环模式就可不用disable再enable，关掉再重启主要起重装NDTR和保护数据的作用
//	DMA_SetCurrDataCounter(DMA2_Stream0,AD3_Value_Length);
//	DMA_ClearITPendingBit( DMA2_Stream0 ,DMA_IT_TCIF0|DMA_IT_DMEIF0|DMA_IT_TEIF0|DMA_IT_HTIF0|DMA_IT_TCIF0 );
	DMA_ClearITPendingBit( DMA2_Stream0 ,DMA_IT_TCIF0);	
	ADC_ClearITPendingBit(ADC3,ADC_IT_OVR);//ADC3->SR = 0;
	DMA_Cmd(DMA2_Stream0,ENABLE);
}
