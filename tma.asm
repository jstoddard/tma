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
    call delay
    call check_input
    jr  game_loop

; some variables
player_y:   db  $09
player_x:   db  $05
cur_world_w:    db  2
cur_world_h:    db  2
cur_world_map:  dw  overworld_nw
cur_screen_y:   db  1
cur_screen_x:    db  0
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
    ld  a, (player_y)   ; check if player is already at top of screen
    cp  0
    jp  z, screen_up    ; if yes, change screen instead of moving player
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
    ld  a, (player_y)   ; check if player is already at bottom of screen
    cp  11
    jp  z, screen_down  ; if yes, change screen instead of moving player
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
    ld  a, (player_x)   ; check if player is already at right end of screen
    cp  15
    jp  z, screen_right ; if yes, change screen instead of moving player
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
    inc (hl)            ; and save new player 
    call delay
    ret

; player wants to move to the left (O or joystick left)
move_w:
    ld  a, (player_x)   ; check if player is already at left end of screen
    cp  0
    jp  z, screen_left  ; if yes, change screen instead of moving player
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
    ld  hl, (cur_map)
    call gettileno
    ld  a, e
    cp BARRIERS
    ret

; load and draw map for cur_screen_x, cur_screen_y
load_screen:
PROC
LOCAL mul1, mul2
    ; calculate cur_screen_y*cur_world_w+cur_screen_x
    ld  hl, cur_screen_y
    ld  d, (hl)
    ld  hl, cur_world_w
    ld  b, (hl)
    ld  a, 0
mul1:
    add a, d
    djnz mul1
    ld  hl, cur_screen_x
    ld  d, (hl)
    add a, d
    ; multiply by 192 bytes per map to get offset from cur_world_map
    ; we need 16-bit numbers at this point
    ld  e, a
    ld  d, 0
    ld  hl, 0
    ld  b, 192
mul2:
    add hl, de
    djnz mul2
    ; let cur_map = cur_world_map + calculated value
    ld  bc, (cur_world_map)
    add hl, bc
    ld  (cur_map), hl
    call draw_screen
    ret
ENDP

; player at left edge of screen, going further left
screen_left:
PROC
    ld  hl, cur_screen_x
    dec (hl)
    ; move player to the right of the new screen
    ld  a, 15
    ld  (player_x), a
    call load_screen
    ld  bc, (player_y)  ; put player_x in b and player_y in c
    call draw_sprite
    ret
ENDP

; player at right edge of screen, going further right
screen_right:
PROC
    ld  hl, cur_screen_x
    inc (hl)
    ; move player to the left of the new screen
    ld  a, 0
    ld  (player_x), a
    call load_screen
    ld  bc, (player_y)  ; put player_x in b and player_y in c
    call draw_sprite
    ret
ENDP

; player at top edge of screen, going up
screen_up:
PROC
    ld  hl, cur_screen_y
    dec (hl)
    ; move player to the bottom of the new screen
    ld  a, 11
    ld  (player_y), a
    call load_screen
    ld  bc, (player_y)  ; put player_x in b and player_y in c
    call draw_sprite
    ret
ENDP

; player at bottom edge of screen, going down
screen_down:
PROC
    ld  hl, cur_screen_y
    inc (hl)
    ; move player to the top of the new screen
    ld  a, 0
    ld  (player_y), a
    call load_screen
    ld  bc, (player_y)  ; put player_x in b and player_y in c
    call draw_sprite
    ret
ENDP

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
    di
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
    ei
    ld  b, 6            ; wait about a tenth of a second
loop1:
    halt
    djnz loop1
    ; stop sound (set channel amplitude to 0)
    di
    ld  a, 10
    out (AY_ADDR), a    ; channel C amplitude
    ld  a, 0
    out (AY_DATA), a
    ld  b, 6        ; wait another tenth of a second
    ei
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
    ld  b, 7
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
