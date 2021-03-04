
    ORG $709c0

    ; try playing a pcm sample when a sound effect is requested

    include generated/symbols_0x80000.inc

    lea sample_lookup,a0
    moveq.l #0,d0
    move.w $7097c,d0
    asl.w #3,d0
    add.l d0,a0
    move.l (a0)+,sample2
    move.b (a0),sample2_size
    move.b (a0),sample2_len
    move.b #0,sample2_loop
    move.b #255,sample2_playing

    movem.l (sp)+,d0-d7/a0-a6
    rts


