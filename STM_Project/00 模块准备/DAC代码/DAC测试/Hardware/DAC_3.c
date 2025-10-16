#include "stm32f10x_dac.h"
#include "stm32f10x_dma.h"
#include "stm32f10x_gpio.h"
#include "stm32f10x_rcc.h"
#include "stm32f10x_tim.h"
#include <math.h>  // 包含数学库头文件

uint16_t g_dac_sin_buf[4096];  /* 发送数据缓冲区 */

/* DAC DMA输出波形初始化函数 */
void dac_dma_wave_init(void) {
    DMA_InitTypeDef DMA_InitStructure;
    DAC_InitTypeDef DAC_InitStructure;
    GPIO_InitTypeDef GPIO_InitStructure;

    /* Enable clocks */
    RCC_AHBPeriphClockCmd(RCC_AHBPeriph_DMA2, ENABLE);
    RCC_APB1PeriphClockCmd(RCC_APB1Periph_DAC, ENABLE);
    RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA, ENABLE);

    /* Configure DAC output pin (PA4) */
    GPIO_InitStructure.GPIO_Pin = GPIO_Pin_4;
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AIN;
    GPIO_Init(GPIOA, &GPIO_InitStructure);

    /* DMA2 channel3 configuration */
    DMA_DeInit(DMA1_Channel1);
    DMA_InitStructure.DMA_PeripheralBaseAddr = (uint32_t)&DAC->DHR12R1;
    DMA_InitStructure.DMA_MemoryBaseAddr = (uint32_t)g_dac_sin_buf;
    DMA_InitStructure.DMA_DIR = DMA_DIR_PeripheralDST;
    DMA_InitStructure.DMA_BufferSize = 4096;
    DMA_InitStructure.DMA_PeripheralInc = DMA_PeripheralInc_Disable;
    DMA_InitStructure.DMA_MemoryInc = DMA_MemoryInc_Enable;
    DMA_InitStructure.DMA_PeripheralDataSize = DMA_PeripheralDataSize_HalfWord;
    DMA_InitStructure.DMA_MemoryDataSize = DMA_MemoryDataSize_HalfWord;
    DMA_InitStructure.DMA_Mode = DMA_Mode_Circular;
    DMA_InitStructure.DMA_Priority = DMA_Priority_High;
    DMA_InitStructure.DMA_M2M = DMA_M2M_Disable;
    DMA_Init(DMA1_Channel1, &DMA_InitStructure);

    /* Enable DMA2 Channel1 */
    DMA_Cmd(DMA1_Channel1, ENABLE);

    /* DAC channel1 Configuration */
    DAC_InitStructure.DAC_Trigger = DAC_Trigger_T2_TRGO;
    DAC_InitStructure.DAC_WaveGeneration = DAC_WaveGeneration_None;
    DAC_InitStructure.DAC_OutputBuffer = DAC_OutputBuffer_Disable;
    DAC_Init(DAC_Channel_1, &DAC_InitStructure);

    /* Enable DAC Channel1 */
    DAC_Cmd(DAC_Channel_1, ENABLE);

    /* Enable DAC Channel1 DMA */
    DAC_DMACmd(DAC_Channel_1, ENABLE);
}



/**
 * @brief       DAC DMA使能波形输出
 *   @note      TIM7的输入时钟频率(f)来自APB1, f = 36M * 2 = 72Mhz.
 *              DAC触发频率 ftrgo = f / ((psc + 1) * (arr + 1))
 *              波形频率 = ftrgo / ndtr; 
 *
 * @param       ndtr        : DMA通道单次传输数据量
 * @param       arr         : TIM7的自动重装载值
 * @param       psc         : TIM7的分频系数
 * @retval      无
 */


/* DAC DMA使能波形输出 */
void dac_dma_wave_enable(uint16_t cndtr, uint16_t arr, uint16_t psc) {
	
    TIM_TimeBaseInitTypeDef TIM_TimeBaseStructure;

    /* Enable TIM2 clock */
    RCC_APB1PeriphClockCmd(RCC_APB1Periph_TIM2, ENABLE);

    /* Time base configuration */
    TIM_TimeBaseStructure.TIM_Period = arr;
    TIM_TimeBaseStructure.TIM_Prescaler = psc;
    TIM_TimeBaseStructure.TIM_ClockDivision = 0;
    TIM_TimeBaseStructure.TIM_CounterMode = TIM_CounterMode_Up;
    TIM_TimeBaseInit(TIM2, &TIM_TimeBaseStructure);

    /* TIM2 TRGO selection */
    TIM_SelectOutputTrigger(TIM2, TIM_TRGOSource_Update);

    /* TIM2 enable counter */
    TIM_Cmd(TIM2, ENABLE);
}

/**
 * @brief       产生正弦波序列函数
 *   @note      需保证: maxval > samples/2
 * @param       maxval : 最大值(0 < maxval < 2048)
 * @param       samples: 采样点的个数
 * @retval      无
 */

void dac_creat_sin_buf(uint16_t maxval, uint16_t samples)
{
    uint8_t i;
    float outdata = 0;                     /* 存放计算后的数字量 */
    float inc = (2 * 3.1415962) / samples; /* 计算相邻两个点的x轴间隔 */
 
    if(maxval <= (samples / 2))return ;	   /* 数据不合法 */
 
    for (i = 0; i < samples; i++)
    {
        /* 
         * 正弦波函数解析式：y = Asin(ωx + φ）+ b
         * 计算每个点的y值，将峰值放大maxval倍，并将曲线向上偏移maxval到正数区域
         * 注意：DAC无法输出负电压，所以需要将曲线向上偏移一个峰值的量，让整个曲线都落在正数区域
         */
        outdata = maxval * sinf(inc * i) + maxval;
        if (outdata > 4095)
            outdata = 4095; /* 上限限定 */
        //printf("%f\r\n",outdata);
        g_dac_sin_buf[i] = outdata;
    }
}
/**
     //正弦
int main(void)
{
	//模块初始化
	OLED_Init();			//OLED初始化
	OLED_ShowString(1, 1, "ADValue:");
    dac_dma_wave_init();
	
	dac_creat_sin_buf(2048, 100);
	dac_dma_wave_enable(100, 10 - 1, 24 - 1);
	AD_Init();				//AD初始化
	
	//显示静态字符串
	
	OLED_ShowString(2, 1, "Voltage:0.00V");
	
	while (1)
	{
		ADValue = AD_GetValue();					//获取AD转换的值
		Voltage = (float)ADValue / 4095 * 3.3;		//将AD值线性变换到0~3.3的范围，表示电压
		
		OLED_ShowNum(1, 9, ADValue, 4);				//显示AD值
		OLED_ShowNum(2, 9, Voltage, 1);				//显示电压值的整数部分
		OLED_ShowNum(2, 11, (uint16_t)(Voltage * 100) % 100, 2);	//显示电压值的小数部分
		
		Delay_ms(300);			//延时100ms，手动增加一些转换的间隔时间
	}
}
*/


