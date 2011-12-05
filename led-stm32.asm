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

;;; Equates
        .equ GPIOD_BASE      ,   0x40020C00
        .equ GPIOD_MODER     ,   GPIOD_BASE + 0x00
        .equ GPIOD_OTYPER    ,   GPIOD_BASE + 0x04
        .equ GPIOD_OSPEEDR   ,   GPIOD_BASE + 0x08
        .equ GPIOD_PUPDR     ,   GPIOD_BASE + 0x0C
        .equ GPIOD_IDR       ,   GPIOD_BASE + 0x10
        .equ GPIOD_ODR       ,   GPIOD_BASE + 0x14
        .equ GPIOD_BSRR      ,   GPIOD_BASE + 0x18
        .equ GPIOD_LCKR      ,   GPIOD_BASE + 0x1C
        .equ GPIOD_AFRL      ,   GPIOD_BASE + 0x20
        .equ GPIOD_AFRH      ,   GPIOD_BASE + 0x24

        .equ RCC_BASE        ,   0x40023800
        .equ RCC_AHB1ENR     ,   RCC_BASE + 0x30

        .equ STACKINIT,   0x20005000

        .equ LEDDELAY,    800000

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

        ;; Enable the Port C peripheral clock by setting bit 4
        ldr r6, = RCC_AHB1ENR
        mov r0, 0x08
        str r0, [r6]

        ;; Set the config and mode bits for Port C bit 12 so it will
        ;; be a push-pull output (up to 50 MHz) by setting bits 19-16
        ;; to '0011'.

        ldr r6, = GPIOD_MODER
        ldr r0, = 0x1000000
        str r0, [r6]

        ;; Load R2 and R3 with the "on" and "off" constants
        mov r2, 0              ; value to turn on LED
        mov r3, 0x1000         ; value to turn off LED

        ldr r6, = GPIOD_ODR    ;  point to Port C output data register

loop:
        str r2, [r6]           ; clear Port C, pin 12, turning on LED
        ldr r1, = LEDDELAY
delay1:
        subs r1, 1
        bne delay1

        str r3, [r6]           ; set Port C, pin 12, turning off LED
        ldr r1, = LEDDELAY
delay2:
        subs r1, 1
        bne delay2

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
