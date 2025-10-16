#include "tim.h"
#include "led.h"

void TIM1_Configure(uint32_t arr, uint16_t psc) {
    TIM_TimeBaseInitTypeDef TIM_TimeBaseStructure;
    NVIC_InitTypeDef NVIC_InitStructure;

    RCC_APB2PeriphClockCmd(RCC_APB2Periph_TIM1, ENABLE);

    TIM_TimeBaseStructure.TIM_Period = arr;
    TIM_TimeBaseStructure.TIM_Prescaler = psc;
    TIM_TimeBaseStructure.TIM_CounterMode = TIM_CounterMode_Up;
    TIM_TimeBaseStructure.TIM_ClockDivision = TIM_CKD_DIV1;
    TIM_TimeBaseStructure.TIM_RepetitionCounter = 0;
    TIM_TimeBaseInit(TIM1, &TIM_TimeBaseStructure);

    NVIC_InitStructure.NVIC_IRQChannel = TIM1_UP_TIM10_IRQn;
    NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = 0;
    NVIC_InitStructure.NVIC_IRQChannelSubPriority = 6;
    NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;
    NVIC_Init(&NVIC_InitStructure);

    TIM_ITConfig(TIM1, TIM_IT_Update, ENABLE);
    TIM_Cmd(TIM1, ENABLE);
}

void TIM1_UP_TIM10_IRQHandler(void) {
    static uint16_t cont_time = 0;

    if (TIM_GetITStatus(TIM1, TIM_IT_Update) == SET) {
        if (led_flow_flag) {
            cont_time++;
            if (cont_time >= 5000) {
                cont_time = 0;
                led_flow_flag = 0;
            }
        }
        TIM_ClearITPendingBit(TIM1, TIM_IT_Update);
    }
}
