#include "stm32f10x.h"                  // Device header
#include "Delay.h"
#include "OLED.h"
#include "stm32_config.h"
#include "AD9833.h"
#include "stdio.h"
#include "MyFIR.h"
#include "Serial.h"
#include "arm_math.h"
#include "arm_const_structs.h"
#include "adc.h"
#include "timer.h"
#include "usart.h"

/* 说明 */
/*  AD9833 
	SYKC—— PA3;     
	CLK —— PA4;   
	DATA—— PA5;	      
	V+  —— (3.3V,5V) ;
	GND —— GND(0V) ;
	
	串口通信
	TXD —— PA9;
	RXD —— PA10;
	
	ADC
	模拟输入 —— PA0;
	
*/ 





/* 用于与MATLAB串口通信 */
uint8_t RxData;
#define N 256
union
{
  struct{
    uint8_t com[4];
  }ComInfo;
  float data;
}D_data;

/* 用于FFT */
u32 Freq;
u16 Row;
int16_t Max_Val=0;
u16 adc_value[5];


int main(void)
{
	/*模块初始化*/
	OLED_Init();		//OLED初始化
	
	MY_NVIC_PriorityGroup_Config(NVIC_PriorityGroup_2);	 //AD9833初始化
	delay_init(72);	
	delay_ms(500);
	
	AD9833_Init();
	
//	AD9833_SetFrequencyQuick(1000.0,AD9833_OUT_SINUS);// Sin
//	AD9833_SetFrequencyQuick(1000.0,AD9833_OUT_TRIANGLE);//三角
//	AD9833_SetFrequencyQuick(1000.0,AD9833_OUT_MSB);//方波
	
//	OLED_ShowString(1, 1, "NUM :0000");
//	OLED_ShowNum(3, 5, D_data.data, 5);
	
//	arm_fir_f32_lp();
	
	/*串口初始化*/
	Serial_Init();		//串口初始化
	uart_init(115200);
	
	AD9833_SetFrequencyQuick(10000.0, AD9833_OUT_SINUS);   	// AD9833输出正弦 40K Hz
	
	delay_ms(50);
	
	/*ADC初始化*/ 
	//TIM1控制ADC采样频率
//	TIM1_Int_Init(83-1,2-1);  //455kHz 
//	TIM1_Int_Init(126-1,2-1); //300kHz 
	TIM1_Int_Init(20-1,36-1);   //100kHz
	TIM2_Cap_Init();	
	
//	Adc_Init2();
	ADC1_Configuration();   //ADC初始化
	DMA_Configuration();    //DMA初始化
	
	
	OLED_ShowString(1, 1, "Row: ");
	OLED_ShowString(2, 1, "Freq:0000.0Hz");
	OLED_ShowString(3, 1, "Max_Val:00000");
	
	while (1)
	{
		
		ADC_DMA_Trigger();	
		
		
		
		u16 i;
		int Freq = 100000; 
		
		delay_ms(500);
		for(i=0;i<NPT;i++)
		{
		 InBufArray[i]=ADC_Value[i]<<16;
		}
		
		/* FFT */
		cr4_fft_256_stm32(OutBufArray, InBufArray, NPT);
		GetPowerMag();
		
//		cnt2 = 	peak_count2(InBufArray);
//		OLED_ShowNum(4, 1, cnt2, 6);
		
		Max_Val=0;
		for(i=2;i<NPT/2;i++)
		{
			if(MagBufArray[i]>Max_Val)
			{
				Max_Val=MagBufArray[i];
				Row=i;
			}
			OLED_ShowNum(4, 1, MagBufArray[i] , 6);
		}
		
		
		
		OLED_ShowNum(1, 6, Row, 5);
		OLED_ShowNum(2, 6, (Freq*Row)/NPT, 4);				//显示电压值的整数部分
		OLED_ShowNum(2, 11, ((Freq*Row*100)/NPT)  % 10, 1);	//显示电压值的小数部分
		OLED_ShowNum(3, 9, (Max_Val), 6);
	}
}
