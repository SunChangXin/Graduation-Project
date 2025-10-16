#include "system.h"
#include "SysTick.h"
#include "usart.h"
#include "fft_calculate.h"
#include "adc.h"
#include "time.h"
#include "OLED.h"
#include "stm32_config.h"
#include "AD9833.h"
#include "stdio.h"

u32 Freq;
u16 Row;
u16 Max_Val=0;
u16 adc_value[5];
/*******************************************************************************
* º¯ Êý Ãû         : main
* º¯Êý¹¦ÄÜ		   : Ö÷º¯Êý
* Êä    Èë         : ÎÞ
* Êä    ³ö         : ÎÞ
*******************************************************************************/
int main()
{
	u16 i;
	
	OLED_Init();					// System_Init
	SysTick_Init(72);
	
	NVIC_PriorityGroupConfig(NVIC_PriorityGroup_2); 
	USART1_Init(9600);

	
	TIM1_Init();                     // ADC + DMA
	ADC1_DMA1_Init();
	ADC1_Init();
	TIM_Cmd(TIM1, ENABLE);
	
	MY_NVIC_PriorityGroup_Config(NVIC_PriorityGroup_2);		// AD9833
	delay_ms(500);
	AD9833_Init();

	
	AD9833_SetFrequencyQuick(4000.0, AD9833_OUT_SINUS);   	// AD9833输出正弦 4K Hz
	
	OLED_ShowString(1, 1, "Row: 00000");
	OLED_ShowString(2, 1, "Freq:00.00Hz");
	OLED_ShowString(3, 1, "Max_Val:00000");
	
	while(1)
	{
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
		
		//LCD_ShowString(0,10,25,20,24,"Row:");
//		LCD_ShowString(0,40,70,20,24,"Max_Val:");
		//LCD_ShowString(0,70,40,20,24,"Freq:");
		//LCD_ShowString(150,70,40,20,24,"Hz");
//		LCD_ShowxNum(40,10,Row,4,24,0);
//		LCD_ShowxNum(80,40,(Max_Val-20),4,24,0);
		//LCD_ShowxNum(55,70,Freq,7,24,0);
		
		
		
		OLED_ShowNum(1, 6, Row, 5);
		OLED_ShowNum(2, 7, (72000000)/((NPT*(ARR+1)*(PSC+1)/Row)), 1);				//显示电压值的整数部分
		OLED_ShowNum(2, 9, (uint16_t)((7200000000)/((NPT*(ARR+1)*(PSC+1)/Row)))  % 100, 2);	//显示电压值的小数部分
		OLED_ShowNum(3, 9, (Max_Val-20), 6);
		
	}
}
