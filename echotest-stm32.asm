;;; led-stm32.asm
;;; written by Frank Sergeant
;;;    frank@pygmy.utoh.org
;;;    http://pygmy.utoh.org/riscy
;;; This program is in the public domain.  See http://pygmy.utoh.org/riscy/cortex/
;;; for notes about the program and how to assemble, link, and burn to flash.

;;; Blink the LED on the Olimex STM32-P103 ARM Cortex M3 board.

;;; Directives
        .thumb                  ; (same as saying '.code 16')
        .syntax unified

        .include "equates-bits.s"
;;; Equates
        .equ PLLCLKIN, 8000000
        ;;    Main crystal clock frequency
        ;;    above (8 MHz) is the speed of both the STM32 HSI (internal
        ;;    RC) oscillator and the HSE (external crystal) oscillator on
        ;;    the Olimex board.
        
        .equ PLL_MULTIPLIER, 1   ;  Multiplier must be 1 since we turn off PLL

        .equ CPUDIVISOR, 1       ;  (does the Cortex have a cpu clock divisor?)
        
        ;.equ PCLKDIVISOR, 4      ; must be 1, 2, or 4
        .equ PCLKDIVISOR, 1      ; must be 1, 2, or 4

        .equ TIMER0_PRESCALE_DIVISOR, 1

        .equ BAUDRATE, 38400
        .equ SPIDIVISOR, 128     ; slow it way down for testing


;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Equates that do calculations and so are not likely to change
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Frequency is given in number of clocks per second

        ;; The Cortex M3 has two PCLKs
        
        .equ PLLCLK, (PLLCLKIN * PLL_MULTIPLIER)
        .equ CCLK, (PLLCLK / CPUDIVISOR)

        ;; The Cortex M3 terms would be HSI or HSE (for the external
        ;; or internal high-speed oscillators).  After going through
        ;; (or bypassing) the PLL, we get a SYSCLK which I think is
        ;; the same thing as what we called the CCLK on the LPC chips.
        .equ SYSCLK, CCLK

        ;; After the SYSCLK goes through the AHB prescaler
        ;; (/ 1,2,...512) it is called the HCLK.  So, maybe HCLK is
        ;; the Cortex M3 term for what we had been calling CCLK?
        ;; Maybe not.

        ;; The Cortex M3 has PCLK1 and PCLK2.
        ;; 
        ;;    APB1 peripherals use PCLK1 (up to 36 MHz)
        ;;    APB2 peripherals use PCLK2 (up to 72 MHz)

        .equ  PCLK, CCLK / PCLKDIVISOR   ; most timing depends on PCLK

        ;; Cortex M3 has two peripheral clocks, PCLK1 and PCLK2.  Set
        ;; them to the same value (hopefully their defaults are divide by 1)
        .equ PCLK1, PCLK
        .equ PCLK2, PCLK

        ;; So, to begin with, all the clocks stay at 8 MHz.
        
        ;; Following needs to be converted for the Cortex M3
        .equ PCLK_TIMER0_DIVISOR, PCLKDIVISOR
        
        .equ TIMER0FREQ, ((CCLK / PCLK_TIMER0_DIVISOR) / TIMER0_PRESCALE_DIVISOR)
        
        .equ  SPICLK, PCLK / SPIDIVISOR

        .equ GPIOA_BASE      ,   0x40020000
        .equ GPIOA_MODER     ,   GPIOA_BASE + 0x00
        .equ GPIOA_OTYPER    ,   GPIOA_BASE + 0x04
        .equ GPIOA_OSPEEDR   ,   GPIOA_BASE + 0x08
        .equ GPIOA_PUPDR     ,   GPIOA_BASE + 0x0C
        .equ GPIOA_IDR       ,   GPIOA_BASE + 0x10
        .equ GPIOA_ODR       ,   GPIOA_BASE + 0x14
        .equ GPIOA_BSRR      ,   GPIOA_BASE + 0x18
        .equ GPIOA_LCKR      ,   GPIOA_BASE + 0x1C
        .equ GPIOA_AFRL      ,   GPIOA_BASE + 0x20
        .equ GPIOA_AFRH      ,   GPIOA_BASE + 0x24

        .equ RCC_BASE        ,   0x40023800
        .equ RCC_CR          ,   RCC_BASE + 0x00
        .equ RCC_CFGR        ,   RCC_BASE + 0x08
        .equ RCC_AHB1ENR     ,   RCC_BASE + 0x30
        .equ RCC_APB1ENR     ,   RCC_BASE + 0x40

        .equ USART2_BASE     ,   0x40004400
        .equ USART2_SR       ,   USART2_BASE + 0x00
        .equ USART2_DR       ,   USART2_BASE + 0x04
        .equ USART2_BRR      ,   USART2_BASE + 0x08
        .equ USART2_CR1      ,   USART2_BASE + 0x0c
        .equ USART2_CR2      ,   USART2_BASE + 0x10
        .equ USART2_CR3      ,   USART2_BASE + 0x14
        .equ USART2_GTPR     ,   USART2_BASE + 0x18

        .equ RXNE            ,   BIT5
        .equ TXE             ,   BIT7
        .equ HSERDY          ,   BIT17
        .equ HSEON           ,   BIT16

        .equ STACKINIT,   0x20005000

.section .text
        .org 0

;;; Vectors
vectors:
        .word STACKINIT         ; stack pointer value when stack is empty
        .word _start + 1        ; reset vector (manually adjust to odd for thumb)
        .word _nmi_handler + 1  ;
        .word _hard_fault  + 1  ;
        .word _memory_fault + 1 ;
        .word _bus_fault + 1    ;
        .word _usage_fault + 1  ;

_start:

setup_clocks:

        ;; Initialize STM32 Clocks

        ;; Ideally, we would just take the defaults to begin with and
        ;; do nothing.  Because it is possible that HSI is not
        ;; accurate enough for the serial communication (USART2), we
        ;; will switch from the internal 8 MHz clock (HSI) to the
        ;; external 8 MHz clock (HSE).

        ldr r6, = RCC_CR
        mov r0, HSEON
        str r0, [r6]            ; turn on the external clock

awaitHSE:
        ldr r0, [r6]
        and r0, # HSERDY
        beq awaitHSE            ; hang here until external clock is stable

        ;; at this point, the HSE is running and stable but I suppose we have not yet
        ;; switched Sysclk to use it.

        ldr r6, = RCC_CFGR
        mov r0, # 1
        str r0, [r6]            ; switch to the external clock
        
        
        ;; Should we now turn off the HSION bit?
        
        ;; Enable the GPIOA peripheral clock by setting bit 0
        ldr r6, = RCC_AHB1ENR
        ldr r0, = BIT0
        str r0, [r6]

        ;; Enable the USART2 peripheral clock by setting bit 17
        ldr r6, = RCC_APB1ENR
        ldr r0, = BIT17
        str r0, [r6]

        
        ;; Set PORTA pins in alternate function mode
        ldr r6, = GPIOA_MODER
        ;;ldr r0, = 0x2AA
        mov r0, 0xA0
        str r0, [r6]

        ldr r6, = GPIOA_PUPDR
        ;;ldr r0, = 0x114            ; All pins of USART2 pulled up
        ldr r0, = 0x20               ; TX pin pulled up
        str r0, [r6]

        ;; Set alternate function 7 to enable USART2 pins on Port A
        ldr r6, = GPIOA_AFRL
        ldr r0, = 0x7700           ; Alternate function 7 for TX and RX pins of USART2 on PORTA 
        str r0, [r6]

enableuart:
        ;; set UE (usart enable) (bit 13), TE (transmit enable) (bit 3), and RE (receiver enable) (bit 2) 
        ldr r6, = USART2_CR1
        ;;.equ  USART_UE_TE_RE, (BIT13 + BIT3 + BIT2)
        ldr r0, = BIT13            ; UE bit - USART enable
        str r0, [r6]

setbaud:
        .equ BRRVALUE, (PCLK1 / BAUDRATE)
        ldr r6, = USART2_BRR
        ;ldr r0, = 0x00D0          ; 38400 bps
        ldr r0, = BRRVALUE         ; BAUDRATE bps
        str r0, [r6]

enabletxrx:
        ;; set TE (transmit enable) (bit 3), and RE (receiver enable) (bit 2) 
        ;; this should cause an idle frame to be sent
        ldr r6, = USART2_CR1
        ldr r0, [r6]
        orr r0, # 0x0000000C       ; = BIT3 + BIT2
        str r0, [r6]

        ldr r6, = USART2_SR
        ldr r7, = USART2_DR

awaitchar:
        ldr r0, [r6]
        and r0, # RXNE
        beq awaitchar          ; loop until character received

        ldr r0, [r7]           ; Retrieve received character from USART data register
        eor r0, 0x20           ; Swap letter case
        str r0, [r7]           ; Put it back in the register
        
awaittx:
        ldr r0, [r6]
        and r0, # TXE
        beq awaittx            ; loop until character is done transmitting

        b awaitchar            ; continue forever

_dummy:                        ; if any int gets triggered, just hang in a loop
_nmi_handler:
_hard_fault:
_memory_fault:
_bus_fault:
_usage_fault:
        add r0, 1
        add r1, 1
        b _dummy
