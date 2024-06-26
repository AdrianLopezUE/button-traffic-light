;
;  Program: Button Traffic Light
;  Description: Setup a combination of leds to act like a traffic light in a loop
;  Author: Adrián López Montoro
;  Created: 08/06/2024
;

#include <avr/io.h>

.global main
main:
  ldi r16, _BV(PCIE2)
  sts PCICR, r16

  ldi r16, _BV(PCINT23)
  sts PCMSK2, r16
  
  sei
  ldi r16, _BV(SM1) | _BV(SE)
  out _SFR_IO_ADDR(SMCR), r16

  ; Configure leds to open for cars and close for pedestrians
  ldi r16, 0b00001100
  out _SFR_IO_ADDR(PORTB), r16

  loop:
    sleep
    rjmp loop


.global PCINT2_vect
PCINT2_vect:
  nop
  sbis _SFR_IO_ADDR(PIND), PD7
  rjmp cambioLuz
  reti

cambioLuz:
    ; Configure leds to warn cars
    ldi r16, 0b00010100
    out _SFR_IO_ADDR(PORTB), r16 
    ldi r17, 0b00000100
    out _SFR_IO_ADDR(PORTB), r17

    call warning_loop

    ; Configure leds to close for cars and open for pedestrians
    ldi r16, 0b00100010
    out _SFR_IO_ADDR(PORTB), r16
    call delay_15s

    ; Configure leds to warn pedestrians
    ldi r16, 0b00100010
    out _SFR_IO_ADDR(PORTB), r16 
    ldi r17, 0b00100000
    out _SFR_IO_ADDR(PORTB), r17

    call warning_loop

    ; Configure leds to open for cars and close for pedestrians
    ldi r16, 0b00001100
    out _SFR_IO_ADDR(PORTB), r16
    reti

; Warning blink
warning_loop:
  ldi r24, 8 
  L4: call warning_blink
      dec r24
      brne L4
      ret

warning_blink:
  out _SFR_IO_ADDR(PORTB), r16
  call delay_500ms
  out _SFR_IO_ADDR(PORTB), r17
  call delay_500ms
  ret

; Delays for leds timers
delay_500ms:
      ldi  r18, 41
      ldi  r19, 150
      ldi  r20, 128
  L1: dec  r20
      brne L1
      dec  r19
      brne L1
      dec  r18
      brne L1
      ret

delay_15s:
      ldi  r18, 5
      ldi  r19, 194
      ldi  r20, 134
      ldi  r21, 33
  L3: dec  r21
      brne L3
      dec  r20
      brne L3
      dec  r19
      brne L3
      dec  r18
      brne L3
      ret