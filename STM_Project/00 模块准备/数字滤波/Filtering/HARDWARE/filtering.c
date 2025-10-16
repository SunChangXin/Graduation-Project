#include "filtering.h"
#include "adc.h"

//一阶互补滤波
int firstOrderFilter(int newValue, int oldValue, float a)
{
	return a * newValue + (1-a) * oldValue;
}

//中值滤波算法
int middleValueFilter(int N)
{
    int value_buf[N];
    int i,j,k,temp;
    for( i = 0; i < N; ++i)
    {
        value_buf[i] = HAL_ADC_GetValue(&hadc1);					
    }
    for(j = 0 ; j < N-1; ++j)
    {
        for(k = 0; k < N-j-1; ++k)
        {
            //从小到大排序，冒泡算法
            if(value_buf[k] > value_buf[k+1])
            {
                temp = value_buf[k];
                value_buf[k] = value_buf[k+1];
                value_buf[k+1] = temp;
            }
        }
    }
		
    return value_buf[(N-1)/2];
}

//算术均值滤波算法
int averageFilter(int N)
{
   int sum = 0;
   short i;
   for(i = 0; i < N; ++i)
   {
        sum += HAL_ADC_GetValue(&hadc1);	
   }
   return sum/N;
}

//平滑均值滤波
#define N 10
int value_buf[N];
int sum=0;
int curNum=0;
int moveAverageFilter()
{
    if(curNum < N)
    {
        value_buf[curNum] = HAL_ADC_GetValue(&hadc1);
        sum += value_buf[curNum];
			  curNum++;
        return sum/curNum;
    }
    else
    {
        sum -= sum/N;
        sum += HAL_ADC_GetValue(&hadc1);
        return sum/N;
    }
}

//限幅平均滤波
#define A 50
#define M 12
int data[M];
int First_flag=0;
int LAverageFilter()
{
  int i;
  int temp,sum,flag=0;
  data[0]=HAL_ADC_GetValue(&hadc1);
	for(i=1;i<M;i++)
	{
		temp=HAL_ADC_GetValue(&hadc1);
		if((temp-data[i-1])>A||((data[i-1]-temp)>A))
		{
		  i--;flag++;
		}
		else
		{
			data[i]=temp;
		}
	}
  for(i=0;i<M;i++)
  {
    sum+=data[i];
  } 
  return  sum/M;
}

//卡尔曼滤波
int KalmanFilter(int inData)
{
		static float prevData = 0;                                 //先前数值
		static float p = 10, q = 0.001, r = 0.001, kGain = 0;      // q控制误差  r控制响应速度 
	
		p = p + q;
		kGain = p / ( p + r );                                     //计算卡尔曼增益
		inData = prevData + ( kGain * ( inData - prevData ) );     //计算本次滤波估计值
		p = ( 1 - kGain ) * p;                                     //更新测量方差
		prevData = inData;
		return inData;                                             //返回滤波值
}