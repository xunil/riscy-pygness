;;; chargen-stm32.asm
;;; written by Robert Liesenfeld <xunil@xunil.net>
;;; adapted from led-stm32.asm, written by Frank Sergeant <frank@pygmy.utoh.org>
;;;    http://pygmy.utoh.org/riscy
;;; This program is in the public domain.  See http://pygmy.utoh.org/riscy/cortex/
;;; for notes about the program and how to assemble, link, and burn to flash.

;;; Continuously loop through low ASCII, outputting characters via USART2.

;;; Directives
        .thumb                  ; (same as saying '.code 16')
        .syntax unified

        .include "equates-bits.s"
;;; Equates

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
        
        
        ;; Turn off the HSION bit
        ldr r6, = RCC_CR
        ldr r0, [r6]
        and r0, 0xFFFFFFFE      ; Zero the 0th bit
        str r0, [r6]
        
        ;; Enable the GPIOA peripheral clock by setting bit 0
        ldr r6, = RCC_AHB1ENR
        ldr r0, = BIT0
        str r0, [r6]

        
        ;; Set PORTA pins in alternate function mode
        ldr r6, = GPIOA_MODER
        ldr r0, [r6]
        ldr r5, = 0x2AA
        orr r0, r5
        str r0, [r6]

        ;; Set alternate function 7 to enable USART2 pins on Port A
        ldr r6, = GPIOA_AFRL
        ldr r0, = 0x77777              ; Alternate function 7 for TX and RX pins of USART2 on PORTA 
        str r0, [r6]

enableuart:
        ;; Enable the USART2 peripheral clock by setting bit 17
        ldr r6, = RCC_APB1ENR
        ldr r0, = BIT17
        str r0, [r6]

        ;; set UE (usart enable) (bit 13), TE (transmit enable) (bit 3), and RE (receiver enable) (bit 2) 
        ldr r6, = USART2_CR1
        ;;.equ  USART_UE_TE_RE, (BIT13 + BIT3 + BIT2)
        ldr r0, = BIT13            ; UE bit - USART enable
        str r0, [r6]

setbaud:
        ldr r6, = USART2_BRR
        mov r0, 0xD0          ; 38400 bps
        strb r0, [r6]

enabletxrx:
        ;; set TE (transmit enable) (bit 3), and RE (receiver enable) (bit 2) 
        ;; this should cause an idle frame to be sent
        ldr r6, = USART2_CR1
        ldr r0, [r6]
        orr r0, BIT3
        str r0, [r6]

        ;; Set up some address registers
        ldr r6, = USART2_SR
        ldr r7, = USART2_DR


initchargen:
        movs r0, 0x20          ; Start with ASCII space character

loop:
        strb r0, [r7]          ; Output the character
        
awaittx:
        ldr r1, [r6]           ; Load USART status register
        and r1, # TXE          ; Transmission complete?
        beq awaittx            ; loop until character is done transmitting

        add r0, 1              ; increment character
        cmp r0, 0x7F           ; did we hit the end of low ASCII?
        bge initchargen        ; yes, reset the character to space
                               ; otherwise...
        b loop                 ; continue forever

_dummy:                        ; if any int gets triggered, just hang in a loop
_nmi_handler:
_hard_fault:
_memory_fault:
_bus_fault:
_usage_fault:
        add r0, 1
        add r1, 1
        b _dummy
