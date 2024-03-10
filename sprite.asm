; Sprite data and routines for Ten Minute Adventure
; by Jeremiah Stoddard

; draw a sprite at a single square, position b,c
; cur_sprite needs to point to sprite, and cur_mask to its mask
draw_sprite:
    PROC
    LOCAL mask_loop, sprite_loop
    push bc     ; save position so we know where to write back to
    ld  a, c
    add a, a    ; multiply y-position by 16
    add a, a
    add a, a
    add a, a
    add a, b    ; a has offset from tilemap
    ld  b, 0
    ld  c, a
    ld  hl, (cur_map)
    add hl, bc  ; hl now points to actual tile #
    ld  a, (hl)
    ld  de, square1
    call load_tile  ; pull tile no. (now in c) into square1
    ; now we have a copy of the tile in square1, let's draw the sprite
    ; onto it
    ld  hl, (cur_mask)      ; start with mask
    ld  de, square1
    ld  b, 32
mask_loop:
    ld  a, (de)
    and (hl)                ; and mask onto tile
    ld  (de), a
    inc hl
    inc de
    djnz mask_loop
    ; mask applied, we load the sprite itself
    ld  hl, (cur_sprite)
    ld  de, square1
    ld  b, 32
sprite_loop:
    ld  a, (de)
    or  (hl)                ; or sprite onto tile
    ld  (de), a
    inc hl
    inc de
    djnz sprite_loop
    ; Now square1 has the tile with the sprite drawn onto it, so let's
    ; put it on the screen
    pop bc
    ld  ix, square1
    call plot16
    ret
    ENDP

; redraw tile at position b,c, clearing any sprite that may be present
clear_sprite:
    ld  hl, (cur_map)
    call gettileno
    call plottile
    ret
    ENDP

; load a tile (tile no. in a) into (de)
load_tile:
PROC
LOCAL addloop
    ld  hl, tileset
    push de
    ld  d, 0
    ld  e, a
    ld  b, 32
addloop:            ; add 32*tileno to hl to get address of tile graphic
    add hl, de
    djnz addloop
    pop de
    ld  c, 32
    ldir
    ret
    ENDP

; Working space to draw sprite over tile(s) before copying to screen
square1:    ds  32
square2:    ds  32

cur_sprite: dw  player_s
cur_mask:   dw  player_s_mask

; player facing south
player_s:
    db  $00,$00,$23,$C0,$27,$E0,$27,$E0
    db  $23,$C0,$21,$80,$27,$00,$7D,$7C
    db  $01,$44,$01,$6C,$01,$B8,$01,$B8
    db  $02,$50,$02,$40,$0E,$70,$00,$00

player_s_mask:
    db  $D3,$C0,$88,$0F,$80,$0F,$80,$0F
    db  $88,$1F,$88,$3F,$80,$01,$00,$01
    db  $80,$01,$FC,$01,$FC,$03,$FC,$03
    db  $F8,$07,$F0,$0F,$E0,$07,$F1,$8F

player_n:
    db  $00,$00,$03,$C4,$07,$E4,$07,$E4
    db  $03,$C4,$01,$84,$07,$E4,$3F,$BE
    db  $3F,$80,$3F,$80,$1D,$80,$1D,$80
    db  $0A,$40,$02,$40,$0E,$70,$00,$00

player_n_mask:
    db  $FC,$3B,$F8,$11,$F0,$01,$F0,$01
    db  $F8,$11,$FC,$11,$C0,$01,$80,$00
    db  $80,$41,$80,$3F,$C0,$3F,$C0,$3F
    db  $E0,$1F,$F0,$0F,$E0,$07,$F1,$8F

player_e:
    db  $00,$00,$01,$90,$03,$D0,$03,$D0
    db  $01,$90,$01,$90,$01,$D0,$01,$F8
    db  $01,$88,$01,$88,$01,$88,$02,$48
    db  $02,$28,$04,$20,$07,$38,$00,$00
player_e_mask:
    db  $FE,$6F,$FC,$07,$F8,$07,$F8,$07
    db  $FC,$07,$FC,$07,$FC,$07,$FC,$03
    db  $FC,$03,$FC,$23,$FC,$24,$F8,$03
    db  $F8,$83,$F0,$87,$F0,$03,$F8,$C7

player_w:
    db  $00,$00,$09,$80,$0B,$C0,$0B,$C0
    db  $09,$80,$09,$80,$0B,$80,$1F,$80
    db  $11,$80,$11,$80,$11,$80,$12,$40
    db  $14,$40,$04,$20,$1C,$E0,$00,$00
player_w_mask:
    db  $F6,$7F,$E0,$3F,$E0,$1F,$E0,$1F
    db  $E0,$3F,$E0,$3F,$C0,$3F,$C0,$3F
    db  $C0,$3F,$C4,$3F,$C4,$3F,$C0,$1F
    db  $C1,$1F,$E1,$0F,$C0,$0F,$E3,$1F
