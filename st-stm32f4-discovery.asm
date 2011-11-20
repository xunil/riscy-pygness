        ;; skip the emacs mode line
;;; -*- Mode:Asm Mode:outline-minor-mode outline-regexp:";;;+" comment-start: "; " -*-

;;; Robert Liesenfeld    xunil@xunil.net   
;;;    Based on the olimex-stm32-p103.asm file by Frank Sergeant  frank@pygmy.utoh.org
        
;;; st-stm32f4-discovery.asm
;;; Equates specific to the ST STM32F4 Discovery ARM Cortex M4 board

        ;; It will be preprocessed into st-stm32f4-discovery.s by
        ;; the preprocessor that converts semicolons to at-signs so
        ;; it can be included in various assembly programs for the
        ;; ST board.

;;; Board equates

        ;; The STAT LED is on Port D, bit 12
        ;; Note, Port C0.26 is in position 26 (dec) or 0x1A (hex)
        ;; in decimal

        ;;  3322 2222 2222 1111 1111 1100 0000 0000
        ;;  1098 7654 3210 9876 5432 1098 7654 3210
        ;;  xxxx xxxx xxxx xxxx xxxY xxxx xxxx xxxx
        ;;  0000 0000 0000 0000 0000 0000 0000 0000  in binary
        ;;     0    0    0    0    1    0    0    0  is 0x00001000 in hex

        ;; So an orr or bic(and) mask is 0x00001000
        
        .equ STAT_LED_MASK, 0x00001000
        .equ LED_MASK, STAT_LED_MASK

        ;; note, this board has an 8 MHz external crystal

;;; STM32F4 processor equates

        .equ PERIPH_BASE     ,   0x40000000                                                                
        .equ PERIPH_BASE_APB1,   (PERIPH_BASE + 0x00000)
        .equ PERIPH_BASE_APB2,   (PERIPH_BASE + 0x10000)
        .equ PERIPH_BASE_AHB1,   (PERIPH_BASE + 0x20000)
        .equ PERIPH_BASE_AHB2,   0x50000000
        .equ PERIPH_BASE_AHB3,   0x60000000

        .equ GPIOA_BASE,   (PERIPH_BASE_AHB1 + 0x0000)                                           
        .equ GPIOB_BASE,   (PERIPH_BASE_AHB1 + 0x0400)
        .equ GPIOC_BASE,   (PERIPH_BASE_AHB1 + 0x0800)
        .equ GPIOD_BASE,   (PERIPH_BASE_AHB1 + 0x0C00)
        .equ GPIOE_BASE,   (PERIPH_BASE_AHB1 + 0x1000)
        .equ GPIOF_BASE,   (PERIPH_BASE_AHB1 + 0x1400)
        .equ GPIOG_BASE,   (PERIPH_BASE_AHB1 + 0x1800)
        .equ GPIOH_BASE,   (PERIPH_BASE_AHB1 + 0x1C00)
        .equ GPIOI_BASE,   (PERIPH_BASE_AHB1 + 0x2000)

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

        .equ GPIOB_MODER     ,   GPIOB_BASE + 0x00
        .equ GPIOB_OTYPER    ,   GPIOB_BASE + 0x04
        .equ GPIOB_OSPEEDR   ,   GPIOB_BASE + 0x08
        .equ GPIOB_PUPDR     ,   GPIOB_BASE + 0x0C
        .equ GPIOB_IDR       ,   GPIOB_BASE + 0x10
        .equ GPIOB_ODR       ,   GPIOB_BASE + 0x14
        .equ GPIOB_BSRR      ,   GPIOB_BASE + 0x18
        .equ GPIOB_LCKR      ,   GPIOB_BASE + 0x1C
        .equ GPIOB_AFRL      ,   GPIOB_BASE + 0x20
        .equ GPIOB_AFRH      ,   GPIOB_BASE + 0x24

        .equ GPIOC_MODER     ,   GPIOC_BASE + 0x00
        .equ GPIOC_OTYPER    ,   GPIOC_BASE + 0x04
        .equ GPIOC_OSPEEDR   ,   GPIOC_BASE + 0x08
        .equ GPIOC_PUPDR     ,   GPIOC_BASE + 0x0C
        .equ GPIOC_IDR       ,   GPIOC_BASE + 0x10
        .equ GPIOC_ODR       ,   GPIOC_BASE + 0x14
        .equ GPIOC_BSRR      ,   GPIOC_BASE + 0x18
        .equ GPIOC_LCKR      ,   GPIOC_BASE + 0x1C
        .equ GPIOC_AFRL      ,   GPIOC_BASE + 0x20
        .equ GPIOC_AFRH      ,   GPIOC_BASE + 0x24

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

        .equ GPIOE_MODER     ,   GPIOE_BASE + 0x00
        .equ GPIOE_OTYPER    ,   GPIOE_BASE + 0x04
        .equ GPIOE_OSPEEDR   ,   GPIOE_BASE + 0x08
        .equ GPIOE_PUPDR     ,   GPIOE_BASE + 0x0C
        .equ GPIOE_IDR       ,   GPIOE_BASE + 0x10
        .equ GPIOE_ODR       ,   GPIOE_BASE + 0x14
        .equ GPIOE_BSRR      ,   GPIOE_BASE + 0x18
        .equ GPIOE_LCKR      ,   GPIOE_BASE + 0x1C
        .equ GPIOE_AFRL      ,   GPIOE_BASE + 0x20
        .equ GPIOE_AFRH      ,   GPIOE_BASE + 0x24

        .equ GPIOF_MODER     ,   GPIOF_BASE + 0x00
        .equ GPIOF_OTYPER    ,   GPIOF_BASE + 0x04
        .equ GPIOF_OSPEEDR   ,   GPIOF_BASE + 0x08
        .equ GPIOF_PUPDR     ,   GPIOF_BASE + 0x0C
        .equ GPIOF_IDR       ,   GPIOF_BASE + 0x10
        .equ GPIOF_ODR       ,   GPIOF_BASE + 0x14
        .equ GPIOF_BSRR      ,   GPIOF_BASE + 0x18
        .equ GPIOF_LCKR      ,   GPIOF_BASE + 0x1C
        .equ GPIOF_AFRL      ,   GPIOF_BASE + 0x20
        .equ GPIOF_AFRH      ,   GPIOF_BASE + 0x24

        .equ GPIOG_MODER     ,   GPIOG_BASE + 0x00
        .equ GPIOG_OTYPER    ,   GPIOG_BASE + 0x04
        .equ GPIOG_OSPEEDR   ,   GPIOG_BASE + 0x08
        .equ GPIOG_PUPDR     ,   GPIOG_BASE + 0x0C
        .equ GPIOG_IDR       ,   GPIOG_BASE + 0x10
        .equ GPIOG_ODR       ,   GPIOG_BASE + 0x14
        .equ GPIOG_BSRR      ,   GPIOG_BASE + 0x18
        .equ GPIOG_LCKR      ,   GPIOG_BASE + 0x1C
        .equ GPIOG_AFRL      ,   GPIOG_BASE + 0x20
        .equ GPIOG_AFRH      ,   GPIOG_BASE + 0x24

        .equ GPIOH_MODER     ,   GPIOH_BASE + 0x00
        .equ GPIOH_OTYPER    ,   GPIOH_BASE + 0x04
        .equ GPIOH_OSPEEDR   ,   GPIOH_BASE + 0x08
        .equ GPIOH_PUPDR     ,   GPIOH_BASE + 0x0C
        .equ GPIOH_IDR       ,   GPIOH_BASE + 0x10
        .equ GPIOH_ODR       ,   GPIOH_BASE + 0x14
        .equ GPIOH_BSRR      ,   GPIOH_BASE + 0x18
        .equ GPIOH_LCKR      ,   GPIOH_BASE + 0x1C
        .equ GPIOH_AFRL      ,   GPIOH_BASE + 0x20
        .equ GPIOH_AFRH      ,   GPIOH_BASE + 0x24

        .equ GPIOI_MODER     ,   GPIOI_BASE + 0x00
        .equ GPIOI_OTYPER    ,   GPIOI_BASE + 0x04
        .equ GPIOI_OSPEEDR   ,   GPIOI_BASE + 0x08
        .equ GPIOI_PUPDR     ,   GPIOI_BASE + 0x0C
        .equ GPIOI_IDR       ,   GPIOI_BASE + 0x10
        .equ GPIOI_ODR       ,   GPIOI_BASE + 0x14
        .equ GPIOI_BSRR      ,   GPIOI_BASE + 0x18
        .equ GPIOI_LCKR      ,   GPIOI_BASE + 0x1C
        .equ GPIOI_AFRL      ,   GPIOI_BASE + 0x20
        .equ GPIOI_AFRH      ,   GPIOI_BASE + 0x24

        ;; RCC registers, section 6.3, page 89, reference manual

        .equ RCC_BASE        ,   (PERIPH_BASE_AHB1 + 0x3800)
        .equ RCC_CR,      RCC_BASE + 0x00 ; clock control register, reset value 0x0000 XX83
          .equ PLLRDY, BIT25   ; hardware sets it to 1 when PLL is locked
          .equ PLLON,  BIT24   ; set to enable PLL
          .equ CSSON,  BIT19
          .equ HSEBYP, BIT18
          .equ HSERDY, BIT17   ; hardware sets it to 1 when external clock is stable
          .equ HSEON,  BIT16
                       ;;    bit 15:8 HSICAL
                       ;;    bit  7:3 HSITRIM
          .equ HSIRDY, BIT1
          .equ HSION,  BIT0

        ;; RCC map on page 111, section 6.3.11 of reference manual
        .equ RCC_PLLCFGR,      RCC_BASE + 0x04
        .equ RCC_CFGR,      RCC_BASE + 0x08
        ;;    bit 21:18  PLLMUL   ; 0 = input clock * 2,  1 = input clock * 3, etc.
        ;;    bit 17     PLLXTPRE ; HSE divider for PLL entry, 0 = not divided,  1 = divided by 2
        ;;    bit 16     PLLSRC   ; 0 = HSI/2,  1 = HSE
        ;;    bit 15:14  ADCPRE   ; set ADC clock frequency
        ;;    bit 13:11  PPRE2    ; APB high-speed prescaler (APB2) (division factor for PCLK2)
        ;;                          0xx = HCLK not divided, 100 = /2, 101 = /4, 110= /8, 111 = /16
        ;;    bit 10:8   PPRE1    ; APB low-speed prescaler (APB1) (division factor for PCLK1)
        ;;                          0xx = HCLK not divided, 100 = /2, 101 = /4, 110= /8, 111 = /16
        ;;    bit  7:4   HPRE     ; AHB prescaler (division factor for AHB clock)
        ;;                          0xxx SYSCLK not divided, 1000 /2, 1001 /4 (etc see page 94 referenc manual)
        ;;    bit  3:2   SWS      ; system clock switch status (set by hardware)
        ;;                          00 = HSI, 01 = HSE, 10 = PLL, 11 = N/A
        ;;    bit  1:0   SW       ; system clock switch (software selects SYSCLK source)
        ;;                          00 = HSI, 01 = HSE, 10 = PLL, 11 = N/A

        .equ RCC_CIR,       RCC_BASE + 0x0C ; clock interrupt register, reset value 0x0000 0000

        .equ RCC_AHB1RSTR	,		(RCC_BASE + 0x10)
        .equ RCC_AHB2RSTR	,		(RCC_BASE + 0x14)
        .equ RCC_AHB3RSTR	,		(RCC_BASE + 0x18)
        .equ RCC_APB1RSTR	,		(RCC_BASE + 0x20)
        .equ RCC_APB2RSTR	,		(RCC_BASE + 0x24)
        .equ RCC_AHB1ENR	,		(RCC_BASE + 0x30)
        .equ RCC_AHB2ENR	,		(RCC_BASE + 0x34)
        .equ RCC_AHB3ENR	,		(RCC_BASE + 0x38)
        .equ RCC_APB1ENR	,		(RCC_BASE + 0x40)
        .equ RCC_APB2ENR	,		(RCC_BASE + 0x44)
        ;;    bit 21     TIM11 EN
        ;;    bit 20     TIM10 EN
        ;;    bit 19     TIM9 EN
        ;;    bit 15     ADC3 EN
        ;;    bit 14     USART1 EN
        ;;    bit 13     TIM8 EN
        ;;    bit 12     SPI1 EN
        ;;    bit 11     TIM1 EN
        ;;    bit 10     ADC2 EN
        ;;    bit  9     ADC1 EN
        ;;    bit  8     IOPG EN
        ;;    bit  7     IOPF EN
        ;;    bit  6     IOPE EN
        ;;    bit  5     IOPD EN
        ;;    bit  4     IOPC EN
        ;;    bit  3     IOPB EN
        ;;    bit  2     IOPA EN
        ;;    bit  0     AFIO EN
        .equ RCC_AHB1LPENR,		(RCC_BASE + 0x50)
        .equ RCC_AHB2LPENR,		(RCC_BASE + 0x54)
        .equ RCC_AHB3LPENR,		(RCC_BASE + 0x58)
        .equ RCC_APB1LPENR,		(RCC_BASE + 0x60)
        .equ RCC_APB2LPENR,		(RCC_BASE + 0x64)
        .equ RCC_BDCR			,   (RCC_BASE + 0x70)
        .equ RCC_CSR			,	  (RCC_BASE + 0x74)
        .equ RCC_SSCGR		,	  (RCC_BASE + 0x80)
        .equ RCC_PLLI2SCFGR,	(RCC_BASE + 0x84)


        ;; STK (SysTick timer)
        ;; see STK register map in section 4.5.6 (page 152) of programming manual
        .equ STK_BASE, 0xE000E010
        .equ STK_CTRL ,   STK_BASE +    0 ;  SysTick control and status register
                                          ;    uses processor clock (AHB) by default.
                                          ;    Set bit 0 to enable.  reset value 0x0000 0004
        ;; I do not seeing a reset value of 0x0000 0004.  I see 0x0000 0000.  So, be sure
        ;; to set the bits explicitly.
          .equ STK_COUNTFLAG, BIT16  ; hardware sets it to '1' if timer counted to zero since the
                                     ; last time this bit was read.
          .equ STK_CLKSOURCE, BIT2   ; 0 = AHB/8,  1 = processor clock (AHB)
          .equ STK_TICKINT,   BIT1   ; 1 = enable interrupt flag
          .equ STK_ENABLE,    BIT0   ; 1 = enable timer 

        
        .equ STK_LOAD ,   STK_BASE +    4 ;  SysTick reload value register (24 bits)
        .equ STK_VAL ,    STK_BASE +    8 ;  SysTick current value register (24 bits)
        .equ STK_CALIB ,  STK_BASE + 0x0C ;  SysTick calibration value register

        ;; set following define at least temporarily so kernel.fth can continue to
        ;;  use T1TC to refer to read the counter value
        .equ T1TC, STK_VAL

        ;; table on page 129 the base addresses on page 106 seem inconsistent?
        ;.equ NVIC_BASE, 0xE000E100
        ;.equ NVIC_BASE, 0xE000EF00

        ;; SCB (System Control Block)
        ;; see SCB register map in section 4.4.14 (page 147) of programming manual
        .equ SCB_BASE, 0xE000ED00
        .equ SCB_CPUID,   SCB_BASE +    0
        .equ SCB_ICSR,    SCB_BASE +    4 ; interrupt control and state register
        .equ SCB_VTOR,    SCB_BASE +    8 ; vector table offset register
        .equ SCB_AIRCR,   SCB_BASE + 0x0C ; application interrupt and reset control register
        .equ SCB_SCR,     SCB_BASE + 0x10 ; system control register
        .equ SCB_CCR,     SCB_BASE + 0x14 ; configuration and control register
        ;; skip the SCB_SHPR* etc for now


        ;; Memory protection unit table on page 118
        ;.equ MEM_BASE, 0xE000E100

        ;; USART2 (serial port) (use either half or full-word access)
        ;; see USART register map in section 26.6.8 (page 776) of reference manual
        .equ USART2_BASE, 0x40004400
        .equ USART2_SR,   USART2_BASE +    0 ;  status register
        ;;     TXE   (transmit data register empty)            bit 7
        ;;           it is cleared by a write to USART2_DR
        ;;     TC    (transmission complete)                   bit 6
        ;;     RXNE  (read data register not empty)            bit 5
        ;;           it is cleared by reading USART2_DR
        ;;     IDLE                                            bit 4
        ;;     bits 3-0 for various errors

        .equ USART2_DR,   USART2_BASE +    4 ;  data register (ls byte)
        .equ USART2_BRR,  USART2_BASE +    8 ;  baud rate register
        ;;     bits 15:4 DIV_Mantissa[11:0] is mantissa of USARTDIV
        ;;     bits  3:0 DIV_Fraction[3:0] is fraction of USARTDIV
        
        .equ USART2_CR1,  USART2_BASE + 0x0C ;  control register 1, default 0x0000 0000
        ;;     bit 13    UE     USART enable
        ;;     bit 12     M     word length (0 = 8 bits, 1 = 9 bits)
        ;;     bit 11    WAKE   (0 = idle line, 1 = address mark)
        ;;     bit 10    PCE    parity control enable
        ;;     bit  9    PS     parity selection (0 = even, 1 = odd)
        ;;     bit  8    PEIE   parity interrupt enable
        ;;     bit  7    TXEIE  TXE interrupt enable
        ;;     bit  6    TCIE   transmission complete interrupt enable
        ;;     bit  5    RXNEIE RXNE interrupt enable
        ;;     bit  4    IDLEIE IDLE interrupt enable
        ;;     bit  3    TE     transmission enable
        ;;     bit  2    RE     receiver enable
        ;;     bit  1    RWU    receiver wakeup
        ;;     bit  0    SBK    send break

        .equ USART2_CR2,  USART2_BASE + 0x10 ;  control register 2, default 0x0000 0000
        ;;     bit 14    LINEN  LIN mode enable
        ;;     bit 13:12 STOP   (00 = 1 stop bit, 10 = 2 stop bits)
        ;;     bit 11    CLKEN  clock enable  (0 = CK pin disabled)
        ;;     bit 10    CPOL   CK pin polarity
        ;;     bit  9    CPHA   clock phase in synchronous mode
        ;;     bit 8:0   other bits we don't need for simple RS232
        
        .equ USART2_CR3,  USART2_BASE + 0x14 ;  control register 3, reset value 0x0000 0000

        .equ USART2_GTPR, USART2_BASE + 0x18 ;  guard time and prescaler, reset value 0x0000 0000

        .equ AFIO_BASE, 0x40010000
        
        
        ;; TIM2 registers, section 14, page 335, reference manual.
        ;; For register and bit descriptions, see section 14.4, page 371

        .equ TIM2_BASE, 0x40000000
        .equ TIM2_CR1,      TIM2_BASE + 0x00 ; control register 1, reset value 0x0000
           ;; bits 9:8 CKD clock division
          .equ TIMx_ARPE, BIT7   ; auto-reload preload enable
           ;; bits 6:5 CMS center-aligned mode selection
          .equ TIMx_DIR,  BIT4   ; 0 = upcounter,  1 = downcounter
                                 ;  this bit is read only in center-aligned or encoder mode
          .equ TIMx_OPM,  BIT3   ; one-pulse mode, 0 = not stopped at update event
          .equ TIMx_URS,  BIT2   ; update request source
          .equ TIMx_UDIS, BIT1   ; update disable, 0 = UEV enabled
          .equ TIMx_CEN,  BIT0   ; counter enable

        .equ TIM2_CR2,      TIM2_BASE + 0x04 ; control register 2, reset value 0x0000
          .equ TIMx_TI1S, BIT7   ; TI1 selection (which pin is connected)
           ;; bits 6:4 MMS master mode selection
          .equ TIMx_CCDS, BIT3   ; capture/compare DMA selection

        ;; lots of other timer registers we probably do not need to touch at this time
        
        .equ TIM2_CNT,      TIM2_BASE + 0x24 ; counter register
        .equ TIM2_PSC,      TIM2_BASE + 0x28 ; prescaler register (set to zero to prescale by 1)
        .equ TIM2_ARR,      TIM2_BASE + 0x2C ; auto-reload register
        
