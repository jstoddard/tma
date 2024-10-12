; Ten Minute Adventure
; A short game by Jeremiah Stoddard

; Some definitions
;K_CLS   EQU $08A6   ; clears screen
;CL_ADDR EQU $09D6   ; takes line # in B, returns screen address in HL

ATTRS   EQU $5800   ; display attributes
FIRST   EQU $4000   ; first third of display (lines 0-7)
SECND   EQU $4800   ; second third of display (lines 8-15)
THIRD   EQU $5000   ; third third of display (lines 16-23)

    ORG $8000

start:
    call init_isr       ; set up interrupt handler
    call draw_screen
    ld  bc, (player_y)  ; put player_x in b and player_y in c
    call draw_sprite
    call play_ovr       ; start overworld music
game_loop:
    call check_input
    jr  game_loop

; some variables
player_y:   db  $09
player_x:   db  $05
cur_map:    dw  overworld_sw

; check for player input and take appropriate action
check_input:
PROC
    ; Check joystick - register 14 of the sound chip, selected by
    ; writing $0E to port $F5
    ; IN at $F6 - address bits 8 and 9 select player 1/2
    ld  a, $0e      ; 14
    di              ; don't want selected register to be changed by sound
                    ; routines between the out and in
    out ($f5), a    ; select register 14 of the sound chip
    ld  b, 1        ; put player 1 on the address bus
    ld  c, $f6
    in  a, (c)
    ei
    ; joystick data in A, with 0 for active
    ; bit 0 - up, bit 1 - down, bit 2 - left, bit 3 - right, bit 7 - button
    bit 0, a
    jp  z, move_n
    bit 1, a
    jp  z, move_s
    bit 2, a
    jp  z, move_w
    bit 3, a
    jp  z, move_e
    ; If we made it here, we don't have any player input from the
    ; joystick right now, so let's check the keyboard
    ; check for 'q' pressed
    ld  a, $fb
    in  a, ($fe)
    bit 0, a
    jp  z, move_n ; if key pressed, jump to move routine
    ; check for 'a' pressed
    ld  a, $fd
    in  a, ($fe)
    bit 0, a
    jp  z, move_s ; if key pressed, jump to move routine
    ; check for 'p' pressed
    ld  a, $df
    in  a, ($fe)
    bit 0, a
    jp  z, move_e
    ; check for 'o' pressed
    bit 1, a    ; same half-row as o, so no need for another in
    jp  z, move_w
    ; if we made it here, no player input, so return
    ret
ENDP

; player wants to move upward (either Q pressed or joystick in up position)
move_n:
    ld  hl, player_n
    ld  (cur_sprite), hl
    ld  hl, player_n_mask
    ld  (cur_mask), hl
    ld  bc, (player_y)
    push hl
    push bc
    call draw_sprite
    pop bc
    pop hl
    dec c               ; y = y - 1
    call check_barrier
    jp  nc, bump
    inc c               ; put y back in order to erase sprite from old pos
    call clear_sprite
    ld  bc, (player_y)  ; get player position again
    dec c               ; y = y - 1 again
    call draw_sprite    ; draw sprite at new position
    ld  hl, player_y
    dec (hl)            ; and save new player location
    call delay
    ret

; player wants to move downward (A or joystick down)
move_s:
    ld  hl, player_s
    ld  (cur_sprite), hl
    ld  hl, player_s_mask
    ld  (cur_mask), hl
    ld  bc, (player_y)
    push hl
    push bc
    call draw_sprite
    pop bc
    pop hl
    inc c               ; y = y + 1
    call check_barrier
    jp  nc, bump
    dec c               ; put y back in order to erase sprite from old pos
    call clear_sprite
    ld  bc, (player_y)  ; get player position again
    inc c               ; y = y + 1 again
    call draw_sprite    ; draw sprite at new position
    ld  hl, player_y
    inc (hl)            ; and save new player location
    call delay
    ret

; player wants to move to the right (P or joystick right)
move_e:
    ld  hl, player_e
    ld  (cur_sprite), hl
    ld  hl, player_e_mask
    ld  (cur_mask), hl
    ld  bc, (player_y)
    push hl
    push bc
    call draw_sprite
    pop bc
    pop hl
    inc b               ; x = x + 1
    call check_barrier
    jp  nc, bump
    dec b               ; put x back in order to erase sprite from old pos
    call clear_sprite
    ld  bc, (player_y)  ; get player position again
    inc b               ; x = x + 1 again
    call draw_sprite    ; draw sprite at new position
    ld  hl, player_x
    inc (hl)            ; and save new player location
    call delay
    ret

; player wants to move to the left (O or joystick left)
move_w:
    ld  hl, player_w
    ld  (cur_sprite), hl
    ld  hl, player_w_mask
    ld  (cur_mask), hl
    ld  bc, (player_y)
    push hl
    push bc
    call draw_sprite
    pop bc
    pop hl
    dec b               ; x = x - 1
    call check_barrier
    jp  nc, bump
    inc b               ; put x back in order to erase sprite from old pos
    call clear_sprite
    ld  bc, (player_y)  ; get player position again
    dec b               ; x = x - 1 again
    call draw_sprite    ; draw sprite at new position
    ld  hl, player_x
    dec (hl)            ; and save new player location
    call delay
    ret

; is tile at bc a barrier?
check_barrier:
    ld  hl, overworld_sw
    call gettileno
    ld  a, e
    cp BARRIERS
    ret

; player walked into barrier, so play a sound
bump:
PROC
LOCAL   loop1, loop2
    ; We'll write to the sound chip directly instead of setting up a
    ; routine to use with the driver since we're just playing a simple
    ; tone. But first, turn of any sound effect currently playing.
    ld  a, 0
    ; Start with high order byte, because as soon as it's 0, the
    ; sound driver will stop calling the routine. We don't want half
    ; an address to be called if an interrupt occurs between the two
    ; ld statements.
    ld  (ch_c_routine+1), a
    ld  (ch_c_routine), a
    ; set tone for channel c
    ld  a, 4            ; 8 bit fine tune register for channel C
    out (AY_ADDR), a    ; select register
    ld  a, $3A
    out (AY_DATA), a
    ld  a, 5            ; 8 bit coarse tune register for channel C
    out (AY_ADDR), a
    out (AY_DATA), a
    ld  a, 7            ; enable register
    out (AY_ADDR), a
    in  a, (AY_DATA)    ; get states of channels
    and %11111011       ; tone bit for channel c = 0 (on)
    out  (AY_DATA), a
    ld  a, 10
    out (AY_ADDR), a    ; channel C amplitude
    ld  a, $0F
    out (AY_DATA), a
    ld  b, 6            ; wait about a tenth of a second
loop1:
    halt
    djnz loop1
    ; stop sound (set channel amplitude to 0)
    ld  a, 0
    out (AY_DATA), a
    ld  b, 6        ; wait another tenth of a second
loop2:
    halt
    djnz loop2
    ret
ENDP

; wait a little bit
delay:
PROC
LOCAL loop
    push bc
    ld  b, 15
loop:
    halt
    djnz loop
    pop bc
    ret

    INCLUDE sprite.asm
    INCLUDE maps.asm
    INCLUDE graphics.asm
    INCLUDE tileset.asm
    INCLUDE sound.asm
    INCLUDE music.asm

    END start
