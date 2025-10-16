        AREA    |.text|, CODE, READONLY
        THUMB

        ; RCC and GPIO Definitions   
RCC_BASE        EQU     0x40023800   
GPIOB_BASE      EQU     0x40020400   
GPIOA_BASE      EQU     0x40020000  
RCC_AHB1ENR     EQU     0x30   
GPIOB_MODER     EQU     0x00   
GPIOB_BSRR      EQU     0x18   
GPIOA_MODER     EQU     0x00   
GPIOA_BSRR      EQU     0x18  
GPIOBEN         EQU     (1 << 1)

        ; Function to initialize GPIOB
        EXPORT  asm_init_ports   
asm_init_ports
        LDR     R0, =RCC_BASE
        LDR     R1, [R0, #RCC_AHB1ENR]
        ORR     R1, R1, #GPIOBEN
        STR     R1, [R0, #RCC_AHB1ENR]

        LDR     R0, =GPIOB_BASE
        LDR     R1, [R0, #GPIOB_MODER]
        MOV     R2, #0x55555555        ; Configure all pins as output
        STR     R2, [R0, #GPIOB_MODER]
        BX      LR

        ; Function to set a pin high on GPIOB
        EXPORT  asm_set_pin_led 
asm_set_pin_led
        LDR     R0, =GPIOB_BASE
        LDR     R1, [R0, #GPIOB_BSRR]
        MOV     R2, #1
        LSL     R2, R2, R1             ; Shift pin number to correct BSRR position
        STR     R2, [R0, #GPIOB_BSRR]
        BX      LR

        ; Function to reset a pin on GPIOB
        EXPORT  asm_reset_pin_led   
asm_reset_pin_led
        LDR     R0, =GPIOB_BASE
        LDR     R1, [R0, #GPIOB_BSRR]
        MOV     R2, #0
        LSL     R2, R2, R1             ; Shift pin number to reset position in BSRR
        STR     R2, [R0, #GPIOB_BSRR]
        BX      LR
		
		EXPORT  asm_set_pin_beep  
asm_set_pin_beep
        LDR     R0, =GPIOA_BASE
        LDR     R1, [R0, #GPIOA_BSRR]
        MOV     R2, #1
        LSL     R2, R2, R1             ; Shift pin number to reset position in BSRR
        STR     R2, [R0, #GPIOA_BSRR]
        BX      LR
		
		EXPORT  asm_reset_pin_beep 
asm_reset_pin_beep
        LDR     R0, =GPIOA_BASE
        LDR     R1, [R0, #GPIOA_BSRR]
        MOV     R2, #0
        LSL     R2, R2, R1             ; Shift pin number to reset position in BSRR
        STR     R2, [R0, #GPIOA_BSRR]
        BX      LR
		
        END
