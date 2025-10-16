        THUMB
        REQUIRE8
        PRESERVE8

        EXPORT delay_init
        EXPORT delay_ms
        EXPORT delay_us
        EXPORT delay_xms

        AREA ||i.delay_init||, CODE, READONLY, ALIGN=2

delay_init PROC
        MOV      r1,#0xe000e000
        LDR      r1,[r1,#0x10]
        BIC      r1,r1,#4
        MOV      r2,#0xe000e000
        STR      r1,[r2,#0x10]
        ASRS     r2,r0,#31
        ADD      r2,r0,r2,LSR #29
        UBFX     r2,r2,#3,#8
        LDR      r3,|L0.56|
        STRB     r2,[r3,#0]
        MOV      r1,r3
        LDRB     r1,[r1,#0]  ; fac_us
        ADD      r2,r1,r1,LSL #1
        RSB      r1,r2,r1,LSL #7
        MOV      r2,#0xffff
        AND      r1,r2,r1,LSL #3
        LDR      r2,|L0.60|
        STRH     r1,[r2,#0]
        BX       lr
        ENDP

|L0.56|
        DCD      fac_us
|L0.60|
        DCD      fac_ms

        AREA ||i.delay_ms||, CODE, READONLY, ALIGN=1

delay_ms PROC
        PUSH     {r4-r6,lr}
        MOV      r4,r0
        MOV      r0,#0x21c
        SDIV     r0,r4,r0
        UXTB     r6,r0
        MOV      r0,#0x21c
        SDIV     r1,r4,r0
        MLS      r0,r0,r1,r4
        UXTH     r5,r0
        B        |L1.42|
|L1.30|
        MOV      r0,#0x21c
        BL       delay_xms
        SUBS     r0,r6,#1
        UXTB     r6,r0
|L1.42|
        CMP      r6,#0
        BNE      |L1.30|
        CBZ      r5,|L1.54|
        MOV      r0,r5
        BL       delay_xms
|L1.54|
        POP      {r4-r6,pc}
        ENDP


        AREA ||i.delay_us||, CODE, READONLY, ALIGN=2

delay_us PROC
        MOV      r1,r0
        CBNZ     r1,|L2.6|
|L2.4|
        BX       lr
|L2.6|
        LDR      r2,|L2.64|
        LDRB     r2,[r2,#0]  ; fac_us
        MULS     r2,r1,r2
        MOV      r3,#0xe000e000
        STR      r2,[r3,#0x14]
        MOVS     r2,#0
        STR      r2,[r3,#0x18]
        MOVS     r2,#1
        STR      r2,[r3,#0x10]
        NOP      
|L2.28|
        MOV      r2,#0xe000e000
        LDR      r0,[r2,#0x10]
        AND      r2,r0,#1
        CBZ      r2,|L2.48|
        AND      r2,r0,#0x10000
        CMP      r2,#0
        BEQ      |L2.28|
|L2.48|
        MOVS     r2,#0
        MOV      r3,#0xe000e000
        STR      r2,[r3,#0x10]
        STR      r2,[r3,#0x18]
        NOP      
        B        |L2.4|
        ENDP

        DCW      0x0000
|L2.64|
        DCD      fac_us

        AREA ||i.delay_xms||, CODE, READONLY, ALIGN=2

delay_xms PROC
        MOV      r1,r0
        LDR      r2,|L3.56|
        LDRH     r2,[r2,#0]  ; fac_ms
        MULS     r2,r1,r2
        MOV      r3,#0xe000e000
        STR      r2,[r3,#0x14]
        MOVS     r2,#0
        STR      r2,[r3,#0x18]
        MOVS     r2,#1
        STR      r2,[r3,#0x10]
        NOP      
|L3.24|
        MOV      r2,#0xe000e000
        LDR      r0,[r2,#0x10]
        AND      r2,r0,#1
        CBZ      r2,|L3.44|
        AND      r2,r0,#0x10000
        CMP      r2,#0
        BEQ      |L3.24|
|L3.44|
        MOVS     r2,#0
        MOV      r3,#0xe000e000
        STR      r2,[r3,#0x10]
        STR      r2,[r3,#0x18]
        BX       lr
        ENDP

|L3.56|
        DCD      fac_ms

        AREA ||.arm_vfe_header||, DATA, READONLY, NOALLOC, ALIGN=2

        DCD      0x00000000

        AREA ||.data||, DATA, ALIGN=1

fac_us
        DCB      0x00,0x00
fac_ms
        DCW      0x0000

        KEEP fac_us
        KEEP fac_ms

        END
