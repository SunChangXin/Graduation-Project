/**********************************************************
                       康威电子
功能：参考时钟25MHz，stm32f103rct6控制AD9833点频输出，正弦波范围0-10M， 
			方波：0-500K，三角波：0-1M 。
接口：控制引脚接口请参照AD9833.h
时间：2023/06/08
版本：2.1
作者：康威电子
其他：本程序只供学习使用，盗版必究。

					AD9833	单片机
硬件连接:	SYKC——PA3;     
			CLK ——PA4;   
			DATA——PA5;	      
			V+——(3.3V,5V均可)
			GND--GND(0V)  

更多电子需求，请到淘宝店，康威电子竭诚为您服务 ^_^
https://kvdz.taobao.com/ 
**********************************************************/

#include "stm32_config.h"
#include "stdio.h"
#include "AD9833.h"
#include "OLED.h"
#include "IC.h"
#include "Key.h"
#include "AD.h"

uint8_t KeyNum;	
uint8_t Confirm;	

uint16_t ADValue;			//??AD???
float Voltage;				//??????

int main(void)
{
	OLED_Init();
	IC_Init();		
	Key_Init();
	
	
	OLED_ShowString(1, 1, "ADValue:");
	OLED_ShowString(2, 1, "Voltage:0.00V");
	
//	// 显示频率
//	OLED_ShowString(1, 1, "NUM:00000");
//	OLED_ShowString(2, 1, "Freq:00000Hz");		
	
	
	
	MY_NVIC_PriorityGroup_Config(NVIC_PriorityGroup_2);	//设置中断分组
	delay_init(72);	//初始化延时函数
	delay_ms(500);//延时一会儿，等待上电稳定,确保AD9833比控制板先上电。
 
	//代码移植建议
	//1.修改头文件AD9833.h中，自己控制板实际需要使用哪些控制引脚。如AD9833_FSYNC脚改成PA1控制，则定义"#define AD9833_FSYNC	PAout(1)" 
	//2.修改C文件AD9833.c中，AD983_GPIO_Init函数，所有用到管脚的GPIO输出功能初始化
	//3.完成
	
	AD9833_Init();//IO口及AD9833寄存器初始化
	
	AD_Init();				//AD???
	//频率入口参数为float，可使信号的频率更精确
//	AD9833_SetFrequencyQuick(1000.0,AD9833_OUT_SINUS);//写输出频率1000.0Hz,输出正弦波
//	AD9833_SetFrequencyQuick(1000.0,AD9833_OUT_TRIANGLE);//写输出频率1000.0Hz,输出三角波
	

	while(1)
	{
		AD9833_SetFrequencyQuick(4000.0,AD9833_OUT_SINUS);//写输出频率1000.0Hz,输出正弦波
		
		ADValue = AD_GetValue();					//??AD????
		Voltage = (float)ADValue / 4095 * 3.3;		//?AD??????0~3.3???,????
		
		OLED_ShowNum(1, 9, ADValue, 4);				//??AD?
		OLED_ShowNum(2, 9, Voltage, 1);				//??????????
		OLED_ShowNum(2, 11, (uint16_t)(Voltage * 100) % 100, 2);	//??????????
		
		delay_ms(100);			//??100ms,?????????????
		
//		AD9833_SetFrequencyQuick(5000.0,AD9833_OUT_MSB); //写输出频率10000.0Hz,输出方波
//		AD9833_SetFrequencyQuick(1000.0,AD9833_OUT_TRIANGLE);//写输出频率1000.0Hz,输出三角波
//		KeyNum = Key_GetNum();
//					
//		if (KeyNum == 0)			//0
//		{    
//			AD9833_SetFrequencyQuick(10000.0,AD9833_OUT_MSB); //写输出频率10000.0Hz,输出方波
//		}
//		
//		if (KeyNum == 1)			//1
//		{
//			AD9833_SetFrequencyQuick(1000.0,AD9833_OUT_MSB); //写输出频率1000.0Hz,输出方波
//		}
//		
//		if (KeyNum == 2)			//2
//		{
//			AD9833_SetFrequencyQuick(2000.0,AD9833_OUT_MSB); //写输出频率1000.0Hz,输出方波
//		}
//		
//		if (KeyNum == 3)			//3
//		{
//			AD9833_SetFrequencyQuick(3000.0,AD9833_OUT_MSB); //写输出频率3000.0Hz,输出方波
//		}
//		
//		if (KeyNum == 4)			//4
//		{
//			AD9833_SetFrequencyQuick(4000.0,AD9833_OUT_MSB); //写输出频率4000.0Hz,输出方波
//		}
//		
//		if (KeyNum == 5)			//5
//		{
//			AD9833_SetFrequencyQuick(5000.0,AD9833_OUT_MSB); //写输出频率5000.0Hz,输出方波
//		}
//		
//		if (KeyNum == 6)			//6
//		{
//			AD9833_SetFrequencyQuick(6000.0,AD9833_OUT_MSB); //写输出频率6000.0Hz,输出方波
//		}
//		
//		if (KeyNum == 7)			//7
//		{
//			AD9833_SetFrequencyQuick(7000.0,AD9833_OUT_MSB); //写输出频率7000.0Hz,输出方波
//		}
//		
//		if (KeyNum == 8)			//8
//		{
//			AD9833_SetFrequencyQuick(8000.0,AD9833_OUT_MSB); //写输出频率8000.0Hz,输出方波
//		}
//		
//		if (KeyNum == 9)			//9
//		{
//			AD9833_SetFrequencyQuick(9000.0,AD9833_OUT_MSB); //写输出频率9000.0Hz,输出方波
//		}
//					
//		
//		OLED_ShowNum(1, 6, KeyNum, 5);	//获取当前数字
//		OLED_ShowNum(2, 6, IC_GetFreq(), 5);	//获取信号频率
	};

}


