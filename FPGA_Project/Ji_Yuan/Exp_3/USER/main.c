#include "stm32f4xx.h"
#include "delay.h"

// 74HC595 和 74HC138 的引脚定义
#define SI_Pin GPIO_Pin_0     // 74HC595 的串行输入引脚
#define RCK_Pin GPIO_Pin_1    // 74HC595 的存储寄存器时钟引脚
#define SCK_Pin GPIO_Pin_2    // 74HC595 的移位寄存器时钟引脚
#define A_Pin GPIO_Pin_3      // 74HC138 的 A 选择引脚
#define B_Pin GPIO_Pin_4      // 74HC138 的 B 选择引脚
#define C_Pin GPIO_Pin_5      // 74HC138 的 C 选择引脚

#define PORT GPIOC            // GPIO 端口定义
#define HC_GPIO_PORT GPIOC    // HC 芯片相关 GPIO 端口

// 74HC138 控制宏
#define  HC138_A(val)   GPIO_WriteBit(GPIOC, GPIO_Pin_3, (BitAction)val) // 控制 A 选择引脚
#define  HC138_B(val)   GPIO_WriteBit(GPIOC, GPIO_Pin_4, (BitAction)val) // 控制 B 选择引脚
#define  HC138_C(val)   GPIO_WriteBit(GPIOC, GPIO_Pin_5, (BitAction)val) // 控制 C 选择引脚

// 74HC595 控制宏
#define  HC595_SI(val)  GPIO_WriteBit(GPIOC, GPIO_Pin_0, (BitAction)val) // 控制串行输入
#define  HC595_RCK(val) GPIO_WriteBit(GPIOC, GPIO_Pin_1, (BitAction)val) // 控制存储寄存器时钟
#define  HC595_SCK(val) GPIO_WriteBit(GPIOC, GPIO_Pin_2, (BitAction)val) // 控制移位寄存器时钟
volatile uint8_t stop_flag = 0; // 用于标记计时是否停止
volatile uint8_t current_num = 0; // 当前数码管显示的数字

void led_config(void) {
    GPIO_InitTypeDef GPIO_InitStructure;

    // 使能 GPIOB 时钟
    RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOB, ENABLE);

    // 配置 GPIOB 所有引脚为推挽输出模式
    GPIO_InitStructure.GPIO_Pin = GPIO_Pin_All;
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_OUT;
    GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
    GPIO_InitStructure.GPIO_Speed = GPIO_Medium_Speed;
    GPIO_Init(GPIOB, &GPIO_InitStructure);
}

// 数码管配置
void smg_config(void) {
    GPIO_InitTypeDef GPIO_InitStructure;

    // 使能 GPIOC 时钟
    RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOC, ENABLE);

    // 配置 GPIOC 所有引脚为推挽输出模式
    GPIO_InitStructure.GPIO_Pin = GPIO_Pin_All;
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_OUT;
    GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
    GPIO_InitStructure.GPIO_Speed = GPIO_Medium_Speed;
    GPIO_Init(GPIOC, &GPIO_InitStructure);
}

// NVIC 配置
void NVIC_Configure(void) {
    GPIO_InitTypeDef GPIO_TypeDefStructure;

    // 使能 GPIOF 时钟
    RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOF, ENABLE);

    // 配置 GPIOF 引脚 8 和 11 为输入模式，用于检测按键
    GPIO_TypeDefStructure.GPIO_Pin = GPIO_Pin_8 | GPIO_Pin_11;
    GPIO_TypeDefStructure.GPIO_Mode = GPIO_Mode_IN;
    GPIO_TypeDefStructure.GPIO_PuPd = GPIO_PuPd_UP; // 上拉输入
    GPIO_Init(GPIOF, &GPIO_TypeDefStructure);
}

// 配置 EXTI8
void EXTI8_Configure(void) {
    EXTI_InitTypeDef EXTI_TypeDefStructure;
    NVIC_InitTypeDef NVIC_TypeDefStructure;

    // 将 GPIOF 的引脚 8 映射到 EXTI 线
    SYSCFG_EXTILineConfig(EXTI_PortSourceGPIOF, EXTI_PinSource8);

    // 配置 EXTI 线 8
    EXTI_TypeDefStructure.EXTI_Line = EXTI_Line8;
    EXTI_TypeDefStructure.EXTI_Mode = EXTI_Mode_Interrupt;
    EXTI_TypeDefStructure.EXTI_Trigger = EXTI_Trigger_Falling; // 下降沿触发
    EXTI_TypeDefStructure.EXTI_LineCmd = ENABLE;
    EXTI_Init(&EXTI_TypeDefStructure);

    // 配置 NVIC 优先级
    NVIC_TypeDefStructure.NVIC_IRQChannel = EXTI9_5_IRQn;
    NVIC_TypeDefStructure.NVIC_IRQChannelPreemptionPriority = 0; // 抢占优先级
    NVIC_TypeDefStructure.NVIC_IRQChannelSubPriority = 7; // 子优先级
    NVIC_TypeDefStructure.NVIC_IRQChannelCmd = ENABLE;
    NVIC_Init(&NVIC_TypeDefStructure);
}

// 配置 EXTI11
void EXTI11_Configure(void) {
    EXTI_InitTypeDef EXTI_TypeDefStructure;
    NVIC_InitTypeDef NVIC_TypeDefStructure;

    // 将 GPIOF 的引脚 11 映射到 EXTI 线
    SYSCFG_EXTILineConfig(EXTI_PortSourceGPIOF, EXTI_PinSource11);

    // 配置 EXTI 线 11
    EXTI_TypeDefStructure.EXTI_Line = EXTI_Line11;
    EXTI_TypeDefStructure.EXTI_Mode = EXTI_Mode_Interrupt;
    EXTI_TypeDefStructure.EXTI_Trigger = EXTI_Trigger_Falling; // 下降沿触发
    EXTI_TypeDefStructure.EXTI_LineCmd = ENABLE;
    EXTI_Init(&EXTI_TypeDefStructure);

    // 配置 NVIC 优先级
    NVIC_TypeDefStructure.NVIC_IRQChannel = EXTI15_10_IRQn;
    NVIC_TypeDefStructure.NVIC_IRQChannelPreemptionPriority = 1; // 抢占优先级
    NVIC_TypeDefStructure.NVIC_IRQChannelSubPriority = 7; // 子优先级
    NVIC_TypeDefStructure.NVIC_IRQChannelCmd = ENABLE;
    NVIC_Init(&NVIC_TypeDefStructure);
}

// 数码管段码表，用于显示 0-9
uint8_t segment_table[10] = {
    0x3F, // 显示 0
    0x06, // 显示 1
    0x5B, // 显示 2
    0x4F, // 显示 3
    0x66, // 显示 4
    0x6D, // 显示 5
    0x7D, // 显示 6
    0x07, // 显示 7
    0x7F, // 显示 8
    0x6F  // 显示 9
};

// 发送数据到 74HC595
void HC595_SendData(uint8_t data) {
    for (int i = 0; i < 8; i++) {
        if (data & 0x80) { // 检查最高位
            GPIO_SetBits(HC_GPIO_PORT, SI_Pin); // 输出高电平
        } else {
            GPIO_ResetBits(HC_GPIO_PORT, SI_Pin); // 输出低电平
        }
        data <<= 1; // 左移一位

        // 生成上升沿信号
        GPIO_SetBits(HC_GPIO_PORT, SCK_Pin);
        GPIO_ResetBits(HC_GPIO_PORT, SCK_Pin);
    }

    // 锁存数据
    GPIO_SetBits(HC_GPIO_PORT, RCK_Pin);
    GPIO_ResetBits(HC_GPIO_PORT, RCK_Pin);
}

// 选择 74HC138 的位
void HC138_SelectBits(uint8_t bit) {
    GPIO_WriteBit(HC_GPIO_PORT, A_Pin, (bit & 0x01) ? Bit_SET : Bit_RESET); // 控制 A 位
    GPIO_WriteBit(HC_GPIO_PORT, B_Pin, (bit & 0x02) ? Bit_SET : Bit_RESET); // 控制 B 位
    GPIO_WriteBit(HC_GPIO_PORT, C_Pin, (bit & 0x04) ? Bit_SET : Bit_RESET); // 控制 C 位
}

// 数码管显示函数
void SMG_Display(uint8_t num) {
    for (uint8_t i = 0; i < 8; i++) { // 假设有 8 个数码管
        HC138_SelectBits(0); // 选择数码管位置
        HC595_SendData(segment_table[num]); // 显示当前数字
        Delay_Ms(3); // 短延时实现动态扫描
    }
}


// LED 流水灯效果
void LED_Flow(void) {
    for (uint16_t i = 0; i < 8; i++) {
        GPIO_Write(GPIOB, 1 << i); // 每次点亮一个 LED
        Delay_Ms(500); // 延迟 500 毫秒
    }
     GPIO_Write(GPIOB, 0x00);
}

// 交通灯闪烁效果
void Traffic_Light(void) {
//    for (uint16_t i = 0; i < 5; i++) {
//        GPIO_Write(GPIOB, 0xFF); // 所有灯亮
//        Delay_Ms(500);
//        GPIO_Write(GPIOB, 0x00); // 所有灯灭
//        Delay_Ms(500);
//    }
		for (uint16_t i = 0; i < 5; i++) {
			GPIO_Write(GPIOB, 0xff00);  
			Delay_Ms(300);  
			GPIO_Write(GPIOB, 0x0000);  
			Delay_Ms(300);  
		}
}

// 按键 1 的中断处理函数
void EXTI9_5_IRQHandler(void) {
    if (EXTI_GetITStatus(EXTI_Line8)) { // 检测 EXTI 线 8 是否触发
        stop_flag = 1; // 停止数码管计时
        Traffic_Light(); // 执行交通灯闪烁效果
        stop_flag = 0; // 恢复数码管计时
        EXTI_ClearITPendingBit(EXTI_Line8); // 清除中断标志位
    }
}
void EXTI15_10_IRQHandler(void) {
    if (EXTI_GetITStatus(EXTI_Line11)) { // 检测 EXTI 线 11 是否触发
          // 仅当数码管显示数字 5 时生效
            stop_flag = 1; // 停止数码管计时
            LED_Flow(); // 执行 LED 流水灯效果
            stop_flag = 0; // 恢复数码管计时
       EXTI_ClearITPendingBit(EXTI_Line11);
        }
    
}
// 主函数
int main(void) {
    NVIC_PriorityGroupConfig(NVIC_PriorityGroup_1); // 配置中断优先级分组
    RCC_APB2PeriphClockCmd(RCC_APB2Periph_SYSCFG, ENABLE); // 使能系统配置时钟
	  EXTI8_Configure(); // 配置 EXTI 8
    EXTI11_Configure(); // 配置 EXTI 11
    Delay_Init(); // 初始化延时函数
    led_config(); // 初始化 LED 配置
    smg_config(); // 初始化数码管配置
    NVIC_Configure(); 

    while (1) {
        if (!stop_flag) { // 如果未被停止
            SMG_Display(current_num); // 显示当前数字
            current_num++;
            if (current_num > 7) current_num = 0; // 数字循环到 0
            Delay_Ms(10000); // 每秒更新一次
        }
    }
}
