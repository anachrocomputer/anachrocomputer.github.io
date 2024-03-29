; pov.asm --- drive the POV LEDs                               16/04/2006
; Copyright (c) 2006 John Honniball

.include "m8def.inc"

            .org 0x0000

; Two 74LS373 latches on Port D bits 0-7
; Latch controls on Port B bits 0 and 1
; Control bit HIGH: transparent
; Control bit LOW:  latch
; Blue LEDs on Port B bits 2 and 3

; Block of interrupt vectors for the AVR ATmega8
            rjmp RESET                              ; Reset Handler
            rjmp EXT_INT0                           ; IRQ0 Handler
            rjmp EXT_INT1                           ; IRQ1 Handler
            rjmp TIM2_COMP                          ; Timer2 Compare Handler
            rjmp TIM2_OVF                           ; Timer2 Overflow Handler
            rjmp TIM1_CAPT                          ; Timer1 Capture Handler
            rjmp TIM1_COMPA                         ; Timer1 CompareA Handler
            rjmp TIM1_COMPB                         ; Timer1 CompareB Handler
            rjmp TIM1_OVF                           ; Timer1 Overflow Handler
            rjmp TIM0_OVF                           ; Timer0 Overflow Handler
            rjmp SPI_STC                            ; SPI Transfer Complete Handler
            rjmp USART_RXC                          ; USART RX Complete Handler
            rjmp USART_UDRE                         ; UDR Empty Handler
            rjmp USART_TXC                          ; USART TX Complete Handler
            rjmp ADCONV                             ; ADC Conversion Complete Handler
            rjmp EE_RDY                             ; EEPROM Ready Handler
            rjmp ANA_COMP                           ; Analog Comparator Handler
            rjmp TWSI                               ; Two-wire Serial Interface Handler
            rjmp SPM_RDY                            ; Store Program Memory Ready Handler

; Start of program execution after a Reset
RESET:      ldi r16,low(RAMEND)                     ; Initialise stack to top of RAM
            out SPL,r16
            ldi r16,high(RAMEND)
            out SPH,r16
 
            ldi r16,0xff                            ; Set Port B to all outputs
            out DDRB,r16
            ldi r16,0xff                            ; Set Port D to all outputs
            out DDRD,r16

            sbi PortB,2                             ; Switch off blue LEDs
            sbi PortB,3
            sbi PortB,4

            cbi PortB,0                             ; Set both latches to hold
            cbi PortB,1                             ; by setting PB0 and PB1 low

loop:       ldi ZL,low(2*pattern)                   ; Z register pair points to pattern
            ldi ZH,high(2*pattern)                  ; in program memory

            ldi r18,14                              ; Load pattern length

patloop:    lpm r16,Z+                              ; Load pattern byte from program memory (upper)
            lpm r17,Z+                              ; Load pattern byte from program memory (lower)

            com r16                                 ; Output bits are active-low
            com r17

            out PortD,r16                           ; Send to latches
            sbi PortB,0                             ; Latch 373 on PB0
            rcall delay2us
            cbi PortB,0                             ; Clear PB0 again

            out PortD,r17                           ; Send to latches
            sbi PortB,1                             ; Latch 373 on PB1
            rcall delay2us
            cbi PortB,1                             ; Clear PB1 again

            ldi r19,8
dly:        rcall delay1ms
            dec	r19
            brne dly

            dec r18                                 ; Decrement pattern length counter
            brne patloop

    	    rjmp loop                               ; Loop back to start


; DELAY2US
; Delay for 2 microseconds
delay2us:   ldi r24,low(8)
            ldi r25,high(8)
dly9:       sbiw r24,1                               ; 2 cycles
            brne dly9                                ; 2 cycles
            ret
; DELAY1MS
; Delay for 1 millisecond
delay1ms:   ldi r24,low(4000)
            ldi r25,high(4000)
dly8:       sbiw r24,1                               ; 2 cycles
            brne dly8                                ; 2 cycles
            ret

pattern1:   .db 0x00,0x01                            ; Greek Key 12 pixels
            .db 0x07,0xfd                            
            .db 0x04,0x05
            .db 0x05,0xf5
            .db 0x05,0x15
            .db 0x05,0x55
            .db 0x05,0x45
            .db 0x05,0x7d
            .db 0x05,0x01
            .db 0x05,0xff
            .db 0x04,0x00
            .db 0x07,0xff

pattern2:   .db 0x1c,0x00                            ; Heart 16 pixels
            .db 0x3f,0x00
            .db 0x7f,0xc0
            .db 0xff,0xf0
            .db 0xff,0xf8
            .db 0x7f,0xfc
            .db 0x3f,0xfe
            .db 0x1f,0xff
            .db 0x3f,0xfe
            .db 0x7f,0xfc
            .db 0xff,0xf8
            .db 0xff,0xf0
            .db 0x7f,0xc0
            .db 0x3f,0x00
            .db 0x1c,0x00
            .db 0x00,0x00

pattern3:   .db 0xf7,0xfc                            ; Celtic Key 16 pixels
            .db 0xf7,0xfc
            .db 0xf7,0xfc
            .db 0xf7,0xfc
            .db 0x07,0x80
            .db 0xff,0xbc
            .db 0xff,0xbc
            .db 0xff,0xbc
            .db 0xff,0xbc
            .db 0xf0,0x3c
            .db 0xf7,0xfc
            .db 0xf7,0x3c
            .db 0xf7,0x3c
            .db 0xf7,0x3c
            .db 0x00,0x00
            .db 0x00,0x00

pattern:    .db 0x00,0x04                            ; Space Invader
            .db 0x07,0x0c                            ; Designed at Dorkbot Bristol
            .db 0x0f,0x98                            ; by Kathy Hinde and Tarim
            .db 0x19,0xf0                            ; 14 pixels including gap
            .db 0x39,0xe0
            .db 0x3f,0xe0
            .db 0x3f,0xe0
            .db 0x39,0xe0
            .db 0x19,0xf0
            .db 0x0f,0x98
            .db 0x07,0x0c
            .db 0x00,0x04
            .db 0x00,0x00
            .db 0x00,0x00

; Block of dummy interrupt routines
EXT_INT0:   reti                                     ; IRQ0 Handler
EXT_INT1:   reti                                     ; IRQ1 Handler
TIM2_COMP:  reti                                     ; Timer2 Compare Handler
TIM2_OVF:   reti                                     ; Timer2 Overflow Handler
TIM1_CAPT:  reti                                     ; Timer1 Capture Handler
TIM1_COMPA: reti                                     ; Timer1 CompareA Handler
TIM1_COMPB: reti                                     ; Timer1 CompareB Handler
TIM1_OVF:   reti                                     ; Timer1 Overflow Handler
TIM0_OVF:   reti                                     ; Timer0 Overflow Handler
SPI_STC:    reti                                     ; SPI Transfer Complete Handler
USART_RXC:  reti                                     ; USART RX Complete Handler
USART_UDRE: reti                                     ; UDR Empty Handler
USART_TXC:  reti                                     ; USART TX Complete Handler
ADCONV:     reti                                     ; ADC Conversion Complete Handler
EE_RDY:     reti                                     ; EEPROM Ready Handler
ANA_COMP:   reti                                     ; Analog Comparator Handler
TWSI:       reti                                     ; Two-wire Serial Interface Handler
SPM_RDY:    reti                                     ; Store Program Memory Ready Handler


