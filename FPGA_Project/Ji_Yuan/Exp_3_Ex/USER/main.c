#include "stm32f4xx.h"
#include "delay.h"
#include "led.h"
#include "smg.h"
#include "exti.h"
#include "tim.h"

#define KEY  GPIO_ReadInputDataBit(GPIOB, GPIO_Pin_11) 

void Key_Hardware_Init()  
{  
		GPIO_InitTypeDef GPIO_TypeDefStructure;  
	
		RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOB, ENABLE); 
	
		GPIO_TypeDefStructure.GPIO_Pin = GPIO_Pin_11;  
		GPIO_TypeDefStructure.GPIO_Mode = GPIO_Mode_IN;  
		GPIO_TypeDefStructure.GPIO_PuPd = GPIO_PuPd_UP;  
		GPIO_Init(GPIOB, &GPIO_TypeDefStructure);  
} 
int main(void) {
    uint8_t i = 0;
    uint16_t cont = 0;

    NVIC_PriorityGroupConfig(NVIC_PriorityGroup_0);
    Delay_Init();
    EXTI_Configure();
    TIM1_Configure(999, 167);  
    SMG_Init(); 
    LED_Hardware_Init();  
    Key_Hardware_Init(); 

    while (1) {
        cont++;
        if (cont >= 500) {
            cont = 0;
            SMG_Sele(i); 
            // (i == 3 || i == 4) {
                if (!KEY) {
                    Delay_Ms(10);
                    if (!KEY) {
                        while (!KEY) {};  
                        led_flow_flag = 1;   
                    }
             //   }
            }
            i++;
            i &= 0x6F;  
        }
        Delay_Ms(1);    
        LED_Flow();     
    }
}
