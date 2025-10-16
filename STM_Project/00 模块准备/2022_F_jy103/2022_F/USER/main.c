#include "delay.h"
#include "sys.h"
#include "usart.h"
#include "timer.h"
#include "stm32_dsp.h"
#include "lcd.h"
#include "adc.h"
#include "fft.h"
#include "key.h"

#include "9851.h"
#include "9851_2.h"
#include "AD9854.h"

/*   AD采样引脚：PC1      */
/*   采样频率  ：100 000Hz   */
/*   幅度3.0VPP  直流偏移量1.5V */

//继电器控制为PC4

//ADC2测量解调信号幅度 PA0

//定时器测量频率 PA1

//float Sendbuf[54];

#define   N_FMf   7

#define   AM   1
#define   FM   2
#define   CM   3

u32 Fre; 

u32 wc_cnt = 0;
u16 wave_status = AM; //记录目前波形状态 默认在AM上 
u16 wave_status_now = AM; //记录目前波形状态 默认在AM上 

void auto_measure();
void show_mf();

//扫频程序
void scan_f()
{
	int i,j,cnt;
	u8 str[20];
	{
//		Fre = 9050000;
//		Fre = 9200000;
		Fre = 9450000;
	}
	
	POINT_COLOR=WHITE;	//画笔颜色
	BACK_COLOR=BLACK;   //背景色

	Write(Fre,Power_Down,0); //AD9851
	delay_ms(600);
	
	for(i=0;i<NPT;i++)
	{
		lBufInArray[i]=ADC_Value[i]<<16;
		
	}
	
	cr4_fft_1024_stm32(lBufOutArray, lBufInArray, NPT);    
	GetPowerMag();
	lcd_show_fft(lBufMagArray);
	cnt = peak_count2(lBufMagArray);
	
	wc_cnt = 0;
	
	for(j = 0; j<42; j++)
	{
		
		// 扫频
		if (cnt == 0)
		{
			wc_cnt = wc_cnt + 1;
			sprintf((char *)str,"  wc:%d  ",wc_cnt);
			
			LCD_ShowString(260,458,60,30,12,(uint8_t *)str);
			Fre += 500000;
			
			Write(Fre,Power_Down,0); //AD9851
			delay_ms(600);
			
			for(i=0;i<NPT;i++)
			{
				lBufInArray[i]=ADC_Value[i]<<16;
				
			}
			cr4_fft_1024_stm32(lBufOutArray, lBufInArray, NPT);    
			GetPowerMag();
			cnt = peak_count2(lBufMagArray);
		}
	}
	
}


//AM,FM波形判断 
void wave_judge()
{
		int i,j,cnt;
		u32 Fre2;
	
		POINT_COLOR=WHITE;	//画笔颜色
		BACK_COLOR=BLACK;  //背景色 
	
		for(i=0;i<NPT;i++)
		{
			lBufInArray[i]=ADC_Value[i]<<16;
			
		}
		cr4_fft_1024_stm32(lBufOutArray, lBufInArray, NPT);    
		GetPowerMag();

		cnt = peak_count2(lBufMagArray);
		
		if(cnt <= 1)
		{
			wave_status = CM;
			LCD_Fill(260,0, 320,170, BLACK); 
			LCD_ShowString(270,180,25,30,24," CW ");
		}
		
		else if(cnt <= 3)
		{
			wave_status = AM;
			GPIO_ResetBits(GPIOC,GPIO_Pin_4);	
			LCD_ShowString(270,180,25,30,24," AM ");
			
//			调频 为了后续解调
//			Fre2 = 9050000+500000*wc_cnt;
//			AD9854_SetSine(Fre2,4000);

			delay_ms(500);
			
			show_ma();//计算ma
		}
		
		else
		{
			wave_status = FM;
			
			// 控制继电器
			GPIO_SetBits(GPIOC,GPIO_Pin_4);	
			
			LCD_ShowString(270,180,25,30,24," FM ");
			
			//65K采样频率
			//切换至10.7MHZ
			//Fre2 = 20200000+500000*wc_cnt;
			
//			调频 为了后续解调
//			Fre2 = 20200000+500000*wc_cnt;
//			AD9854_SetSine(Fre2,4000);
			
			delay_ms(500);
			
			//计算 mf 和频偏
			show_mf();
		}
	
}


//FM解调频率测量  采用定时器比较测频 幅度需大于1.9V
int FM_fre()
{
	int i,j;
	int tmd[N_FMf];
	int temp;
	for(j=0;j<N_FMf;j++)
	{
		  tmd[j] = (int)((float)(2000000)/(float)(Rising_Last-Falling));
		
	}
	
	//冒泡排序
	for( i=0;i<N_FMf-1;i++)
	{
        for( j=0;j<N_FMf-1-i;j++)
		{
			if(tmd[j] > tmd[j+1])
			{
				temp = tmd[j];
				tmd[j] = tmd[j+1];
				tmd[j+1] = temp;
			}
		}
	}
	return tmd[4];
}

//计算mf
void show_mf()
{
	float FM_f,range;
	float mf = 0,f_sh = 0;
	
	//设置比例系数K
	float K[8] = {35.5,44,53,61,70,78,87,96};
	u8 str[20];
	
	//测频率
	FM_f = FM_fre();
	//测幅度
	range = Get_Adc_Average(ADC_Channel_0,5);
	
	{
		//9.9k及以上
		if(FM_f >9900)
		{
			f_sh = range*K[7];
			mf = f_sh/FM_f;
			
		}
		//8.9-9.9
		else if(FM_f >8900)
		{
			f_sh = range*K[6];
			mf = f_sh/FM_f;
		}
		//7.9-8.9
		else if(FM_f >7900)
		{
			f_sh = range*K[5];
			mf = f_sh/FM_f;
		}
		//6.9-7.9
		else if(FM_f >6900)
		{
			f_sh = range*K[4];
			mf = f_sh/FM_f;
		}
		//5.9-6.9
		else if(FM_f >5900)
		{
			f_sh = range*K[3];
			mf = f_sh/FM_f;
		}
		//4.9-5.9
		else if(FM_f >4900)
		{
			f_sh = range*K[2];
			mf = f_sh/FM_f;
		}
		//3.9-4.9
		else if(FM_f >3900)
		{
			f_sh = range*K[1];
			mf = f_sh/FM_f;
		}
		//2.9-3.9
		else if(FM_f >2900)
		{
			f_sh = range*K[0];
			mf = f_sh/FM_f;
		}
	}
	
	sprintf((char *)str,"F:%d     ",(int)FM_f);
	LCD_ShowString(260,320,60,30,12,(uint8_t *)str);
		 
	sprintf((char *)str,"A:%d  ",Get_Adc_Average(ADC_Channel_0,5));
	LCD_ShowString(260,340,60,30,12,(uint8_t *)str);
	
	LCD_ShowString(275,0,30,20,16,"mf:");
	LCD_ShowFloat3(260,30,mf,6,16);
		
	LCD_ShowString(275,60,30,20,16,"f_sh");
	//LCD_ShowFloat5(250,90,f_sh,6,12);
	LCD_ShowxNum(270,90,(u32)f_sh,5,12,0);

		
	LCD_Fill(260, 120, 320,170, BLACK); 
}

int main(void)
{
	int i,cnt2;
	u8 key;
	u32 Fre3; 
	u8 str[20];
	delay_init();	    	 //延时函数初始化	  
	uart_init(115200);	
	LCD_Init();
	KEY_Init();
	
	{
		//TIM1_Int_Init(83-1,2-1);//455kHz 
		//TIM1_Int_Init(126-1,2-1);//300kHz 
		TIM1_Int_Init(189-1,2-1);//200kHz 
	}
	
	TIM2_Cap_Init();

	AD9851_Configuration(); 
	delay_ms(50);


	Adc_Init2();			//ADC初始化  获取FM调制波幅值
	
	ADC1_Configuration();   //ADC初始化  判断调制方式 FFT
	DMA_Configuration();    //DMA初始化
 
	LCD_Clear(BLACK);
	POINT_COLOR=WHITE;	  	//画笔颜色
	BACK_COLOR=BLACK; 	  	//背景色
	
	 {
//		Fre = 9050000;
//		Fre = 9200000;
		Fre = 9450000;
	 }

	delay_ms(50);	
	 
	Write(Fre,Power_Down,0); 	//AD9851 混频

	while(1)
	{	
		//自动测量 
			
			{
				
					delay_ms(500);
					
					for(i=0;i<NPT;i++)
					{
						lBufInArray[i]=ADC_Value[i]<<16;
						
					}
					cr4_fft_1024_stm32(lBufOutArray, lBufInArray, NPT);    
					GetPowerMag();
					lcd_show_fft(lBufMagArray);
				
					cnt2 = 	peak_count2(lBufMagArray);
					// 此时 cnt2 只可能是 0 或 >=3
					
					if(cnt2 == 0) 		// CM 或 AM
					{
						scan_f();
						wave_judge();
//						cnt2 = 	peak_count2(lBufMagArray);
					}
					
					else				// FM 或 AM
					{
						if(cnt2 <= 3)
							  wave_status_now = AM;
						if(cnt2 > 3)
							  wave_status_now = FM;
						
						
						if(wave_status == AM && wave_status_now == AM)
						{
								
							show_ma();
							wave_status = AM;
						}
						
						if(wave_status == FM&& wave_status_now == FM)
						{
							
							show_mf();
							wave_status = FM;
						}
						
						
						if(wave_status == AM && wave_status_now == FM)
						{
							GPIO_ResetBits(GPIOC,GPIO_Pin_4);	
							scan_f();
							wave_judge();
							 
						}
						
						if(wave_status == FM && wave_status_now == AM)	
						{
							GPIO_ResetBits(GPIOC,GPIO_Pin_4);	
							scan_f();
							wave_judge();
						}
											
			 }
					
	
		}
			
	}	 
	
}
 




