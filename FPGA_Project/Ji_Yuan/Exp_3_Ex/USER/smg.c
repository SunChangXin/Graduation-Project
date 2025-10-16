#include "smg.h"
#include "delay.h"

// 数码管显示0-9的编码
uint8_t digivalue[] = {0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F};  // 0-9的显示数据

void SMG_Init(void) {
    GPIO_InitTypeDef GPIO_InitStructure;

    // 开启GPIOC的时钟
    RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOC, ENABLE);

    // 配置GPIO引脚（假设连接数码管的GPIO引脚是GPIOC的0到5号引脚）
    GPIO_InitStructure.GPIO_Pin = GPIO_Pin_0 | GPIO_Pin_1 | GPIO_Pin_2 | 
                                   GPIO_Pin_3 | GPIO_Pin_4 | GPIO_Pin_5;
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_OUT;       
    GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;      // 推挽输出
    GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;   // 设置输出速度为50MHz
    GPIO_Init(GPIOC, &GPIO_InitStructure);  
}

// 发送数据到74HC595
void HC595_Send(uint8_t dat) {
    uint8_t i;
    for (i = 0; i < 8; i++) {  // 发送8位数据
        if (dat & 0x80) {       // 判断数据最高位
            GPIO_SetBits(GPIOC, GPIO_Pin_0);  // 设置数据为高
        } else {
            GPIO_ResetBits(GPIOC, GPIO_Pin_0);  // 设置数据为低
        }
        GPIO_ResetBits(GPIOC, GPIO_Pin_2);  // 时钟信号低电平
        Delay_Us(1);                        // 延时
        GPIO_SetBits(GPIOC, GPIO_Pin_2);    // 时钟信号高电平
        Delay_Us(1);                        // 延时
        dat <<= 1;                          // 左移数据
    }
    GPIO_ResetBits(GPIOC, GPIO_Pin_1);    // 锁存引脚低电平
    Delay_Us(1);                           // 延时
    GPIO_SetBits(GPIOC, GPIO_Pin_1);      // 锁存引脚高电平
}

// 选择显示的数字
void SMG_Sele(uint8_t index) {
    if (index < 10) {                      // 确保传入的index在0-9之间
        HC595_Send(digivalue[index]);     // 通过74HC595发送相应的显示数据
    }
}
