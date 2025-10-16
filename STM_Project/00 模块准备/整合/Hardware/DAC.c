#include "stm32f10x.h"
#include "stm32f10x_gpio.h"
#include "stm32f10x_rcc.h"
#include "stm32f10x_dac.h"
#include "Delay.h"  

/* DAC????? */
void DAC_InitConfig(void)
{
    GPIO_InitTypeDef GPIO_InitStructure;
    DAC_InitTypeDef  DAC_InitStructure;

    /* ???? */
    RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA, ENABLE);  // ??PORTA????
    RCC_APB1PeriphClockCmd(RCC_APB1Periph_DAC, ENABLE);    // ??DAC????

    /* ??PA.4 (DAC_OUT1) */
    GPIO_InitStructure.GPIO_Pin = GPIO_Pin_6;
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AIN;  // ????
    GPIO_Init(GPIOA, &GPIO_InitStructure);

    /* DAC??1??? */
    DAC_InitStructure.DAC_Trigger = DAC_Trigger_None;  // ???????
    DAC_InitStructure.DAC_WaveGeneration = DAC_WaveGeneration_None;  // ???????
    DAC_InitStructure.DAC_LFSRUnmask_TriangleAmplitude = DAC_LFSRUnmask_Bit0;  // ???????
    DAC_InitStructure.DAC_OutputBuffer = DAC_OutputBuffer_Disable;  // DAC1??????
    DAC_Init(DAC_Channel_1, &DAC_InitStructure);

    /* ??DAC??1 */
    DAC_Cmd(DAC_Channel_1, ENABLE);

    /* ????????0 */
    DAC_SetChannel1Data(DAC_Align_12b_R, 0);
}

/* DAC?????? */
void DAC_SetVoltage(uint16_t voltage)
{
    float temp = voltage;
    temp = temp * 4096 / 3300;  // ???????DAC???
    DAC_SetChannel1Data(DAC_Align_12b_R, (uint16_t)temp);
}

/* DAC????? */
void DAC_TriangularWave(uint16_t maxval, uint16_t dt, uint16_t samples, uint16_t n)
{
    uint16_t i, j;
    float incval;  /* ??? */
    float curval;  /* ??? */

    if(samples > ((maxval + 1) * 2)) return;  /* ????? */

    incval = (float)(maxval + 1) / (samples / 2);  /* ????? */

    for(j = 0; j < n; j++)
    { 
        curval = 0;
        DAC_SetChannel1Data(DAC_Align_12b_R, (uint16_t)curval);  /* ???0 */
        for(i = 0; i < (samples / 2); i++)  /* ????? */
        {
            curval += incval;  /* ????? */
            DAC_SetChannel1Data(DAC_Align_12b_R, (uint16_t)curval);
			Delay_us(dt);
        }
        for(i = 0; i < (samples / 2); i++)  /* ????? */
        {
            curval -= incval;  /* ????? */
            DAC_SetChannel1Data(DAC_Align_12b_R, (uint16_t)curval);
			Delay_us(dt);
        }
    }
	
}
/*三角波
int main(void)
{
	//模块初始化
	OLED_Init();			//OLED初始化
	DAC_InitConfig();
	AD_Init();				//AD初始化
	DAC_TriangularWave(2047,10,100,1);

	
	//显示静态字符串
	OLED_ShowString(1, 1, "ADValue:");
	OLED_ShowString(2, 1, "Voltage:0.00V");
	
	while (1)
	{
		ADValue = AD_GetValue();					//获取AD转换的值
		Voltage = (float)ADValue / 4095 * 3.3;		//将AD值线性变换到0~3.3的范围，表示电压
		
		OLED_ShowNum(1, 9, ADValue, 4);				//显示AD值
		OLED_ShowNum(2, 9, Voltage, 1);				//显示电压值的整数部分
		OLED_ShowNum(2, 11, (uint16_t)(Voltage * 100) % 100, 2);	//显示电压值的小数部分
		
		Delay_ms(100);			//延时100ms，手动增加一些转换的间隔时间
	}
}
*/
 


