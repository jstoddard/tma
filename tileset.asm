; Tileset for Ten Minute Adventure
; by Jeremiah Stoddard
BARRIERS    equ $06   ; tiles at or above this number cannot be walked on
PORTALS     equ $12   ; tiles at or above this number move player to new map on collision

; Tileset - 32-byte 16x16 bitmaps
tileset:
; tile $00 - grass
    db $20,$20,$04,$04,$80,$80,$08,$08
    db $20,$20,$02,$02,$48,$48,$00,$00
    db $20,$20,$04,$04,$80,$80,$08,$08
    db $20,$20,$02,$02,$48,$48,$00,$00
; tile $01 - tall grass
    db $04,$28,$04,$48,$84,$40,$94,$22
    db $94,$84,$94,$82,$91,$12,$A1,$52
    db $09,$54,$49,$50,$48,$09,$48,$81
    db $48,$89,$29,$29,$28,$AA,$01,$28
; tile $02 - desert (same as grass, but yellow)
    db $20,$20,$04,$04,$80,$80,$08,$08
    db $20,$20,$02,$02,$48,$48,$00,$00
    db $20,$20,$04,$04,$80,$80,$08,$08
    db $20,$20,$02,$02,$48,$48,$00,$00
; tile $03 - town floor
    db $00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00
; tile $04 - red carpet
    db $00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00
; tile $05 - dungeon floor
    db $FF,$FF,$FF,$FB,$FF,$F5,$E7,$FF
    db $DB,$FF,$FF,$FF,$FF,$FF,$FF,$E7
    db $FF,$DB,$F7,$FF,$EB,$FF,$FF,$FF
    db $FF,$FF,$FF,$FF,$7F,$FE,$BF,$FD
; tile $06 - town wall
    db $01,$01,$01,$01,$01,$01,$FF,$FF
    db $10,$10,$10,$10,$10,$10,$FF,$FF
    db $01,$01,$01,$01,$01,$01,$FF,$FF
    db $10,$10,$10,$10,$10,$10,$FF,$FF
; tile $07 - counter
    db $00,$00,$7F,$FE,$40,$02,$40,$02
    db $40,$02,$40,$02,$40,$02,$40,$02
    db $40,$02,$40,$02,$40,$02,$40,$02
    db $40,$02,$40,$02,$7F,$FE,$00,$00
; tile $08 - shop sign
    db $00,$07,$00,$09,$3F,$F1,$20,$22
    db $20,$44,$20,$8C,$21,$14,$22,$24
    db $54,$44,$88,$84,$41,$04,$22,$08
    db $41,$10,$88,$E0,$55,$80,$22,$00
; tile $09 - inn sign
    db $00,$00,$00,$20,$08,$10,$00,$18
    db $40,$18,$00,$10,$00,$20,$00,$00
    db $00,$00,$00,$00,$80,$1D,$80,$3F
    db $80,$1D,$FF,$FF,$80,$01,$80,$01
; tile $0A - fountain
    db $0C,$30,$06,$60,$23,$C4,$01,$80
    db $43,$C2,$0D,$B0,$31,$8C,$41,$82
    db $83,$C1,$83,$C1,$C1,$83,$F0,$0F
    db $7C,$3E,$7F,$FE,$7F,$FE,$3F,$FC
; tile $0B - dungeon wall
    db $BC,$FB,$C3,$7B,$DF,$75,$DE,$8D
    db $EE,$FD,$CF,$7D,$B7,$73,$78,$AD
    db $FB,$DE,$3D,$DE,$D0,$8D,$EF,$75
    db $EF,$75,$EC,$FB,$DB,$7B,$1B,$04
; tile $0C - lava
    db $88,$88,$77,$77,$88,$88,$77,$77
    db $88,$88,$77,$77,$88,$88,$77,$77
    db $88,$88,$77,$77,$88,$88,$77,$77
    db $88,$88,$77,$77,$88,$88,$77,$77
; tile $0D - skull
    db $FF,$FF,$F8,$1F,$F0,$07,$E0,$03
    db $C0,$00,$87,$00,$D6,$23,$A0,$40
    db $90,$20,$86,$03,$C7,$00,$C0,$00
    db $E0,$03,$F0,$08,$F8,$1F,$FF,$FF
; tile $0E - bones
    db $FE,$FF,$F0,$7F,$EE,$FE,$D7,$FE
    db $D5,$F1,$D5,$8F,$D5,$AF,$00,$2F
    db $D5,$AF,$D5,$8F,$D5,$F1,$D7,$FE
    db $EE,$FE,$F0,$7F,$FE,$FF,$FF,$FF
; tile $0F - tree
    db $18,$18,$24,$24,$42,$42,$81,$81
    db $81,$81,$81,$81,$81,$81,$7E,$7E
    db $18,$18,$18,$18,$18,$18,$18,$18
    db $18,$18,$18,$18,$3C,$3C,$7E,$7E
; tile $10 - mountain
    db $FF,$FF,$F7,$FF,$F3,$FF,$F1,$DF
    db $F1,$8F,$F1,$07,$EA,$17,$E0,$47
    db $E8,$2F,$E5,$43,$CA,$AB,$D5,$43
    db $CA,$AB,$D5,$45,$83,$C1,$FF,$FF
; tile $11 - water
    db $88,$88,$77,$77,$88,$88,$77,$77
    db $88,$88,$77,$77,$88,$88,$77,$77
    db $88,$88,$77,$77,$88,$88,$77,$77
    db $88,$88,$77,$77,$88,$88,$77,$77
; tile $12 - castle
    db $EF,$F7,$E7,$F3,$EF,$F7,$EF,$F7
    db $C7,$E3,$83,$C1,$00,$00,$00,$00
    db $10,$08,$10,$08,$11,$88,$13,$C8
    db $07,$E0,$07,$E0,$07,$E0,$07,$E0
; tile $13 - town
    db $FC,$3F,$F8,$1F,$F3,$0F,$F3,$0F
    db $F0,$1B,$FF,$B1,$C0,$E0,$80,$60
    db $00,$24,$06,$20,$06,$24,$00,$20
    db $30,$20,$30,$24,$30,$24,$30,$24
; tile $14 - cave
    db $FF,$FF,$FA,$9F,$E1,$87,$D0,$8B
    db $CB,$D3,$87,$E1,$EF,$F1,$9F,$FF
    db $8F,$F1,$CF,$F1,$AF,$FB,$DF,$F5
    db $8F,$FB,$8F,$F1,$DF,$F1,$AF,$FB
; tile $15 - stairs up
    db $F8,$00,$88,$00,$8F,$80,$88,$80
    db $88,$F8,$88,$88,$88,$8F,$F8,$88
    db $F8,$88,$FF,$88,$FF,$88,$FF,$F8
    db $FF,$F8,$FF,$FF,$FF,$FF,$FF,$FF
; tile $16 - stairs down
    db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    db $FF,$FF,$8F,$FF,$8F,$FF,$88,$FF
    db $88,$FF,$88,$8F,$88,$8F,$88,$88
; tile $17 - blank
    db $00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00

; Tile attributes - 1 byte for each tile
; Sprites will be drawn over tiles in the foreground color and outlined
; in the background color. To make this work as well as possible, I
; have given tiles that can be walked on a foreground (ink) color of
; black.
tileatt:
    db %00100000    ; tile $00 - grass is black on green
    db %00100000
    db %00100000
    db %00100000
    db %00100000    ; tile $01 - tall grass is black on green
    db %00100000
    db %00100000
    db %00100000
    db %00110000    ; tile $02 - desert is black on yellow
    db %00110000
    db %00110000
    db %00110000
    db %01111000    ; tile $03 - town floor is black on white
    db %01111000
    db %01111000
    db %01111000
    db %01010000    ; tile $04 - red carpet is black on red
    db %01010000
    db %01010000
    db %01010000
    db %00010000    ; tile $05 - dungeon floor is black on red
    db %00010000
    db %00010000
    db %00010000
    db %01111000    ; tile $06 - town wall is black on white
    db %01111000
    db %01111000
    db %01111000
    db %01110000    ; tile $07 - counter is black on yellow
    db %01110000
    db %01110000
    db %01110000
    db %00111000    ; tile $08 - shop sign is black on gray
    db %00111000
    db %00111000
    db %00111000
    db %00001110    ; tile $09 - top of inn sign is yellow on blue
    db %00001110
    db %00001000    ; tile $09 - bottom of inn sign is black on blue
    db %00001000
    db %00001111    ; tile $0A - fountain is white on blue
    db %00001111
    db %00001111
    db %00001111
    db %00010000    ; tile $0B - dungeon wall is black on red
    db %00010000
    db %00010000
    db %00010000
    db %10010111    ; tile $0C - lava is white on red (flashing)
    db %10010111
    db %10010111
    db %10010111
    db %00111000    ; tile $0D - skull is black on gray
    db %00111000
    db %00111000
    db %00111000
    db %00111000    ; tile $0E - bones are black on gray
    db %00111000
    db %00111000
    db %00111000
    db %00100000    ; tile $0F - treetop black outline on green
    db %00100000
    db %00100110    ; tile $0F - trunk yellow on green
    db %00100110
    db %00111000    ; tile $10 - mountain is black on gray
    db %00111000
    db %00111000
    db %00111000
    db %10001101    ; tile $11 - water is cyan on blue (flashing)
    db %10001101
    db %10001101
    db %10001101
    db %00111100    ; tile $12 - top of castle is green on gray
    db %00111100
    db %00111000    ; tile $12 - bottom of castle is black on gray
    db %00111000
    db %00111100    ; tile $13 - top of town green on gray
    db %00111100
    db %00111000    ; tile $13 - bottom of town black on gray
    db %00111000
    db %00111000    ; tile $14 - cave is black on gray
    db %00111000
    db %00111000
    db %00111000
    db %00111000    ; tile $15 - stairs up are black on gray
    db %00111000
    db %00111000
    db %00111000
    db %00111000    ; tile $16 - stairs down are black on gray
    db %00111000
    db %00111000
    db %00111000
    db %00000000    ; blank tile is just black
    db %00000000
    db %00000000
    db %00000000
