#include "AD9833.h"
#include "delay.h"
#include "sys.h"

 int main(void)
 {	
	delay_init();	    	 //延时函数初始化	  
	AD9833_Init();		  	//初始化与LED连接的硬件接口
	AD9833_WaveSeting(2000.0,0,SIN_WAVE,0 );//2KHz,	频率寄存器0，正弦波输出 ,初相位0 
    AD9833_AmpSet(100);	//设置幅值，幅值最大 255
	while(1)
	{
		
		delay_ms(100);
	}
 }

