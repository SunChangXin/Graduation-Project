#include "stm32f10x.h"                  // Device header
#include "Delay_J.h"
#include "OLED.h"

uint8_t KEY [4];         // 获取输入数字
uint8_t CONFIRM = 0; // 标志位

/**
  * 函    数：按键初始化
  * 参    数：无
  * 返 回 值：无
  */
void Key_Init(void)
{
	/*开启时钟*/
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOB, ENABLE);		//开启GPIOB的时钟
	
	/*GPIO初始化*/
	GPIO_InitTypeDef GPIO_InitStructure;
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IPU;
	// GPIO_InitStructure.GPIO_Pin = GPIO_Pin_0 | GPIO_Pin_12 | GPIO_Pin_13 | GPIO_Pin_14 | GPIO_Pin_15;
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
	
	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_0;
	GPIO_Init(GPIOB, &GPIO_InitStructure);	
	
	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_12;
	GPIO_Init(GPIOB, &GPIO_InitStructure); 
	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_13;
	GPIO_Init(GPIOB, &GPIO_InitStructure); 
	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_14;
	GPIO_Init(GPIOB, &GPIO_InitStructure); 
	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_15;
	GPIO_Init(GPIOB, &GPIO_InitStructure);                        //将PB0和PB12-15引脚初始化为上拉输入
}

/**
  * 函    数：按键获取键码
  * 参    数：无
  * 返 回 值：按下按键的键码值，范围：0~2，返回0代表没有按键按下
  * 注意事项：此函数是阻塞式操作，当按键按住不放时，函数会卡住，直到按键松手
  */
uint8_t Key_GetNum(void)
{
	KEY[0] = 0;		//定义变量，默认键码值为0
	KEY[1] = 0;
	KEY[2] = 0;
	KEY[3] = 0;
	CONFIRM = 0;	
	
	while(CONFIRM == 0){
		
		if (GPIO_ReadInputDataBit(GPIOB, GPIO_Pin_12) == 0)			//读PB12输入寄存器的状态，如果为0，则代表按键12按下
		{
			Delay_ms(1000);											//延时消抖
			while (GPIO_ReadInputDataBit(GPIOB, GPIO_Pin_12) == 0);	//等待按键松手
			Delay_ms(200);											//延时消抖
			KEY[3] = 1;												//设置键码
		}
		
		if (GPIO_ReadInputDataBit(GPIOB, GPIO_Pin_13) == 0)			//读PB13输入寄存器的状态，如果为0，则代表按键13按下
		{
			Delay_ms(20);											//延时消抖
			while (GPIO_ReadInputDataBit(GPIOB, GPIO_Pin_13) == 0);	//等待按键松手
			Delay_ms(20);											//延时消抖
			KEY[2] = 1;												//设置键码
		}
		
		if (GPIO_ReadInputDataBit(GPIOB, GPIO_Pin_14) == 0)			//读PB14输入寄存器的状态，如果为0，则代表按键14按下
		{
			Delay_ms(20);											//延时消抖
			while (GPIO_ReadInputDataBit(GPIOB, GPIO_Pin_14) == 0);	//等待按键松手
			Delay_ms(20);											//延时消抖
			KEY[1] = 1;												//设置键码
		}
		
		if (GPIO_ReadInputDataBit(GPIOB, GPIO_Pin_15) == 0)			//读PB15输入寄存器的状态，如果为0，则代表按键15按下
		{
			Delay_ms(20);											//延时消抖
			while (GPIO_ReadInputDataBit(GPIOB, GPIO_Pin_15) == 0);	//等待按键松手
			Delay_ms(20);											//延时消抖
			KEY[0] = 1;												//设置键码
		}
		
		if (GPIO_ReadInputDataBit(GPIOB, GPIO_Pin_0) == 0)			//读PB0输入寄存器的状态，如果为0，则代表按键0按下
		{
			Delay_ms(20);											//延时消抖
			while (GPIO_ReadInputDataBit(GPIOB, GPIO_Pin_0) == 0);	//等待按键松手
			Delay_ms(20);											//延时消抖
			CONFIRM = 1;											//设置键码													//置键码为1
		}
		
		
	}
	
	OLED_ShowNum(3, 1, KEY[0], 5);
	OLED_ShowNum(3, 1, KEY[1], 4);
	OLED_ShowNum(3, 1, KEY[2], 3);
	OLED_ShowNum(3, 1, KEY[3], 2);
	
	uint8_t TEMP = KEY[0] + KEY[1]*2 + KEY[2]*4 + KEY[3]*8;
	OLED_ShowNum(4, 1, TEMP, 5);
	return TEMP;			
}




