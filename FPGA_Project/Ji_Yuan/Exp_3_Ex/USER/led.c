#include "led.h"
#include "delay.h"

uint8_t led_flow_flag = 0;  

void LED_Hardware_Init(void) {
    GPIO_InitTypeDef GPIO_InitStructure;

    RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOF, ENABLE);

    GPIO_InitStructure.GPIO_Pin = GPIO_Pin_All;  
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_OUT;           
    GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;           
    GPIO_InitStructure.GPIO_Speed = GPIO_Medium_Speed;     
    GPIO_Init(GPIOF, &GPIO_InitStructure);  

    GPIO_Write(GPIOF, 0x0000);  
}

void LED_Flow(void) {
    static uint8_t cont;
    static uint16_t led_data;

    if (led_flow_flag == 1) {
        led_data = 1 << cont;           
        GPIO_Write(GPIOF, led_data);
        Delay_Ms(100);  
        cont++;
        cont &= 0x07;    
    } else if (led_flow_flag == 2) {
        GPIO_Write(GPIOF, 0xff00);  
        Delay_Ms(300);  
        GPIO_Write(GPIOF, 0x0000);  
        Delay_Ms(300);  
    }
}
