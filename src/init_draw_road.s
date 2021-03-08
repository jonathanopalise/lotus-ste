initdrawroad:
    move.l #$ffff8a20,a5
    move.w d4,$76688
    move.w #8,(a5)+            ; source x increment 8a20
    move.w #-158,(a5)          ; source y increment 8a22
    addq.l #6,a5
    move.w #-1,(a5)+           ; endmask1 8a28
    move.w #-1,(a5)+           ; endmask2 8a2a
    move.w #-1,(a5)+           ; endmask3 8a2c
    move.w #8,(a5)+            ; dest x increment 8a2e
    move.w #-150,(a5)          ; dest y increment 8x30
    addq.l #6,a5
    move.w #20,(a5)           ; xcount 8a36
    addq.l #4,a5
    move.w #$0203,(a5)        ; hop/op 8a3a
    move.l #$ffff8a38,a5      ; ycount
    move.l #$ffff8a24,a3      ; source
    move.l #$ffff8a32,a2      ; destination
    move.l #$ffff8a3c,a6      ; linenum (to start blitter)
    moveq.l #1,d5 ; d5 is now free for use
    lea.l byte_offsets,a0
    move.l a0,usp
    lea.l gfx_data,a0
    move.l a0,d6
    rts


