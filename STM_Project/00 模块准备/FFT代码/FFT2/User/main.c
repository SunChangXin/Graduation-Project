#include "system.h"
#include "SysTick.h"
#include "usart.h"
#include "fft_calculate.h"
#include "adc.h"
#include "time.h"
#include "OLED.h"


u32 Freq;
u16 Row;
u16 Max_Val=0;
u16 adc_value[5];
/*******************************************************************************
* 函 数 名         : main
* 函数功能		   : 主函数
* 输    入         : 无
* 输    出         : 无
*******************************************************************************/
int main()
{
	u16 i;
	
	SysTick_Init(72);
	NVIC_PriorityGroupConfig(NVIC_PriorityGroup_2);  //中断优先级分组 分2组

	USART1_Init(9600);

	
	TIM1_Init();
	ADC1_DMA1_Init();
	ADC1_Init();
	TIM_Cmd(TIM1, ENABLE);

	while(1)
	{
		//Max_Val=0;
		for(i=2;i<NPT/2;i++)
		{
			if(MagBufArray[i]>Max_Val)
			{
				Max_Val=MagBufArray[i];
				Row=i;
			}
		}
		Freq=(72000000)/(NPT*(ARR+1)*(PSC+1)/Row);
		
		//LCD_ShowString(0,10,25,20,24,"Row:");
//		LCD_ShowString(0,40,70,20,24,"Max_Val:");
		//LCD_ShowString(0,70,40,20,24,"Freq:");
		//LCD_ShowString(150,70,40,20,24,"Hz");
//		LCD_ShowxNum(40,10,Row,4,24,0);
//		LCD_ShowxNum(80,40,(Max_Val-20),4,24,0);
		//LCD_ShowxNum(55,70,Freq,7,24,0);
		
			
		OLED_ShowString(1, 1, "Row:00000");
		OLED_ShowString(2, 1, "Freq:00000Hz");
		OLED_ShowNum(1, 6, Row, 5);
		OLED_ShowNum(2, 6, (Max_Val-20), 5);
		
	}
}
