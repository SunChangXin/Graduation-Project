/**
  ******************************************************************************
  * @file    main.c
  * $Author: wdluo $
  * $Revision: 17 $
  * $Date:: 2012-07-06 11:16:48 +0800 #$
  * @brief   主函数.
  ******************************************************************************
  * @attention
  *
  *<h3><center>&copy; Copyright 2009-2012, ViewTool</center>
  *<center><a href="http:\\www.viewtool.com">http://www.viewtool.com</a></center>
  *<center>All Rights Reserved</center></h3>
  * 
  ******************************************************************************
  */
/* Includes ------------------------------------------------------------------*/
#include "main.h"
#include "usart.h"
#include "fft.h"
#include <math.h>
/* Private typedef -----------------------------------------------------------*/
/* Private define ------------------------------------------------------------*/
#define		NPT		128	//FFT采样点数，该点数应该为2的N次方，不满足此条件时应在后面补0
#define		F1		50	//测试信号1频率
#define		A1		3	//测试信号1幅度
#define		P1		30	//测试信号1相位
#define		F2		75	//测试信号2频率
#define		A2		1.5	//测试信号2幅度
#define		P2		90	//测试信号2相位
/* Private macro -------------------------------------------------------------*/
float my_sin_tab[NPT/4+1];	//定义正弦表的存放空间
struct compx s[NPT];    //FFT输入和输出：从S[0]开始存放，根据大小自己定义
/* Private variables ---------------------------------------------------------*/
/* Private function prototypes -----------------------------------------------*/
/* Private functions ---------------------------------------------------------*/

/**
  * @brief  串口打印输出
  * @param  None
  * @retval None
  */
int main(void)
{
	int i,t;
	SystemInit();//系统时钟初始化
	USART_Configuration();//串口1初始化
	printf("\x0c\0");printf("\x0c\0");//超级终端清屏
	printf("\033[1;40;32m");//设置超级终端背景为黑色，字符为绿色
	printf("\r\n*******************************************************************************");
	printf("\r\n************************ Copyright 2009-2012, ViewTool ************************");
	printf("\r\n*************************** http://www.viewtool.com ***************************");
	printf("\r\n***************************** All Rights Reserved *****************************");
	printf("\r\n*******************************************************************************");
	printf("\r\n");
	
	create_sin_tab(my_sin_tab,NPT);					//生成正弦表加快FFT速度，该表只需要一次性生成
	//生成测试信号，该信号由两个正弦信号和一个直流信号合成
	for(t=0;t<NPT;t++)                           	//给结构体赋值
	{
		s[t].real=2+A1*cos(2*PI*F1*t/NPT-PI*P1/180)+A2*cos(2*PI*F2*t/NPT+PI*P2/180); 	//实部为正弦波FFT_N点采样，赋值为1
		s[t].imag=0;                                //虚部为0
	}
	//进行FFT变换
	FFT(s);                                        	//进行快速福利叶变换
	//计算各个频点的幅度值
	for(i=0;i<NPT;i++){                           	//求变换后结果的模值，存入复数的实部部分
		s[i].real=sqrt(s[i].real*s[i].real+s[i].imag*s[i].imag)/(i==0?NPT:NPT/2);
		if((i>0)&&(i%8==0)){
			printf("\r\n");
		}
		printf("%8.5f ",s[i].real);
	}

	while(1)
	{
		//检查接收数据完成标志位是否置位	
		if(USART_GetFlagStatus(USART1, USART_IT_RXNE) != RESET)
		{
		//将接收到的数据发送出去，对USART_DR的读操作可以将USART_IT_RXNE清零。
		printf("%c",USART_ReceiveData(USART1));
		}

	}
}

#ifdef  USE_FULL_ASSERT
/**
  * @brief  报告在检查参数发生错误时的源文件名和错误行数
  * @param  file 源文件名
  * @param  line 错误所在行数 
  * @retval None
  */
void assert_failed(uint8_t* file, uint32_t line)
{
    /* 用户可以增加自己的代码用于报告错误的文件名和所在行数,
       例如：printf("错误参数值: 文件名 %s 在 %d行\r\n", file, line) */

    /* 无限循环 */
    while (1)
    {
    }
}
#endif

/*********************************END OF FILE**********************************/
