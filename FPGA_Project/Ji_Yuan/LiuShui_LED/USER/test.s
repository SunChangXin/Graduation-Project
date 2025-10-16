; *************************************************************
; 实验名称：LED流水灯实验
;
; 硬件模块：计算机原理应用实验箱
;
; 硬件接线：ARM P12接口 --------- LED P2接口
;              PF0~PF7 -------- LED1~LED8
;		     注：可使用20P排线直连P12、P2接口。
;
; 实验现象：LED1~LED8实现流水灯效果。
;
; 更新时间：2019-01-22
;**************************************************************
        THUMB
        REQUIRE8
        PRESERVE8

__ARM_use_no_argv EQU 0

        EXPORT __ARM_use_no_argv
        EXPORT main

        IMPORT Stm32_Clock_Init
        IMPORT delay_init
        IMPORT LED_Init
        IMPORT delay_ms
        IMPORT GPIO_Write

        AREA ||i.main||, CODE, READONLY, ALIGN=2

|GPIOF|
        DCD      0x40021400

; int main(void)
main PROC
        MOVS     r3,#7
        MOVS     r2,#2
        MOVS     r1,#0x19
        MOV      r0,#0x150
        BL       Stm32_Clock_Init			; 系统时钟初始化
        MOVS     r0,#0xa8
        BL       delay_init				; 延时初始化
        BL       LED_Init				; LED初始化
        B        |while(1)|
|loop|									; 循环体
        MOVS     r0,#0x01
        LSLS     r2,r0,r4				; 逻辑左移
        UXTH     r5,r2
        MOV      r1,r5
        LDR      r0,|GPIOF|				; GPIOF输出led_data
        BL       GPIO_Write
        MOVS     r0,#0x64
        BL       delay_ms				; 延时100ms
        ADDS     r2,r4,#1
        UXTB     r4,r2
        AND      r4,r4,#7				; cont大于7后清零
|while(1)|
        B        |loop|					; 循环
        ENDP

        END
