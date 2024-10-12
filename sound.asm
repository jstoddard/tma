; Sound driver and interrupt handler for Ten Minute Adventure
; by Jeremiah Stoddard

AY_ADDR equ $f5
AY_DATA equ $f6

; Turn off all music and sound
sound_off:
PROC
LOCAL loop
    ; disable interrupt handler sound routine
    ld  a, (isubstate)
    res 1, a
    ld  (isubstate), a
    ld  a, 8
    ; set each channel's volume to 0 (set registers 8-10 to 0) on AY chip
loop:
    out (AY_ADDR), a
    push af
    ld  a, 0
    out (AY_DATA), a
    pop af
    inc a
    cp 11
    jr  nz, loop
    ret
ENDP

; Turn off channels A and B
music_off:
    ; set ch_a_on and ch_b_on to 0 so sound routines aren't called during
    ; interrupts
    ld  a, 0
    ld  (ch_a_on), a
    ld  (ch_b_on), a
    ; set volume on channel a and b to 0 (registers 8-9)
    ld  a, 8
    out (AY_ADDR), a
    ld  a, 0
    out (AY_DATA), a
    ld  a, 9
    out (AY_ADDR), a
    ld  a, 0
    out (AY_DATA), a
    ret

; Turn on channels A and B
music_on:
    ; set ch_a_on and ch_b_on to 1 so sound routines are called during
    ; interrupts
    ld  a, 1
    ld  (ch_a_on), a
    ;ld  (ch_b_on), a
    ; set volume on channel a and b to $0F (registers 8-9)
    ld  a, 8
    out (AY_ADDR), a
    ld  a, $0F
    out (AY_DATA), a
    ;ld  a, 9
    ;out (AY_ADDR), a
    ;ld  a, $0F
    ;out (AY_DATA), a
    ret

; Routine to update sound as necessary
; called 60 times per second by interrupt handler (when bit 1 of isubstate
; is set)
sound_step:
    push af
    push hl
    ld  a, (ch_a_on)
    cp  0
    call nz, ch_a_step
    ld  a, (ch_b_on)
    cp  0
    call nz, ch_b_step
    ld  hl, (ch_c_routine)
    ld  a, h
    cp  0
    call nz, redirect_to_hl
    pop hl
    pop af
    ret

; fake indirect call since you can't call to a pointer in z80 asm
redirect_to_hl:
    jp  (hl)

; Routine for channel A
ch_a_step:
PROC
LOCAL   cont, enable, play_tone
    ld  hl, ch_a_ctr
    dec (hl)            ; decrement counter
    ret nz              ; return if no changes to be made yet
    push bc
    ld  hl, (ch_a_at)
    inc hl
    inc hl
    push hl             ; save updated location (ch_a_at+2)
    ld  bc, (ch_a_start)
    or  a               ; clear carry flag
    sbc hl, bc
    ld  bc, (ch_a_len)
    sbc hl, bc          ; hl-bc (ch_a_at+2-ch_a_len = 0)?
    pop hl              ; restore hl to ch_a_at+2
    jr  nz, cont        ; proceed if ch_a_at+2-ch_a_len != 0
    ld  hl, (ch_a_start)  ; we reached the end of the music data, start over
cont:
    ld  a, 7
    out (AY_ADDR), a     ; select register enable or disable channel
    ld  (ch_a_at), hl
    ld  a, (hl)          ; note to play
    cp  0
    jr  nz, enable
    in  a, (AY_DATA)    ; disable channel
    or  %00001001
    out (AY_DATA), a
    jr  play_tone
enable:
    in  a, (AY_DATA)    ; enable channel
    and %11111110
    out (AY_DATA), a
play_tone:
    call get_tone
    ld  a, 0
    out (AY_ADDR), a
    ld  a, c
    out (AY_DATA), a
    ld  a, 1
    out (AY_ADDR), a
    ld  a, b
    out (AY_DATA), a
    inc hl
    ld a, (hl)          ; counter (how long to play the note)
    ld (ch_a_ctr), a
    pop bc
    ret
ENDP

; Routine for channel B
ch_b_step:
PROC
    ld  hl, ch_b_ctr
    dec (hl)            ; decrement counter
    ret nz              ; return if no changes to be made yet
    push bc
    ld  hl, (ch_b_at)
    inc hl
    inc hl
    push hl             ; save updated location (ch_b_at+2)
    ld  bc, (ch_b_start)
    or  a               ; clear carry flag
    sbc hl, bc
    ld  bc, (ch_b_len)
    sbc hl, bc
    pop hl              ; restore hl to ch_b_at+2
    jr  nz, cont
    ld  hl, (ch_b_start)  ; we reached the end of the music data, start over
cont:
    ld  a, 7
    out (AY_ADDR), a     ; select register enable or disable channel
    ld  (ch_b_at), hl
    ld  a, (hl)          ; note to play
    cp  0
    jr  nz, enable
    in  a, (AY_DATA)    ; disable channel
    or  %00010010
    out (AY_DATA), a
    jr  play_tone
enable:
    in  a, (AY_DATA)    ; enable channel
    and %11111101
    out (AY_DATA), a
play_tone:
    call get_tone
    ld  a, 2
    out (AY_ADDR), a
    ld  a, c
    out (AY_DATA), a
    ld  a, 3
    out (AY_ADDR), a
    ld  a, b
    out (AY_DATA), a
    inc hl
    ld a, (hl)          ; counter (how long to play the note)
    ld (ch_b_ctr), a
    pop bc
    ret
ENDP

; Pointer to routine to call for channel C
ch_c_routine:   dw  $0000

ch_a_on:    db  $00     ; whether music is currently playing on Channel A
ch_a_len:   dw  $0000   ; length of music data for channel A
ch_a_start: dw  $0000   ; pointer to beginning of music data for A
ch_a_at:    dw  $0000   ; pointer to current part of music data for A
ch_a_ctr    db  $00     ; counter for channel a
ch_b_on:    db  $00     ; whether music is currently playing on Channel B
ch_b_len:   dw  $0000   ; length of music data for channel B
ch_b_start: dw  $0000   ; pointer to beginning of music data for B
ch_b_at:    dw  $0000   ; pointer to current part of music data for B
ch_b_ctr:   db  $00

; Tone tables
; period = 110297/f
; do notes from E2 to G5
get_tone:
    push hl
    add a, a
    ld  hl, tone_table
    ld  c, a
    ld  b, 0
    add hl, bc
    ld  c, (hl)
    inc hl
    ld  b, (hl)
    pop hl
    ret

; 8-bit fine tune (registers 0, 2, 4)
tone_table:
    db  $00     ; 0 = rest (don't play sound)
    db  $00     ; 0 = rest (don't play sound)
    db  $3A     ; 1 = E2 (82.41 Hz)
    db  $05     ; 1 = E2 (82.41 Hz)
    db  $EF     ; 2 = F2 (87.31 Hz)
    db  $04     ; 2 = F2 (87.31 Hz)
    db  $A8     ; 3 = F#2 (92.50 Hz)
    db  $04     ; 3 = F#2 (92.50 Hz)
    db  $65     ; 4 = G2 (98.00 Hz)
    db  $04     ; 4 = G2 (98.00 Hz)
    db  $26     ; 5 = G#2 (103.83 Hz)
    db  $04     ; 5 = G#2 (103.83 Hz)
    db  $EA     ; 6 = A2 (110.00 Hz)
    db  $03     ; 6 = A2 (110.00 Hz)
    db  $B2     ; 7 = A#2 (116.54 Hz)
    db  $03     ; 7 = A#2 (116.54 Hz)
    db  $7D     ; 8 = B2 (123.47 Hz)
    db  $03     ; 8 = B2 (123.47 Hz)
    db  $4B     ; 9 = C3 (130.81 Hz)
    db  $03     ; 9 = C3 (130.81 Hz)
    db  $1B     ; A = C#3 (138.59 Hz)
    db  $03     ; A = C#3 (138.59 Hz)
    db  $EF     ; B = D3 (146.83 Hz)
    db  $02     ; B = D3 (146.83 Hz)
    db  $C5     ; C = D#3 (155.56 Hz)
    db  $02     ; C = D#3 (155.56 Hz)
    db  $9D     ; D = E3 (164.81 Hz)
    db  $02     ; D = E3 (164.81 Hz)
    db  $77     ; E = F3 (174.61 Hz)
    db  $02     ; E = F3 (174.61 Hz)
    db  $54     ; F = F#3 (185.00 Hz)
    db  $02     ; F = F#3 (185.00 Hz)
    db  $32     ; 10 = G3 (196.00 Hz)
    db  $02     ; 10 = G3 (196.00 Hz)
    db  $13     ; 11 = G#3 (207.65 Hz)
    db  $02     ; 11 = G#3 (207.65 Hz)
    db  $F5     ; 12 = A3 (220.00 Hz)
    db  $01     ; 12 = A3 (220.00 Hz)
    db  $D9     ; 13 = A#3 (233.08 Hz)
    db  $01     ; 13 = A#3 (233.08 Hz)
    db  $BE     ; 14 = B3 (246.94 Hz)
    db  $01     ; 14 = B3 (246.94 Hz)
    db  $A5     ; 15 = C4 (261.63 Hz)
    db  $01     ; 15 = C4 (261.63 Hz)
    db  $8D     ; 16 = C#4 (277.18 Hz)
    db  $01     ; 16 = C#4 (277.18 Hz)
    db  $77     ; 17 = D4 (293.66 Hz)
    db  $01     ; 17 = D4 (293.66 Hz)
    db  $62     ; 18 = D#4 (311.13 Hz)
    db  $01     ; 18 = D#4 (311.13 Hz)
    db  $4E     ; 19 = E4 (329.63 Hz)
    db  $01     ; 19 = E4 (329.63 Hz)
    db  $3B     ; 1A = F4 (349.23 Hz)
    db  $01     ; 1A = F4 (349.23 Hz)
    db  $2A     ; 1B = F#4 (369.99 Hz)
    db  $01     ; 1B = F#4 (369.99 Hz)
    db  $19     ; 1C = G4 (392.00 Hz)
    db  $01     ; 1C = G4 (392.00 Hz)
    db  $09     ; 1D = G#4 (415.30 Hz)
    db  $01     ; 1D = G#4 (415.30 Hz)
    db  $FA     ; 1E = A4 (440.00 Hz)
    db  $00     ; 1E = A4 (440.00 Hz)
    db  $EC     ; 1F = A#4 (466.16 Hz)
    db  $00     ; 1F = A#4 (466.16 Hz)
    db  $DF     ; 20 = B4 (493.88 Hz)
    db  $00     ; 20 = B4 (493.88 Hz)
    db  $D2     ; 21 = C5 (523.25 Hz)
    db  $00     ; 21 = C5 (523.25 Hz)
    db  $C6     ; 22 = C#5 (554.37 Hz)
    db  $00     ; 22 = C#5 (554.37 Hz)
    db  $BB     ; 23 = D5 (587.33 Hz)
    db  $00     ; 23 = D5 (587.33 Hz)
    db  $B1     ; 24 = D#5 (622.25 Hz)
    db  $00     ; 24 = D#5 (622.25 Hz)
    db  $A7     ; 25 = E5 (659.25 Hz)
    db  $00     ; 25 = E5 (659.25 Hz)
    db  $9D     ; 26 = F5 (698.46 Hz)
    db  $00     ; 26 = F5 (698.46 Hz)
    db  $95     ; 27 = F#5 (739.99 Hz)
    db  $00     ; 27 = F#5 (739.99 Hz)
    db  $8C     ; 28 = G5 (783.99 Hz)
    db  $00     ; 28 = G5 (783.99 Hz)

; The vector table and interrupt handler were initially placed near the
; end of memory with ORG directives.  This resulted in a 32K .tap file
; even when the early prototypes of the game were only a couple kilobytes.
; So, to avoid inflating the file size, we build the vector table when
; the program starts and copy the interrupt handler to its final location
; in memory
init_isr:
    di
    ; build vector table (call $fefe for any interrupt)
    ld  a, $fe
    ld  ($fd00), a
    ld  hl, $fd00
    ld  de, $fd01
    ld  bc, $0100
    ldir
    ; copy interrupt handler to $fefe
    ld  hl, isr_start
    ld  de, $fefe
    ld  bc, isr_end-isr_start
    ldir
    ; set up interrupt mode 2
    ld  a, $fd  ; interrupt vector table at memory location $FD00
    ld  i, a    ; place in Interrupt Control Vector Register
    im  2       ; set interrupt mode 2
    ei          ; enable interrupts
    ret

; Interrupt vector table
;    ORG $FD00
;    REPT 257
;    db  $FE
;    ENDM

; isubstate - Interrupt Subroutine State
; Byte indicating which routines to call during an interrupt. Routines
; can be turned "on" and "off" by setting and resetting their associated
; bit, respectively.
; Currently bit 1 is for the sound routine. Bit 0 is intended for a
; drawing routine for animation, so that it gets called first during the
; vertical blank period.
isubstate   db  $02

; Interrupt handler
isr_start:
;    ORG $FEFE
    push af
    ld  a, (isubstate)  ; load routine status byte
    ; Check which routines are "on" and call them. These routines are
    ; expected to push and pop for themselves any registers that they
    ; may change. This may not be a good assumption generally, but since
    ; I'm writing these routines myself, I think I can get away with it.
;    bit 0, a
;    call nz, anim_step
    bit 1, a
    call nz, sound_step   
    pop af
    ei
    reti
isr_end:
