        THUMB
        REQUIRE8
        PRESERVE8

        EXPORT LED_Init

        IMPORT GPIO_Set
        IMPORT GPIO_Write


        AREA ||i.LED_Init||, CODE, READONLY, ALIGN=2

|RCC_AHB1ENR|
        DCD      0x40023830
|GPIOF|
        DCD      0x40021400

; void LED_Init(void)
LED_Init PROC
		PUSH     {r2-r4,lr}
		LDR      r0,|RCC_AHB1ENR|	; 读取RCC_AHB1ENR的值
		LDR      r0,[r0,#0]
		ORR      r0,r0,#0x20
		LDR      r1,|RCC_AHB1ENR|
		STR      r0,[r1,#0]			; RCC_AHB1ENR的位5置1，即使能IO端口F时钟 
		MOVS     r0,#1				; PUPD
		MOVS     r1,#3				; OSPEED
		MOVS     r2,#1				; MODE
		MOVS     r3,#0				; OTYPE
		STRD     r1,r0,[sp,#0]
		MOVS     r1,#0xff			; BITx
		LDR      r0,|GPIOF|			; GPIOx
		BL       GPIO_Set			; 调用IO端口配置函数GPIO_Set
		MOV      r1,#0xff
		LDR      r0,|GPIOF|			; 点亮所有LED灯
		BL		 GPIO_Write
		POP      {r2-r4,pc}
		ENDP

        END
