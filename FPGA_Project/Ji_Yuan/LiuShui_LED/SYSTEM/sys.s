		THUMB
		REQUIRE8
		PRESERVE8

		EXPORT Ex_NVIC_Config
		EXPORT GPIO_AF_Set
		EXPORT GPIO_Set
		EXPORT MY_NVIC_Init
		EXPORT MY_NVIC_PriorityGroupConfig
		EXPORT MY_NVIC_SetVectorTable
		EXPORT Stm32_Clock_Init
		EXPORT Sys_Clock_Set
		EXPORT Sys_Soft_Reset
		EXPORT Sys_Standby
		EXPORT INTX_DISABLE
		EXPORT INTX_ENABLE
		EXPORT MSR_MSP
		EXPORT GPIO_Write

; ******************************************************************
; 功  能：外部中断配置函数
;		（只针对GPIOA~I;不包括PVD,RTC,USB_OTG,USB_HS,以太网唤醒等）
;
; 参  数：r3: GPIOx(0~8,代表GPIOA~I)
; 		 r0: BITx,需要使能的位
; 		 r2: TRIM,触发模式,1,下升沿;2,上降沿;3，任意电平触发
; 		 r5: EXTOFFSET
;
; 		 该函数一次只能配置1个IO口,多个IO口,需多次调用
; 		 该函数会自动开启对应中断,以及屏蔽线   	   
;
; 返回值：无 
; ******************************************************************
        AREA ||i.Ex_NVIC_Config||, CODE, READONLY, ALIGN=2

|RCC_APB2ENR|
        DCD      0x40023844
|SYSCFG_EXTICR1|
        DCD      0x40013808
|EXTI_IMR|
        DCD      0x40013c00

; void Ex_NVIC_Config(u8 GPIOx,u8 BITx,u8 TRIM) 
Ex_NVIC_Config PROC
        PUSH     {r4-r7,lr}
        MOV      r3,r0				; 获取GPIOx的值，存放于r3中
        MOV      r0,r1				; 获取BITx的值，存放于r0中
        ASRS     r5,r1,#31			; ASRS算术右移,符号位保留，左端填充1
        ADD      r5,r1,r5,LSR #30		; 
        ASRS     r5,r5,#2
        SUB      r5,r1,r5,LSL #2
        LSLS     r5,r5,#26
        LSRS     r4,r5,#24
        LDR      r0,|RCC_APB2ENR|
        LDR      r0,[r0,#0]
        ORR      r0,r0,#0x4000
        LDR      r5,|RCC_APB2ENR|
        STR      r0,[r5,#0]
        ASRS     r5,r1,#31
        ADD      r5,r1,r5,LSR #30
        ASRS     r6,r5,#2
        LDR      r5,|SYSCFG_EXTICR1|
        LDR      r5,[r5,r6,LSL #2]
        MOVS     r6,#0xf
        LSLS     r6,r6,r4
        BICS     r5,r5,r6
        MOV      r0,r1
        ASRS     r6,r1,#31
        ADD      r6,r1,r6,LSR #30
        ASRS     r7,r6,#2
        LDR      r6,|SYSCFG_EXTICR1|
        STR      r5,[r6,r7,LSL #2]
        ASRS     r5,r1,#31
        ADD      r5,r1,r5,LSR #30
        ASRS     r6,r5,#2
        LDR      r5,|SYSCFG_EXTICR1|
        LDR      r5,[r5,r6,LSL #2]
        LSL      r6,r3,r4
        ORRS     r5,r5,r6
        ASRS     r6,r1,#31
        ADD      r6,r1,r6,LSR #30
        ASRS     r7,r6,#2
        LDR      r6,|SYSCFG_EXTICR1|
        STR      r5,[r6,r7,LSL #2]
        LDR      r0,|EXTI_IMR|
        LDR      r0,[r0,#0]
        MOVS     r5,#1
        LSLS     r5,r5,r1
        ORRS     r0,r0,r5
        LDR      r5,|EXTI_IMR|
        STR      r0,[r5,#0]
        AND      r0,r2,#1
        CBZ      r0,|L0.142|
        LDR      r0,|EXTI_IMR|
        ADDS     r0,r0,#0xc
        LDR      r0,[r0,#0]
        MOVS     r5,#1
        LSLS     r5,r5,r1
        ORRS     r0,r0,r5
        LDR      r5,|EXTI_IMR|
        ADDS     r5,r5,#0xc
        STR      r0,[r5,#0]
|L0.142|
        AND      r0,r2,#2
        CBZ      r0,|L0.166|
        LDR      r0,|EXTI_IMR|
        ADDS     r0,r0,#8
        LDR      r0,[r0,#0]
        MOVS     r5,#1
        LSLS     r5,r5,r1
        ORRS     r0,r0,r5
        LDR      r5,|EXTI_IMR|
        ADDS     r5,r5,#8
        STR      r0,[r5,#0]
|L0.166|
        POP      {r4-r7,pc}
        ENDP

; ************************************************************************
; 功  能：GPIO复用设置
;
; 参  数：r0: GPIOx，代表GPIOA~GPIOI
; 		 r1: BITx，0~15，代表IO引脚编号
; 		 r2: AFx，0~15，代表AF0~AF15
; 		 r3: GPIOx_AFRL
;
; 		 AF0:MCO/SWD/SWCLK/RTC  			AF1:TIM1/TIM2;
; 		 AF2:TIM3~5; AF3:TIM8~11			    AF3:TIM8~11
; 		 AF4:I2C1~I2C3;          			AF5:SPI1/SPI2
; 		 AF6:SPI3;             			    AF7:USART1~3;
; 		 AF8:USART4~6;         				AF9;CAN1/CAN2/TIM12~14  
; 		 AF10:USB_OTG/USB_HS     			AF11:ETH
; 		 AF12:FSMC/SDIO/OTG/HS  			AF13:DCIM  
; 		 AF14:                   			AF15:EVENTOUT
;
; 返回值：无
; ************************************************************************
        AREA ||i.GPIO_AF_Set||, CODE, READONLY, ALIGN=1

; void GPIO_AF_Set(GPIO_TypeDef* GPIOx,u8 BITx,u8 AFx)
GPIO_AF_Set PROC
        PUSH     {r4,r5,lr}
        ASRS     r4,r1,#3
        ADD      r3,r0,#0x20
        LDR      r3,[r3,r4,LSL #2]
        LSLS     r4,r1,#29
        LSRS     r5,r4,#27
        MOVS     r4,#0xf
        LSLS     r4,r4,r5
        BICS     r3,r3,r4
        ASRS     r5,r1,#3
        ADD      r4,r0,#0x20
        STR      r3,[r4,r5,LSL #2]
        ASRS     r4,r1,#3
        ADD      r3,r0,#0x20
        LDR      r3,[r3,r4,LSL #2]
        LSLS     r4,r1,#29
        LSRS     r4,r4,#27
        LSL      r4,r2,r4
        ORRS     r3,r3,r4
        ASRS     r5,r1,#3
        ADD      r4,r0,#0x20
        STR      r3,[r4,r5,LSL #2]
        POP      {r4,r5,pc}
        ENDP

; *************************************************************************************
; 功  能：GPIO通用设置
;
; 参  数：r0: GPIOx:(x = A、B、C、D、E、F、G、H、I)
; 		 r4: BITx,:0X0000~0XFFFF,位设置,每个位代表一个IO
; 		 r2: MODE,0~3;模式选择,0,输入(系统复位默认状态);1,普通输出;2,复用功能;3,模拟输入.
; 		 r3: OTYPE,0/1;输出类型选择,0,推挽输出;1,开漏输出.
; 		 r6: OSPEED,0~3;输出速度设置,0,2Mhz;1,25Mhz;2,50Mhz;3,100Mh. 
; 		 r7; PUPD,0~3:上下拉设置,0,不带上下拉;1,上拉;2,下拉;3,保留.
;
; 返回值：无
; ************************************************************************************
        AREA ||i.GPIO_Set||, CODE, READONLY, ALIGN=1

pinpos			EQU			0x00
pos				EQU			0x00
curpin			EQU			0x00

; void GPIO_Set(GPIO_TypeDef* GPIOx,u32 BITx,u32 MODE,u32 OTYPE,u32 OSPEED,u32 PUPD)
GPIO_Set PROC
        PUSH     {r4-r10,lr}
        MOV      r4,r1				; 获取BITx，存放在r4中
        LDRD     r6,r7,[sp,#0x20]
        MOVS     r1,#pinpos
        MOVS     r5,#pos
        MOVS     r12,#curpin
        NOP      
        B        |CMP_pinpos_16|
|for|
        MOV      r8,#1
        LSL      r5,r8,r1			; 逐位检查，pos等于pinpos左移一位
        AND      r12,r4,r5			; 获取某一位引脚
        CMP      r12,r5				; 检查该引脚是否要设置
        BNE      |pinpos++|			; 若该引脚不需要设置，则检查下一位引脚
        ; 清除原来的MODE的设置
        LDR      r8,[r0,#0]			; 获取寄存器GPIOx_MODER中的值，存放于r8中,GPIOx_MODER的地址基于GPIOx的基地址偏移0x00
        LSL      r10,r1,#1			; r10等于pinpos左移一位
        MOV      r9,#3
        LSL      r9,r9,r10
        BIC      r8,r8,r9			; BIC 与非
        STR      r8,[r0,#0]			; 寄存器GPIOx_MODER中写入复位值
        ; 设置新的MODE的模式 
        LDR      r8,[r0,#0]			; 获取寄存器GPIOx_MODER的值，存放于r8中
        LSL      r9,r1,#1			; r9等于pinpos左移一位
        LSL      r9,r2,r9			; r2 = MODE
        ORR      r8,r8,r9
        STR      r8,[r0,#0]			; 寄存器GPIOx_MODER中写入新MODE值
        CMP      r2,#1				; 判断是否为输出模式
        BEQ      |IF_MODE_OUT/AF|
        CMP      r2,#2				; 判断是否为复用模式
        BNE      |IF_MODE_IN|
|IF_MODE_OUT/AF|
        ; 清除原来的OSPEEDR的设置
        LDR      r8,[r0,#8]			; 获取寄存器GPIOx_OSPEEDR中的值，存放于r8中，GPIOx_OSPEEDR的地址基于GPIOx的基地址偏移0x08
        LSL      r10,r1,#1
        MOV      r9,#3
        LSL      r9,r9,r10
        BIC      r8,r8,r9
        STR      r8,[r0,#8]			; 寄存器GPIOx_OSPEEDR中写入复位值
        ; 设置新的OSPEEDR
        LDR      r8,[r0,#8]
        LSL      r9,r1,#1
        LSL      r9,r6,r9			; r6 = OSPEEDR
        ORR      r8,r8,r9
        STR      r8,[r0,#8]			; 寄存器GPIOx_OSPEEDR中写入新OSPEEDR值
        ; 清除原来的OTYPER的设置
        LDR      r9,[r0,#4]			; 获取寄存器GPIOx_OTYPER中的值，存放于r8中，GPIOx_OTYPER的地址基于GPIOx的基地址偏移0x04
        MOV      r8,#1
        LSL      r8,r8,r1
        BIC      r9,r9,r8
        STR      r9,[r0,#4]			; 寄存器GPIOx_OTYPER中写入复位值
        ; 设置新的OTYPER
        LDR      r8,[r0,#4]
        LSL      r9,r3,r1			; r3 = OTYPER
        ORR      r8,r8,r9
        STR      r8,[r0,#4]			; 寄存器GPIOx_OTYPER中写入新OTYPER值
|IF_MODE_IN|
        ; 清除原来的PUPDR的设置
        LDR      r8,[r0,#0xc]		; 获取寄存器GPIOx_PUPDR中的值，存放于r8中,GPIOx_PUPDR的地址基于GPIOx的基地址偏移0x0c
        LSL      r10,r1,#1
        MOV      r9,#3
        LSL      r9,r9,r10
        BIC      r8,r8,r9
        STR      r8,[r0,#0xc]		; 寄存器GPIOx_OTYPER中写入复位值
        ; 设置新的PUPDR
        LDR      r8,[r0,#0xc]
        LSL      r9,r1,#1
        LSL      r9,r7,r9			; r7 = PUPDR
        ORR      r8,r8,r9
        STR      r8,[r0,#0xc]		; 寄存器GPIOx_OTYPER中写入新PUPDR值
|pinpos++|
        ADDS     r1,r1,#1
|CMP_pinpos_16|
        CMP      r1,#0x10			; pinpos与16相比较
        BCC      |for|				; BCC 小于跳转
        POP      {r4-r10,pc}
        ENDP

; *************************************************************************************
; 功  能：GPIO输出
;
; 参  数：r0: GPIOx:(x = A、B、C、D、E、F、G、H、I)
; 		 r1: PortVal,:0X0000~0XFFFF，端口输出值
;
; 返回值：无
; ************************************************************************************

        AREA ||i.GPIO_Write||, CODE, READONLY, ALIGN=1

; void GPIO_Write(GPIO_TypeDef* GPIOx, uint16_t PortVal)
GPIO_Write PROC
		PUSH     {lr}	
		LDR      r2,[r0,#0x14]
		MOVS     r2,r1
		STR      r2,[r0,#0x14]
		POP      {pc}
		ENDP

; *******************************************************************************
; 功  能：设置NVIC 
; 
; 参  数：r7: NVIC_PreemptionPriority:抢占优先级
; 		 r8: NVIC_SubPriority       :响应优先级
; 		 r4: NVIC_Channel           :中断编号
; 		 r5: NVIC_Group             :中断分组 0~4
; 		 r6: temp
;
; 注意优先级不能超过设定的组的范围!否则会有意想不到的错误
; 组划分:
; 组0:0位抢占优先级,4位响应优先级
; 组1:1位抢占优先级,3位响应优先级
; 组2:2位抢占优先级,2位响应优先级
; 组3:3位抢占优先级,1位响应优先级
; 组4:4位抢占优先级,0位响应优先级
; NVIC_SubPriority和NVIC_PreemptionPriority的原则是,数值越小,越优
;
; 返回值：无
; *******************************************************************************
        AREA ||i.MY_NVIC_Init||, CODE, READONLY, ALIGN=2

|SCS_BASE|
        DCD      0xe000e400

; void MY_NVIC_Init(u8 NVIC_PreemptionPriority,u8 NVIC_SubPriority,u8 NVIC_Channel,u8 NVIC_Group)	 
MY_NVIC_Init PROC
        PUSH     {r4-r8,lr}
        MOV      r7,r0							; 获取NVIC_PreemptionPriority
        MOV      r8,r1							; 获取NVIC_SubPriority
        MOV      r4,r2							; 获取NVIC_Channel
        MOV      r5,r3							; 获取NVIC_Group
        MOV      r0,r5
        BL       MY_NVIC_PriorityGroupConfig		; 设置分组
        RSB      r0,r5,#4						; RSB 反向减法
        LSL      r6,r7,r0
        MOVS     r0,#0xf
        ASRS     r0,r0,r5
        AND      r0,r0,r8
        ORRS     r6,r6,r0
        AND      r6,r6,#0xf						; 取低四位
        ASRS     r2,r4,#31
        ADD      r2,r4,r2,LSR #27
        ASRS     r2,r2,#5
        LSLS     r2,r2,#2
        ADD      r2,r2,#0xe000e000
        LDR      r2,[r2,#0x100]					; NVIC_BASE
        MOV      r1,r4
        ASRS     r3,r4,#31
        ADD      r3,r4,r3,LSR #27
        ASRS     r3,r3,#5
        SUB      r12,r4,r3,LSL #5
        MOVS     r3,#1
        LSL      r3,r3,r12
        ORRS     r2,r2,r3
        MOV      r0,r4
        ASRS     r3,r4,#31
        ADD      r3,r4,r3,LSR #27
        ASRS     r3,r3,#5
        LSLS     r3,r3,#2
        ADD      r3,r3,#0xe000e000
        STR      r2,[r3,#0x100]					; 使能中断位(要清除的话,设置ICER对应位为1即可)
        LDR      r0,|SCS_BASE|
        LDRB     r0,[r0,r4]
        ORR      r0,r0,r6,LSL #4
        LDR      r1,|SCS_BASE|
        STRB     r0,[r1,r4]						; 设置响应优先级和抢断优先级 
        POP      {r4-r8,pc}
        ENDP

; *****************************************************************************
; 功  能：设置NVIC分组
; 
; 参  数：r1: NVIC_Group:NVIC分组 0~4 总共5组
; 		 r2: temp1
;		 r0: temp
; 
; 返回值：无
; *****************************************************************************
        AREA ||i.MY_NVIC_PriorityGroupConfig||, CODE, READONLY, ALIGN=2

|SCB_BASE|
        DCD      0xe000ed0c
|Key|
        DCD      0x05fa0000

; void MY_NVIC_PriorityGroupConfig(u8 NVIC_Group)	 
MY_NVIC_PriorityGroupConfig PROC
        MOV      r1,r0
        MOVS     r3,#7
        BIC      r2,r3,r1				; 取后三位
        LSLS     r2,r2,#8
        LDR      r3,|SCB_BASE|
        LDR      r0,[r3,#0]				; 读取先前的设置
        MOV      r3,#0x0000F8FF
        ANDS     r0,r0,r3				; 清空先前分组
        LDR      r3,|Key|
        ORRS     r0,r0,r3				; 写入钥匙
        ORRS     r0,r0,r2
        LDR      r3,|SCB_BASE|
        STR      r0,[r3,#0]				; 设置分组	  
        BX       lr
        ENDP

; ****************************************************************************
; 功  能：设置向量表偏移地址
;
; 参  数：r0: NVIC_VectTab:基址
; 		 r1: Offset:偏移量	
; 
; 返回值：无
; ****************************************************************************
        AREA ||i.MY_NVIC_SetVectorTable||, CODE, READONLY, ALIGN=2

|SCB_VTOR|
        DCD      0xe000ed08

; void MY_NVIC_SetVectorTable(u32 NVIC_VectTab,u32 Offset)	
MY_NVIC_SetVectorTable PROC
        LSRS     r2,r1,#9
        LSLS     r2,r2,#9
        ORRS     r2,r2,r0				; VTOR低9位保留,即[8:0]保留。
        LDR      r3,|SCB_VTOR|
        STR      r2,[r3,#0]				; 设置NVIC的向量表偏移寄存器
        BX       lr
        ENDP

; ****************************************************************************
; 功  能：系统时钟初始化函数
;
; 参  数：r4: plln:主PLL倍频系数(PLL倍频),取值范围:64~432.
; 		 r5: pllm:主PLL和音频PLL分频系数(PLL之前的分频),取值范围:2~63.
; 		 r6: pllp:系统时钟的主PLL分频系数(PLL之后的分频),取值范围:2,4,6,8.(仅限这4个值!)
; 		 r7: pllq:USB/SDIO/随机数产生器等的主PLL分频系数(PLL之后的分频),取值范围:2~15.
;
; 返回值：无
; ****************************************************************************
        AREA ||i.Stm32_Clock_Init||, CODE, READONLY, ALIGN=2

|RCC_BASE|
        DCD      0x40023800
|ReSet_HSEON_CSSON_PLLON|
        DCD      0xfef6ffff
|ReSet_RCC_PLLCFGR|
        DCD      0x24003010

; void Stm32_Clock_Init(u32 plln,u32 pllm,u32 pllp,u32 pllq)
Stm32_Clock_Init PROC
        PUSH     {r4-r7,lr}
        MOV      r4,r0
        MOV      r5,r1
        MOV      r6,r2
        MOV      r7,r3
        LDR      r0,|RCC_BASE|
        LDR      r0,[r0,#0]
        ORR      r0,r0,#0x00000001
        LDR      r1,|RCC_BASE|
        STR      r0,[r1,#0]						; 设置HISON,开启内部高速RC振荡
        MOVS     r0,#0x00000000
        LDR      r1,|RCC_BASE|
        ADDS     r1,r1,#8
        STR      r0,[r1,#0]						; CFGR清零
        LDR      r0,|RCC_BASE|
        LDR      r0,[r0,#0]
        LDR      r1,|ReSet_HSEON_CSSON_PLLON|		; HSEON,CSSON,PLLON清零 
        ANDS     r0,r0,r1
        LDR      r1,|RCC_BASE|
        STR      r0,[r1,#0]
        LDR      r0,|ReSet_RCC_PLLCFGR|			; PLLCFGR恢复复位值 
        ADDS     r1,r1,#4
        STR      r0,[r1,#0]
        SUBS     r0,r1,#4
        LDR      r0,[r0,#0]
        BIC      r0,r0,#0x40000					; HSEBYP清零,外部晶振不旁路
        SUBS     r1,r1,#4
        STR      r0,[r1,#0]
        MOVS     r0,#0x00000000
        LDR      r1,|RCC_BASE|
        ADDS     r1,r1,#0xc
        STR      r0,[r1,#0]						; 禁止RCC时钟中断 
        MOV      r3,r7
        MOV      r2,r6
        MOV      r1,r5
        MOV      r0,r4
        BL       Sys_Clock_Set					; 设置时钟 
        MOVS     r1,#0
        MOV      r0,r1
        BL       MY_NVIC_SetVectorTable			; 配置向量表
        POP      {r4-r7,pc}
        ENDP

; ****************************************************************************
; 功  能：时钟设置函数
; 
; 参  数：Fvco=Fs*(plln/pllm);
; 		 Fsys=Fvco/pllp=Fs*(plln/(pllm*pllp))
; 		 Fusb=Fvco/pllq=Fs*(plln/(pllm*pllq))
; 		 Fvco:VCO频率
; 		 Fsys:系统时钟频率
; 		 Fusb:USB,SDIO,RNG等的时钟频率
; 		 Fs:PLL输入时钟频率,可以是HSI,HSE等. 
; 		 
; 		 r4: plln:主PLL倍频系数(PLL倍频),取值范围:64~432.
; 		 r5: pllm:主PLL和音频PLL分频系数(PLL之前的分频),取值范围:2~63.
; 		 r2: pllp:系统时钟的主PLL分频系数(PLL之后的分频),取值范围:2,4,6,8.(仅限这4个值!)
; 		 r3: pllq:USB/SDIO/随机数产生器等的主PLL分频系数(PLL之后的分频),取值范围:2~15.
; 		 r1: retry
; 		 r0: status
;
; 外部晶振为8M的时候,推荐值：plln=336,pllm=25,pllp=2,pllq=7.
; 					 得到：Fvco=25*(336/25)=336Mhz
;      				 	   Fsys=336/2=168Mhz
;   					   Fusb=336/7=48Mhz
; 返回值：0,成功;1,失败。
; ****************************************************************************
        AREA ||i.Sys_Clock_Set||, CODE, READONLY, ALIGN=2

;|RCC_BASE|
        ;DCD      0x40023800
|PWR_BASE|
        DCD      0x40007000
|FLASH_R_BASE|
        DCD      0x40023c00

; u8 Sys_Clock_Set(u32 plln,u32 pllm,u32 pllp,u32 pllq)
Sys_Clock_Set PROC
        PUSH     {r4-r7,lr}
        MOV      r4,r0
        MOV      r5,r1
        MOVS     r1,#0
        MOVS     r0,#0
        LDR      r6,|RCC_BASE|
        LDR      r6,[r6,#0]				; RCC_CR
        ORR      r6,r6,#0x10000
        LDR      r7,|RCC_BASE|
        STR      r6,[r7,#0]				; HSE 开启 
        B        |while_HSE RDY|
|retry++|
        ADDS     r6,r1,#1
        UXTH     r1,r6
|while_HSE RDY|							; 等待HSE RDY
        LDR      r6,|RCC_BASE|
        LDR      r6,[r6,#0]
        AND      r6,r6,#0x20000
        CBNZ     r6,|if_HSE_UNABLE_READY|
        MOV      r6,#0x1fff
        CMP      r1,r6
        BLT      |retry++|
|if_HSE_UNABLE_READY|
        MOV      r6,#0x1fff
        CMP      r1,r6
        BNE      |HSE_READY|
        MOVS     r0,#1					; HSE无法就绪,status=1
        B        |return|
|HSE_READY|
        LDR      r6,|RCC_BASE|
        ADDS     r6,r6,#0x40
        LDR      r6,[r6,#0]
        ORR      r6,r6,#0x10000000
        LDR      r7,|RCC_BASE|
        ADDS     r7,r7,#0x40
        STR      r6,[r7,#0]				; 电源接口时钟使能
        LDR      r6,|PWR_BASE|
        LDR      r6,[r6,#0]
        ORR      r6,r6,#0xc000
        LDR      r7,|PWR_BASE|
        STR      r6,[r7,#0]				; 高性能模式,时钟可到168Mhz
        LDR      r6,|RCC_BASE|
        ADDS     r6,r6,#8
        LDR      r6,[r6,#0]
        ORR      r6,r6,#0x9400
        LDR      r7,|RCC_BASE|
        ADDS     r7,r7,#8
        STR      r6,[r7,#0]				; HCLK 不分频;APB1 4分频;APB2 2分频. 
        LDR      r6,|RCC_BASE|
        LDR      r6,[r6,#0]
        BIC      r6,r6,#0x1000000
        LDR      r7,|RCC_BASE|
        STR      r6,[r7,#0]				; 关闭主PLL
        ORR      r6,r5,r4,LSL #6
        MOVS     r7,#1
        RSB      r7,r7,r2,LSR #1
        ORR      r6,r6,r7,LSL #16
        ORR      r6,r6,r3,LSL #24
        ORR      r6,r6,#0x400000
        LDR      r7,|RCC_BASE|
        ADDS     r7,r7,#4
        STR      r6,[r7,#0]				; 配置主PLL,PLL时钟源来自HSE
        SUBS     r6,r7,#4
        LDR      r6,[r6,#0]
        ORR      r6,r6,#0x1000000
        SUBS     r7,r7,#4
        STR      r6,[r7,#0]				; 打开主PLL
        NOP      
|while_PLL_READY|
        LDR      r6,|RCC_BASE|
        LDR      r6,[r6,#0]
        AND      r6,r6,#0x2000000
        CMP      r6,#0
        BEQ      |while_PLL_READY|		; 等待PLL准备好 
        LDR      r6,|FLASH_R_BASE|
        LDR      r6,[r6,#0]
        ORR      r6,r6,#0x100
        LDR      r7,|FLASH_R_BASE|
        STR      r6,[r7,#0]				; 指令预取使能.
        MOV      r6,r7
        LDR      r6,[r6,#0]
        ORR      r6,r6,#0x200
        STR      r6,[r7,#0]				; 指令cache使能.
        MOV      r6,r7
        LDR      r6,[r6,#0]
        ORR      r6,r6,#0x400
        STR      r6,[r7,#0]				; 数据cache使能.
        MOV      r6,r7
        LDR      r6,[r6,#0]
        ORR      r6,r6,#5
        STR      r6,[r7,#0]				; 5个CPU等待周期. 
        LDR      r6,|RCC_BASE|
        ADDS     r6,r6,#8
        LDR      r6,[r6,#0]
        BIC      r6,r6,#3
        LDR      r7,|RCC_BASE|
        ADDS     r7,r7,#8
        STR      r6,[r7,#0]				; 清零
        MOV      r6,r7
        LDR      r6,[r6,#0]
        ORR      r6,r6,#2
        STR      r6,[r7,#0]				; 选择主PLL作为系统时钟	
        NOP      
|while_PLL_SET_SUCCESS|
        LDR      r6,|RCC_BASE|
        ADDS     r6,r6,#8
        LDR      r6,[r6,#0]
        AND      r6,r6,#0xc
        CMP      r6,#8
        BNE      |while_PLL_SET_SUCCESS|	; 等待主PLL作为系统时钟成功. 
|return|
        POP      {r4-r7,pc}
        ENDP

; ****************************************************************************
; 功  能：系统软复位   
; 
; 参  数：无
; 
; 返回值：无
; ****************************************************************************
        AREA ||i.Sys_Soft_Reset||, CODE, READONLY, ALIGN=2

|ReSet_data|
        DCD      0x05fa0004
|SCB_AIRCR|
        DCD      0xe000ed0c

; void Sys_Soft_Reset(void)
Sys_Soft_Reset PROC
        LDR      r0,|ReSet_data|
        LDR      r1,|SCB_AIRCR|
        STR      r0,[r1,#0]
        BX       lr
        ENDP

; ****************************************************************************
; 功  能：系进入待机模式	
; 
; 参  数：无
; 
; 返回值：无
; ****************************************************************************
         AREA ||i.Sys_Standby||, CODE, READONLY, ALIGN=2

|SCB_SCR|
        DCD      0xe000ed10
|RCC_APB1ENR|
        DCD      0x40023840
;|PWR_BASE|
        ;DCD      0x40007000

; void Sys_Standby(void)
Sys_Standby PROC
        PUSH     {r4,lr}
        LDR      r0,|SCB_SCR|
        LDR      r0,[r0,#0]
        ORR      r0,r0,#4
        LDR      r1,|SCB_SCR|
        STR      r0,[r1,#0]					; 使能SLEEPDEEP位 (SYS->CTRL)
        LDR      r0,|RCC_APB1ENR|
        LDR      r0,[r0,#0]
        ORR      r0,r0,#0x10000000
        LDR      r1,|RCC_APB1ENR|
        STR      r0,[r1,#0]					; 使能电源时钟 
        LDR      r0,|PWR_BASE|
        LDR      r0,[r0,#4]					; PWR_CSR
        ORR      r0,r0,#0x100
        LDR      r1,|PWR_BASE|
        STR      r0,[r1,#4]					; 设置WKUP用于唤醒
        MOV      r0,r1
        LDR      r0,[r0,#0]					; PWR_CR
        ORR      r0,r0,#4
        STR      r0,[r1,#0]					; 清除Wake-up 标志
        MOV      r0,r1
        LDR      r0,[r0,#0]					; PWR_CR
        ORR      r0,r0,#2
        STR      r0,[r1,#0]					; PDDS置位   	
        BL       WFI_SET						; 执行WFI指令,进入待机模式
        POP      {r4,pc}
        ENDP

; ****************************************************************************
; 功  能：执行汇编指令WFI  
;
; 参  数：无
;
; 返回值：无
; ****************************************************************************
	AREA ||.emb_text||, CODE

; void WFI_SET(void)
WFI_SET PROC
		WFI

		ENDP

; ****************************************************************************
; 功  能：关闭所有中断(但是不包括fault和NMI中断)
;
; 参  数：无
;
; 返回值：无
; ****************************************************************************
	AREA ||.emb_text||, CODE

; void INTX_DISABLE(void)
INTX_DISABLE PROC
		CPSID 	I
		BX 		LR 

		ENDP

; ****************************************************************************
; 功  能：开启所有中断
;
; 参  数：无
;
; 返回值：无
; ****************************************************************************
	AREA ||.emb_text||, CODE

; void INTX_ENABLE(void)
INTX_ENABLE PROC
		CPSIE 	I
		BX 		LR 

		ENDP

; ****************************************************************************
; 功  能：设置栈顶地址
;
; 参  数：addr:栈顶地址
;
; 返回值：无
; ****************************************************************************
	AREA ||.emb_text||, CODE

; void MSR_MSP(u32 addr) 
MSR_MSP PROC
		MSR 	MSP, r0  		; set Main Stack value
		BX 		r14

		ENDP

        END
