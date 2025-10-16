#include "fft.h"
#include "math.h"
#include "lcd.h"
#include "delay.h"
#include "string.h"
#include "stdio.h"
#include "adc.h"
#include "stm32_dsp.h"
#include "hc05.h"
#include "usart3.h"

u32 lBufInArray[NPT];
u32 lBufOutArray[NPT];
u32 lBufMagArray[NPT];
u32 lBUFPHASE[NPT];
u8 str[20];
uint16_t Sendbuf[4];


float PI2=6.28318530717959;
float PI=3.14159265358979;
u32 Fs=65000;      
float Fmax;
float ma;

/******************************************************************
函数名称:GetPowerMag()
函数功能:计算各次谐波幅值                          short 的范围，是-32767 到 32767 。也就是 -(2^15 - 1)到(2^15 - 1)。
参数说明:
备　　注:先将lBufOutArray分解成实部(X)和虚部(Y)，然后计算幅值(sqrt(X*X+Y*Y)
*******************************************************************/

void GetPowerMag(void)
{
    signed short lX,lY;                                                  //算频率的话Fn=i*Fs/NPT		//由于此处i是从0开始的，所以不需要再减1
    float X,Y,Mag;                                                      
    unsigned short i;
    for(i=0; i<NPT/2; i++)                                                  //经过FFT后，每个频率点处的真实幅值  A0=lBufOutArray[0]/NPT
    {                                                                       //                                 Ai=lBufOutArray[i]*2/NPT
        lX  = (lBufOutArray[i] << 16) >> 16;  //lX  = lBufOutArray[i];
        lY  = (lBufOutArray[i] >> 16);
			                                 
        X = NPT * ((float)lX) / 32768;//除以32768再乘65536是为了符合浮点数计算规律,不管他
        Y = NPT * ((float)lY) / 32768;
        Mag = sqrt(X * X + Y * Y) / NPT;
        if(i == 0)
            lBufMagArray[i] = (unsigned long)(Mag * 32768);   //0Hz是直流分量，直流分量不需要乘以2
        else
            lBufMagArray[i] = (unsigned long)(Mag * 65536);
    }
}


//显示波形网格
void griddisplay()
{
	int i;
	POINT_COLOR = WHITE;
	
	 //横坐标网格
	for(i = 0;i <=6;i++)
	{
	LCD_DrawLine(i*30,0, i*30,480); 
	}
	for(i = 0;i < 16;i++)
	{
	LCD_DrawLine(0,i*30, 180,i*30); 
	}
	
	LCD_DrawLine(0,479, 180,479); 
	 
	//LCD_DrawLine(0,0, 0,480);    
	
	
	
	
}

//波形显示
//传入参数为ADC实时采样的电压值
 void wavedisplay(u16 *p)
{

	u16 *pp = p+1;             //p+1相当于我直接把0HZ部分滤掉了
	unsigned int i = 0;

	LCD_Fill(0, 0, 220,480, BLACK);   //其他就黑色
	griddisplay();
	POINT_COLOR=YELLOW;	//画笔颜色
	for(i = 1;i<480;i++)
	{
		
		LCD_DrawLine((*pp*0.048), i, *(pp+1)*0.048, (i+1));     //有效部分白色       
		
    pp++;
		
	}
	
}

void lcd_show_fft(unsigned int *p)
{
	unsigned int *pp = p+1;             //p+1相当于我直接把0HZ部分滤掉了
	unsigned int i = 0;
	for(i = 0;i<480;i++)
	{
	//分辨率hz
	//每个小矩形宽度为1，其实这里没有显示完所有的
    //512个值，频率可达到 Hz	
    //0.11是我根据屏幕显示高度调整的一个值,频谱闪的话记得改这个值！！！！！ 320*240屏幕		320*=780
		
		LCD_Fill(0,        i, *pp*0.11, (i+1), WHITE);     	//有效部分白色       
		LCD_Fill(*pp*0.11, i, 250,       (i+1), BLACK);   	//其他就黑色
		pp++;
		
	}
	
}


/***********************************************
找最大值，次大值……对应的频率，分析波形  //适用于任何波形，分析最大 次大 等等波形
*************************************************/
void select_max(float *f,float *a,unsigned int ij,unsigned int *flag)
{
	int i,j;

	float aMax =0.0,aSecondMax = 0.0;
	float aMax_pr =0.0,aSecondMax_pr = 0.0;
	float fMax =0.0,fSecondMax = 0.0;

	int nMax=0,nSecondMax=0;
	
	for ( i = 1; i < ij; i++)//i必须是1，是0的话，会把直流分量加进去！！！！
    {
        if (a[i]>aMax)
        {
            aMax = a[i]; 		 				
			nMax=i;
			fMax=f[nMax];

        }
    }
		
	for ( i=1; i < ij; i++)
    {
		if (nMax == i)
		{
			continue;
		}
        if (a[i]>aSecondMax&&a[i]>a[i+1]&&a[i]>a[i-1])
        {
            aSecondMax = a[i]; 					
			nSecondMax=i;
			fSecondMax=f[nSecondMax];
        }
    }
		
		
	aSecondMax_pr =sqrt(lBufMagArray[flag[nSecondMax]]*lBufMagArray[flag[nSecondMax]]+lBufMagArray[flag[nSecondMax]+1]*lBufMagArray[flag[nSecondMax]+1]
											+lBufMagArray[flag[nSecondMax]-1]*lBufMagArray[flag[nSecondMax]-1]+lBufMagArray[flag[nSecondMax]-2]*lBufMagArray[flag[nSecondMax]-2]
											+lBufMagArray[flag[nSecondMax]+2]*lBufMagArray[flag[nSecondMax]+2])*(3.3/4096);

	ma = ((aSecondMax_pr/aMax)*2);
}

//波峰计数
int peak_count(unsigned int *a)
{
	 int i,j,count = 0;
		unsigned int *pp = a; 
//    float aMax =0.0,aSecondMax = 0.0,aThirdMax = 0.0,aFourthMax=0.0,aFifthMax=0.0;
//	  int nMax=0,nSecondMax=0,nThirdMax=0,nFourthMax=0,nFifthMax = 0;
		for ( i=1; i < NPT/2; i++)
    {
			
        if ((a[i]>a[i+1])&&(a[i]>a[i-1])&&(a[i]>50))
        {
					count++;
        }
				pp++;
    }
			LCD_ShowFloat3(260,16*17,count,4,12);
		  LCD_ShowString(245,270,25,30,12,"cnt:");
	return count;
}

//扫频用，忽略小波峰
int peak_count2(unsigned int *a)
{
	int i,j,count = 0;
	unsigned int *pp = a; 
	unsigned int aMax =0;

	for ( i=1; i < 150; i++)
    {
			
		if (a[i]>aMax)
        {
			aMax = a[i];
        }
				
        if ((a[i]>a[i+1])&&(a[i]>a[i-1])&&(a[i]>80))
        {
			count++;
        }
		
		pp++;
    }
	
	if(aMax <200)
		count = 0;		// 小波峰
	if(aMax >1500)
		count = 1;   	// CM

	return count;
}

void select_max2(float *f,float *a,unsigned int ij)
{
	  int i;		
	 float aMax =0.0;
	  for ( i = 1; i < ij; i++)//i必须是1，是0的话，会把直流分量加进去！！！！
    {
        if (a[i]>aMax)
        {
					aMax = a[i];
				  Fmax = f[i];
        }
    }
		 LCD_ShowString(300,240,25,30,12,"FMf:");
		LCD_ShowFloat3(300,16*15,Fmax,4,12);
  
	
}

void lcd_print_fft(unsigned int *p)
{
	
	unsigned int *pp = p;            
	unsigned int i = 0, j = 0, flag[NPT/2] ={0} ;
	float f[NPT/2]={0.00},a[NPT/2]={0.00};
	
	for(i=0;i<NPT/2;i++)
	{
		if(*pp>10)
		{
			f[j]=(float)i*Fs/NPT;

			a[j]=(float)*pp*(3.3/4096);

			flag[j] = i;

			j++;
		}
		pp++;
	}
	select_max(f,a,j,flag);
	
}


void select_max_fft(unsigned int *p)
{
	
	unsigned int *pp = p;             //p+1相当于我直接把0HZ部分滤掉了(改成了不过滤)
	unsigned int i = 0,j = 0;
  float f[NPT/2]={0.00},a[NPT/2]={0.00};
	for(i=0;i<NPT/2;i++)
  {
	  if(*pp>10)//看情况调，若是数字太跳就调大,把小的幅值过滤，以防干扰
		{
			f[j]=(float)i*Fs/NPT;
			//LCD_ShowFloat4(0,j*12,f[j],6,12);
			a[j]=(float)*pp*(3.3/4096);
			
		
			//LCD_ShowFloat4(100,j*12,a[j],2,12);
			j++;
		}
		pp++;
  }
	select_max2(f,a,j);
	
}




//使用中值滤波算法计算TMD
void show_ma()
{
	int i,j;
	float tmd[N_TMD];
	float temp;
	float ma_now;
	
	for(j=0;j<N_TMD;j++)
	{
		for(i=0;i<NPT;i++)
		{
		  lBufInArray[i]=ADC_Value[i]<<16;
		}
		cr4_fft_1024_stm32(lBufOutArray, lBufInArray, NPT);    
		GetPowerMag();
		
		lcd_print_fft(lBufMagArray);
		
		tmd[j] = ma;
	}
	
	//冒泡排序
	for( i=0;i<N_TMD-1;i++)
	{
        for( j=0;j<N_TMD-1-i;j++)
		{
			if(tmd[j] > tmd[j+1])
			{
				temp = tmd[j];
				tmd[j] = tmd[j+1];
				tmd[j+1] = temp;
			}
		}
	}


	LCD_Fill(260, 0, 320,119, BLACK); 
	LCD_Fill(260, 320, 320,360, BLACK); 

	LCD_ShowString(275,120,30,20,16,"ma:");
	
	if(tmd[4] >0.89)
		ma_now = tmd[4]-0.03;
	if(tmd[4] <=0.89)
		ma_now = tmd[4]+0.08;
	
	LCD_ShowFloat3(260,150,ma_now,6,16);
}
