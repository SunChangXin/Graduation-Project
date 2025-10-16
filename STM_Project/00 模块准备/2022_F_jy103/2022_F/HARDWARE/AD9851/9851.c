/***
**优化
***IR:测量输出电压->与输出没有直接关系
***/
#include"9851.h"

//void delay(u8 i);
//int main(void)
//	{
//		RCC_Configuration();
//		AD9851_Configuration();
//			
//		Write(10_M,Power_Down,0);
//		while(1);
//	}
void RCC_Configuration(void)
	{	
		ErrorStatus HSEStartUpStatus;
		RCC_DeInit();
		RCC_HSEConfig(RCC_HSE_ON);
		HSEStartUpStatus = RCC_WaitForHSEStartUp();
		if(HSEStartUpStatus == SUCCESS)
		{
			RCC_HCLKConfig(RCC_SYSCLK_Div1);
			RCC_PCLK2Config(RCC_HCLK_Div1);
			RCC_PLLConfig(RCC_PLLSource_HSE_Div1, RCC_PLLMul_2);
			RCC_PLLCmd(ENABLE);
			while(RCC_GetFlagStatus(RCC_FLAG_PLLRDY) == RESET);
			RCC_SYSCLKConfig(RCC_SYSCLKSource_PLLCLK);
			while(RCC_GetSYSCLKSource() != 0x08)	 ;
			RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA,ENABLE);
		}
	}
void AD9851_Configuration(void)
	{
		
		GPIO_InitTypeDef  GPIO_InitStructure;
		RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOE,ENABLE);//使能PORTA,PORTE时钟
		
		GPIO_InitStructure.GPIO_Pin=GPIO_Pin_1|GPIO_Pin_2|GPIO_Pin_6|GPIO_Pin_0;
		GPIO_InitStructure.GPIO_Mode=GPIO_Mode_Out_PP;
		GPIO_InitStructure.GPIO_Speed=GPIO_Speed_50MHz; 
		GPIO_Init(GPIOE,&GPIO_InitStructure);  
	}
/*void delay(u8 i)
	{
		while(i--);
	}*/
void Write(u32 Freq,FlagStatus Power_Flag,u8 Cmd)
	{	
		u8 i;
		u32 Sys_CLK=30000000;//30MHz			
		FlagStatus Multiplier_Flag;
		
		if(Freq<=1000000)Multiplier_Flag=Multiplier_DISABLE;
			else if(Freq>1000000)Multiplier_Flag=Multiplier_ENABLE;
		//2^32=4294967296
		if(Multiplier_Flag==Multiplier_ENABLE)Sys_CLK=180000000;//180MHz
		Freq=Freq*4294967296/Sys_CLK; //先乘法后除法，效率高；
		/*Figure 14*/
		W_CLK_0;
		FQ_UP_0;
		REST_0;
		REST_1;
		REST_0;
		W_CLK_1;
		W_CLK_0;
		FQ_UP_1;
		FQ_UP_0;
		//0~31
		for(i=0;i<32;i++)
			{
			 	if(Freq&0X1)
					Data_1;
					else Data_0;
				W_CLK_1;
				W_CLK_0;
				Freq>>=1;		
			}
		//32
		if(Multiplier_Flag==SET)
			Data_1;
			else Data_0;
		W_CLK_1;
		W_CLK_0;
		//33
		Data_0;
		W_CLK_1;
		W_CLK_0;
		//34
		if(Power_Flag==SET)
			Data_1;
			else Data_0;
		W_CLK_1;
		W_CLK_0;
		//35,36,37,38,39
		for(i=0;i<5;i++)
			{
			 	if(Cmd&0x0001)
					Data_1;
					else Data_0;
				W_CLK_1;
				W_CLK_0;
				Cmd>>=1;		
			}
	   	FQ_UP_1;
		FQ_UP_0;
	}	
	
	
	
	
	
	