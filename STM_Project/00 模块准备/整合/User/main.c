#include "stm32f10x.h"                  // Device header
#include "Delay.h"
#include "sys.h"
#include "OLED.h"
#include "stm32_config.h"
#include "stdio.h"
#include "AD9833.h"
#include "AD_single.h"
#include "ADC_FFT.h"
#include "usart.h"
#include "fft_calculate.h"
#include "Serial.h"
#include "MyFIR.h"
#include "arm_math.h"
#include "arm_const_structs.h"
#include "DAC_3.h"
#include "DAC.h"


/* 说明 */
/*
*** OLED
	OLED_ShowString(1, 1, "String:");
	OLED_ShowNum(1, 9, NUm, 4);

*** AD9833
	SYKC —— PA3;     
	CLK  —— PA4;   
	DATA —— PA5;	      
	V+   —— (3.3V,5V均可)
	GND  —— GND(0V) 
			
	AD9833_SetFrequencyQuick(1000.0,AD9833_OUT_SINUS);
	AD9833_SetFrequencyQuick(1000.0,AD9833_OUT_TRIANGLE);
	AD9833_SetFrequencyQuick(5000.0,AD9833_OUT_MSB);
	
*** AD采样	
*	AD_single
	采样脚 —— PA0

	ADValue = AD_GetValue();					
	Voltage = (float)ADValue / 4095 * 3.3;		
	OLED_ShowNum(1, 9, ADValue, 4);				
	OLED_ShowNum(2, 9, Voltage, 1);				
	OLED_ShowNum(2, 11, (uint16_t)(Voltage * 100) % 100, 2);	

*	AD_FFT   用于采样 N 点 便于FFT操作
	采样脚   —— PA1
	采样频率 —— TIM2控制 ADC_FFT.h修改

*** 串口助手
	TXD —— PA10
	RXD —— PA9

*** 数字滤波FIR
	调用 	 —— arm_fir_f32_lp();
	输入数组 —— testInput_f32_1024Hz[]
	输出数组 —— testOutput[]

***	MATLAB通信
	
	

*/

// ADC_FFT测试
u32 Freq;
u16 Row;
u16 Max_Val=0;

// ADC_single测试
uint16_t ADValue_single;			//定义AD值变量
float Voltage_single;				//定义电压变量

// MATLAB通信测试
union
{
  struct
  {
    uint8_t com[4];
  }ComInfo;
  
  float data;
	
}D_data;			//传输数据

uint8_t RxData;		//接收数据 （=10）

#define N 256	//数组长度



int main(void)
{
	
	/*模块初始化*/
	OLED_Init();						//OLED初始化
	
	MY_NVIC_PriorityGroup_Config(NVIC_PriorityGroup_2);		//AD9833初始化
	Delay_ms(500);
	AD9833_Init();
	
//	AD_single_Init();					//单通道AD初始化
	
	AD_FFT_Init();						//AD+FFT 初始化
	
	Serial_Init();						//串口初始化
	
	
	Delay_ms(10);
	
	/* FFT测试 */
//	OLED_ShowString(1, 1, "K: 00000");
//	OLED_ShowString(2, 1, "Max_Val:00000");
	
	AD9833_SetFrequencyQuick(500.0, AD9833_OUT_SINUS);
	
	
	while (1)
	{	
		/* FFT测试 */
//		FFT_test(); 
//		Delay_ms(5000);
		
		
//		Delay_ms(500);
//		GPIO_SetBits(GPIOC, GPIO_Pin_13);						//将PC13引脚设置为高电平
//		Delay_ms(500);
//		GPIO_ResetBits(GPIOC, GPIO_Pin_13);						//将PC13引脚设置为低电平
		
		
		/* MATLAB通信测试 */		
//		FIR_test();
//		Delay_ms(500);
//		if (Serial_GetRxFlag() == 1)			//检查串口接收数据的标志位
//		{
//			RxData = Serial_GetRxData();		//获取串口接收的数据
//			OLED_ShowNum(1, 5, RxData, 5);
//			if(RxData==10)						//判断握手信号是否到来
//			{		
//				Delay_ms(10);
//				for(int i=0;i<N;i++)
//				{
//					D_data.data = (uint32_t)AD_FFT_Value[i];     		//将数据赋给共同体
////					OLED_ShowNum(3, 5, D_data.data, 5);
//					Serial_SendArray(D_data.ComInfo.com, 4);//将4个字节发送出去
//				}		
//			}
//		}
		
	
	
	}
}
