#include "stm32f4xx.h"                  // Device header
#include "delay.h"
#include "usart.h"
#include "table_fft.h"

#include "stm32_dsp.h"
#include "math.h"
#include "Timer.h"
#include "ADCDMA.h"


u16 i;
#define NPT 256
long InBufArray[NPT];
long OutBufArray[NPT]={0};
long lBufMagArray[NPT/2];
long  MagBufArray[NPT/2];

void GetPowerMag()
{
    signed short lX,lY;
    float X,Y,Mag;
    unsigned short i;
    for(i=0; i<NPT/2; i++)
    {
        lX  = (InBufArray[i] << 16) >> 16;
        lY  = (OutBufArray[i] >> 16);
        
        //除以32768再乘65536是为了符合浮点数计算规律
        X = NPT * ((float)lX) / 32768;
        Y = NPT * ((float)lY) / 32768;
        Mag = sqrt(X * X + Y * Y) / NPT;
        if(i == 0)
            MagBufArray[i] = (unsigned long)(Mag * 32768);
        else
            MagBufArray[i] = (unsigned long)(Mag * 65536);
    }
}

int main(){
	
	
	delay_init(168);
	uart_init(115200);
	printf("Start !\r\n");
	TIM2_Init(5-1, 525-1);//fs=32KHz	fs=84MHz/(arr*psc)
	AD3_Init();	
	delay_ms(10);

	while(1){
		
		ADC_DMA_Trigger();											//每次都要重新触发，否则只采样一波数据(NPT个AD值)便停止了
		
		for(i=0; i<NPT; i++){
			
			InBufArray[i] = ((signed short)(AD3_Value[i]-2048)) << 16;	//将AD值移至实部
			printf("%d\r\n",AD3_Value[i]);							//打印AD值（片内12位AD：0~4095）
			
		}
		
		cr4_fft_256_stm32(OutBufArray, InBufArray, NPT);//FFT运算
		for(i=0; i<NPT/2; i++){									
			printf("%d:%d\r\n",i,OutBufArray[i]);					//打印幅值
		}
		
 		GetPowerMag();
		for(i=0; i<NPT/2; i++){									
			printf("%d:%d\r\n",i,MagBufArray[i]);					//打印幅值
		}
		delay_ms(5000);
		
}

}



