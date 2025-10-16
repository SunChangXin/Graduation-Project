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
#include "DAC.h"
#include "AD.h"

#define N 1024

uint8_t RxData;

union
{
  struct
  {
    uint8_t com[4];
  }ComInfo;
  
  float data;
	
}D_data;


int main(void)
{
	/*模块初始化*/
	OLED_Init();		//OLED初始化
	
	
	
//	DAC_InitConfig();

//	OLED_ShowString(1, 1, "NUM :0000");
//	
//	DAC_TriangularWave(2047, 10, 100, 1);
//	DAC_SetVoltage(3);
	
	OLED_ShowString(1, 1, "NUM :0000");
	
	AD_Init();
//	AD9833_SetFrequencyQuick(1000.0,AD9833_OUT_SINUS);// Sin
//	AD9833_SetFrequencyQuick(1000.0,AD9833_OUT_TRIANGLE);//三角
//	AD9833_SetFrequencyQuick(1000.0,AD9833_OUT_MSB);//方波
	
	/*串口初始化*/
	Serial_Init();		//串口初始化
	
	OLED_ShowString(3, 1, "NUM :0000");
	
	for(int i=0;i<N;i++)
	{
      testInput_f32_1024Hz[i]= AD_GetValue();//5hz和200hz的正弦波信号
	}
	OLED_ShowString(2, 1, "NUM :0000");
	while(1)
	{		
		
		arm_fir_f32_lp();
		
		if (Serial_GetRxFlag() == 1)			//检查串口接收数据的标志位
		{
			RxData = Serial_GetRxData();		//获取串口接收的数据
			OLED_ShowNum(1, 5, RxData, 5);
			if(RxData==10)// 判断握手信号是否到来
			{		
				delay_ms(10);
				for(int i=0;i<1000;i++)
				{
					D_data.data=testInput_f32_1024Hz[i];//将数据赋给共同体
					OLED_ShowNum(3, 5, D_data.data, 5);
					Serial_SendArray(D_data.ComInfo.com, 4);//将4个字节发送出去
				}		
			}
		}			
	}
	
}




