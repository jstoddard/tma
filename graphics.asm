; Graphics routines for Ten Minute Adventure
; by Jeremiah Stoddard

draw_screen:
PROC
LOCAL loop
    ld hl, (cur_map)
loop:
    ld e, (hl)
    inc hl
    push hl
    push bc
    call plottile
    pop bc
    pop hl
    inc b
    ld  a, b
    cp  16
    jr  nz, loop
    ld  b, 0
    inc c
    ld  a, c
    cp  12
    jr  nz, loop
    ret
    ENDP

; plot a 16x16 tile -- tile no in e, x-pos (0-15) in b, y-pos (0-11) in c
plottile:
    PROC
    LOCAL quad_de, parse_bc, finishrow, addcol, mult_loop, iter
    ; set attributes
    push bc             ; save x,y b/c we're about to mutilate bc
    ld d, 0
    sla e               ; de = de*4 (four bytes per tile)
    jr  nc, quad_de
    inc d
quad_de:
    sla d
    sla e
    jr  nc, parse_bc
    inc d
parse_bc:
    ld  a, b        ; save b*2 for now
    sla a
    ld  b, 0
    sla c           ; set bc to row*2*32 + col
    sla c
    sla c
    sla c
    sla c
    jr  nc, finishrow   ; here we might overflow
    inc b               ; inc b if so
finishrow:
    sla b
    sla c
    jr  nc, addcol      ; might overflow again
    inc b
addcol:
    ld  h, 0
    ld  l, a        ; hl contains col #
    add hl, bc      ; add col to row address
    ld  b, h        ; put back in bc so we can add to ix
    ld  c, l
    ld  ix, ATTRS   ; attribute file
    add ix, bc      ; add row/col offset
    ld  hl, tileatt ; tile attributes
    add hl, de      ; add 4*(tile no) (4 bytes per tile)
    ld  a, (hl)
    ld  (ix+0), a
    inc hl
    ld  a, (hl)
    ld  (ix+1), a
    inc hl
    ld  a, (hl)
    ld  (ix+32), a
    inc hl
    ld  a, (hl)
    ld  (ix+33), a

    ; we've set the attributes, now let's draw the tiles
    ld b, 3
    ; we multiplied de by four above, but tile pixel data is 32 bytes long,
    ; so we need to shift de three more times
    ; i.e. de = de*32 = de*4*8
mult_loop:
    sla d
    sla e
    jr nc, iter
    inc d
iter:
    djnz mult_loop

    ld  ix, tileset ; finish setting our pointers
    add ix, de
    pop bc
    ENDP    ; head onto plot16 to plot the actual bitmap

; plot 16x16 bitmap from ix at position (x,y) in b,c
plot16:
    PROC
    LOCAL secnd3rd, first3rd, row_to_addr, plotloop
    ; this is the tricky one -- calculate the screen address
    ; bc (when popped from stack) is has x, y for 16x16 tiles
    ; y < 4 = first 3rd of screen, < 8 second 3rd, >= 8 third 3rd
    ld  a, c
    cp  $04
    jr  c, first3rd    ; if under 4, we're on the first third of the screen
    cp  $08
    jr  c, secnd3rd    ; if under 8, we're on the second third
    ld  hl, THIRD       ; set hl to last third of display
    sub $08             ; A is now row # (for 8-pixel rows) btwn 0 and 3
    jr  row_to_addr
secnd3rd:
    ld  hl, SECND
    sub $04
    jr row_to_addr
first3rd:
    ld  hl, FIRST
row_to_addr:
    sla a   ; multiply a by 64 to get address offset for row
    sla a   ; should have been 0-3 when started shifting, so no worry about
    sla a   ; overflow
    sla a
    sla a
    sla a
    sla b   ; double b to get column
    add a, b
    ld  l, a    ; hl should now contain address to start plotting

    ; start plotting
    ld  b, 8
    push hl
    call plotloop   ; plot first 8 rows
    pop hl
    set 5, l        ; next line
    ld  b, 8
plotloop:
    ld  a, (ix+0)
    ld  (hl), a
    inc hl
    ld  a, (ix+1)
    ld  (hl), a
    dec hl
    inc h
    inc ix
    inc ix
    djnz plotloop
    ret
    ENDP