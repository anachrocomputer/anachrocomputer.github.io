; ledpwm.asm --- drive a blue LED with PWM                     21/04/2006
; Copyright (c) 2006 John Honniball

.include "m8def.inc"

            .org 0x0000

; Blue LED on Port B bit 2
            .equ LEDPORT = PortB
            .equ LEDBIT = 2

; This program drives a single LED connected to the AVR's I/O port.  It
; is connected so that the cathode of the LED is wired to the AVR pin,
; and the anode of the LED is wired to the 5V power supply via a
; resistor.  The value of that resistor depends on the colour of the LED,
; but is usually a few hundred ohms.

; We control the brightness of the LED with Pulse Width Modulation (PWM),
; for two reasons.  Firstly, we have no analog outputs on the AVR chip,
; only digital ones.  Secondly, a LED's brightness  does not respond
; linearly to variations in supply voltage, but it responds much better
; to PWM.

; Pulsating LED looks better if it never quite goes "off", but cycles from
; full brightness to a dim state, and back again
            .equ MINBRIGHT = 10
            .equ MAXBRIGHT = 255

; This value controls how fast the LED cycles from bright to dim.  It is
; the number of PWM cycles that we generate for each step in the brightness
; ramp, up and down.  Larger numbers will make the pulsation slower.
            .equ NCYCLES = 8

; Block of interrupt vectors for the AVR ATmega8 (unused in this program)
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

; Initialise the hardware
            ldi r16,0xff                            ; Set Port B to all outputs
            out DDRB,r16

            sbi LEDPORT,LEDBIT                      ; Switch off blue LED by setting output pin high

; Start with LED at its lowest level, then ramp up to maximum
dopwm:      ldi r17,MINBRIGHT                       ; R17 holds current brightness level
l1:         ldi r18,NCYCLES                         ; R18 counts PWM cycles, and hence pulsation speed
l2:         cbi LEDPORT,LEDBIT                      ; Output pin low, LED on
            mov r16,r17                             ; R16 controls length of delay (= R17)
            rcall delayn4us                         ; Call delay subroutine
            sbi LEDPORT,LEDBIT                      ; Output pin high, LED off
            ldi r16,255
            sub r16,r17                             ; R16 controls length of delay (= 255 - R17)
            rcall delayn4us                         ; Call delay subroutine
            dec r18                                 ; Decrement PWM cycle counter
            brne l2
            inc r17                                 ; Increase brightness by one step
            brne l1

; Now ramp back down to the minimum brightness
            ldi r17,MAXBRIGHT                       ; R17 holds current brightness level
l3:         ldi r18,NCYCLES                         ; R18 counts PWM cycles, and hence pulsation speed
l4:         cbi LEDPORT,LEDBIT                      ; Output pin low, LED on
            mov r16,r17                             ; R16 controls length of delay (= R17)
            rcall delayn4us                         ; Call delay subroutine
            sbi LEDPORT,LEDBIT                      ; Output pin high, LED off
            ldi r16,255
            sub r16,r17                             ; R16 controls length of delay (= 255 - R17)
            rcall delayn4us                         ; Call delay subroutine
            dec r18                                 ; Decrement PWM cycle counter
            brne l4
            dec r17                                 ; Decrease brightness by one step
            cpi r17,MINBRIGHT                       ; Have we reached the minimum?
            brne l3

            rjmp dopwm                              ; Loop back to start

; DELAYN4US
; Delay for (R16 * 4) microseconds
delayn4us:  tst r16                                 ; R16 = 0? (no delay)
            breq dly4
dly2:       ldi r24,low(16)
            ldi r25,high(16)
dly3:       sbiw r24,1                              ; 2 cycles
            brne dly3                               ; 2 cycles
            dec r16
            brne dly2
dly4:       ret                                     ; Return to caller


; Block of dummy interrupt routines (we don't use interrupts in this program)
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



