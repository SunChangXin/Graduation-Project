/**********************************************************
* @ File name -> usart.h
* @ Version   -> V1.0
* @ Date      -> 12-26-2013
* @ Brief     -> 系统串口设置相关的函数
**********************************************************/

#ifndef _usart_h_
#define _usart_h_

/**********************************************************
                     外部函数头文件                        
**********************************************************/

#include "stdio.h"	//printf函数头文件
#include "stm32f10x.h"   
#include "sys.h" 

#define USART_REC_LEN  			200  	//定义最大接收字节数 200
#define EN_USART1_RX 			1		//使能（1）/禁止（0）串口1接收
	  	
extern u8  USART_RX_BUF[USART_REC_LEN]; //接收缓冲,最大USART_REC_LEN个字节.末字节为换行符 
extern u16 USART_RX_STA;         		//接收状态标记	
//如果想串口中断接收，请不要注释以下宏定义
void uart_init(u32 bound);


#endif

