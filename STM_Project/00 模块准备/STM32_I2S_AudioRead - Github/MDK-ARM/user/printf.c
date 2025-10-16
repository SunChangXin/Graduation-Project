/**
 * @file   printf.c
 * @brief  printf驱动程序
 *         重定义了stdio模块中的printf函数用到的“int fputc(int ch, FILE *f)”，该函数名称和参数不可随意更改。
 *         该文件无需头文件
 * @author 王晓荣
 * @version 
 * @date   2015-10-13
 */
#include "stm32f1xx_hal.h"
#include <stdio.h>
/** 定义printf使用的串口 */
extern UART_HandleTypeDef huart1;

/**
 * @brief 仅供printf函数调用的函数
 * @param ch 字符
 * @param f  文件指针
 */
int fputc(int ch, FILE *f)
{
  HAL_UART_Transmit(&huart1, (uint8_t *)&ch, 1, 0xFFFF);	 
	return ch;
}







