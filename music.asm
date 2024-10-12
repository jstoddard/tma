; Background music for Ten Minute Adventure
; by Jeremiah Stoddard

; Channel A music for overworld
; Data format: note (see table in sound.asm), length
mus_ovr_a:
    db  $23,$06,$00,$06,$27,$06,$00,$06,$23,$06,$00,$06,$27,$06,$00,$06
    db  $21,$06,$00,$06,$27,$06,$00,$06,$21,$06,$00,$06,$27,$06,$00,$06
mus_ovr_a_end:

play_ovr:
    ld  hl, mus_ovr_a
    ld  (ch_a_start), hl
    ld  (ch_a_at), hl
    ld  hl, mus_ovr_a_end-mus_ovr_a
    ld  (ch_a_len), hl
    ld  hl, ch_a_at         ; decrement ch_a_at so when incremented,
    dec (hl)                ; it will start at ch_a_start
    dec (hl)
    ld  a, $01
    ld  (ch_a_ctr), a       ; make it hit 0 at next interrupt
    call music_on
    ret
