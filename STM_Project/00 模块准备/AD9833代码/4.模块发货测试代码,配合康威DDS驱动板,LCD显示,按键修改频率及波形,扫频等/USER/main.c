/**********************************************************
                       康威电子
功能：参考时钟25MHz，stm32f103rct6控制AD9833点频输出，LCD显示，
			按键调节频率，长按中间键切换波形及扫频！！！！！
			建议正弦波范围0-10M， 方波：0-500K，三角波：0-1M 。
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
#include "led.h"
#include "lcd.h"
#include "AD9833.h" 
#include "key.h"
#include "timer.h"
#include "task_manage.h"

char str[30];	//显示缓存
extern u8 _return;
int main(void)
{
	u16 i=0;

	MY_NVIC_PriorityGroup_Config(NVIC_PriorityGroup_2);	//设置中断分组
	delay_init(72);	//初始化延时函数
	LED_Init();	//初始化LED接口
	key_init();
	initial_lcd();
	LCD_Clear();
	delay_ms(300);
	LCD_Refresh_Gram();
	Timerx_Init(99,71);	//定时器
	LCD_Clear();
	
	
	AD9833_Init();//IO口及AD9833寄存器初始化
	AD9833_SetFrequencyQuick(1000,AD9833_OUT_SINUS);//正弦波
	//1、
	//后续代码涉及界面及按键交互功能，频率或其他参数会被重写，导致在此处更改参数无效
	//上述情况，取消下面注释即可，可直接更改频率及幅度，
//	AD9833_Init();//IO口及AD9833寄存器初始化
//	AD9833_SetFrequencyQuick(1000,AD9833_OUT_SINUS);//1000hz正弦波
//	while(1);
	
	//2、	
//	关于扫频的说明，长按中间键切换波形及扫频！！！！！
//	该程序的扫频功能利用定时器中断，不断写入自加的频率实现，
//	在timer.c的TIM4_IRQHandler中将自加后的频率写入


	while(1)
	{
		KeyRead();
		Set_PointFre(Keycode, 0);
		if(_return){_return=0;LCD_Refresh_Gram();}
		KEY_EXIT();
	}	
}




