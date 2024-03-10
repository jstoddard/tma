; Tileset for Ten Minute Adventure
; by Jeremiah Stoddard
BARRIERS    equ 3   ; tiles at or above this number cannot be walked on

; Tileset - 32-byte 16x16 bitmaps
tileset:
; tile 0 - grass
    db $20,$20,$04,$04,$80,$80,$08,$08
    db $20,$20,$02,$02,$48,$48,$00,$00
    db $20,$20,$04,$04,$80,$80,$08,$08
    db $20,$20,$02,$02,$48,$48,$00,$00
; tile 1 - tall grass
    db $04,$28,$04,$48,$84,$40,$94,$22
    db $94,$84,$94,$82,$91,$12,$A1,$52
    db $09,$54,$49,$50,$48,$09,$48,$81
    db $48,$89,$29,$29,$28,$AA,$01,$28
; tile 2 - desert (same as grass, but yellow)
    db $20,$20,$04,$04,$80,$80,$08,$08
    db $20,$20,$02,$02,$48,$48,$00,$00
    db $20,$20,$04,$04,$80,$80,$08,$08
    db $20,$20,$02,$02,$48,$48,$00,$00
; tile 3 - tree
    db $18,$18,$24,$24,$42,$42,$81,$81
    db $81,$81,$81,$81,$81,$81,$7E,$7E
    db $18,$18,$18,$18,$18,$18,$18,$18
    db $18,$18,$18,$18,$3C,$3C,$7E,$7E
; tile 4 - mountain
    db $FF,$FF,$F7,$FF,$F3,$FF,$F1,$DF
    db $F1,$8F,$F1,$07,$EA,$17,$E0,$47
    db $E8,$2F,$E5,$43,$CA,$AB,$D5,$43
    db $CA,$AB,$D5,$45,$83,$C1,$FF,$FF
; tile 5 - water
    db $88,$88,$77,$77,$88,$88,$77,$77
    db $88,$88,$77,$77,$88,$88,$77,$77
    db $88,$88,$77,$77,$88,$88,$77,$77
    db $88,$88,$77,$77,$88,$88,$77,$77

; Tile attributes - 1 byte for each tile
; Sprites will be drawn over tiles in the foreground color and outlined
; in the background color. To make this work as well as possible, I
; have given tiles that can be walked on a foreground (ink) color of
; black.
tileatt:
    db %00100000    ; tile 0 - grass is black on green
    db %00100000
    db %00100000
    db %00100000
    db %00100000    ; tile 1 - tall grass is black on green
    db %00100000
    db %00100000
    db %00100000
    db %00110000    ; tile 2 - desert is black on yellow
    db %00110000
    db %00110000
    db %00110000
    db %00100000    ; tile 3 - treetop black outline on green
    db %00100000
    db %00100110    ; tile 3 - trunk yellow on green
    db %00100110
    db %00111000    ; tile 4 - mountain is black on white
    db %00111000
    db %00111000
    db %00111000
    db %10001101    ; tile 5 - water is cyan on blue (flashing)
    db %10001101
    db %10001101
    db %10001101
