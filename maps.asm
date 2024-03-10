; Maps for Ten Minute Adventure
; by Jeremiah Stoddard

; get tile number for position b,c of map in hl
; returns tile number in e (ready for plottile)
gettileno:
    push bc     ; save position
    ld  a, c
    add a, a    ; multiply y-position by 16
    add a, a
    add a, a
    add a, a
    add a, b    ; a has offset from tilemap
    ld  b, 0
    ld  c, a
    add hl, bc  ; hl now points to actual tile #
    ld  e, (hl)
    pop bc      ; restore position
    ret

; 16x12 map of tiles for screen
overworld_sw:
    db 4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4
    db 4,4,4,3,3,1,1,1,0,0,0,0,0,0,4,4
    db 4,4,4,3,1,1,1,0,0,0,0,0,0,0,0,4
    db 4,4,3,3,3,1,1,0,0,0,0,0,0,0,0,4
    db 4,3,3,3,1,1,1,1,0,0,0,0,0,0,0,4
    db 4,3,3,3,1,1,1,1,0,0,0,0,0,0,0,4
    db 4,5,5,3,3,1,1,0,0,0,0,0,0,2,2,4
    db 4,5,5,3,0,0,0,0,0,0,0,0,2,2,2,4
    db 4,5,5,5,0,0,0,0,0,2,2,2,2,2,2,4
    db 4,4,5,5,0,0,0,0,2,2,2,2,2,2,2,4
    db 4,4,4,0,0,0,0,2,2,2,2,2,2,2,4,4
    db 4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4
