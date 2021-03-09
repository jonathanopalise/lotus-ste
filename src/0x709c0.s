
    ORG $709c0

    ; **************************************************************************
    ; * Lotus STE                                                              *
    ; *                                                                        *
    ; * Play PCM sound effect on event                                         *
    ; *                                                                        *
    ; * Further discovery is required to make this mechanism work in both 1    *
    ; * player and 2 player contexts
    ; **************************************************************************

    include generated/symbols_0x80000.inc

    move.w $7097c,d0

    cmp.w variableP1SoundEventLatch,d0
    beq.s noplay

    move.w      d0,variableP1SoundEventLatch
    move.w      #0,variableP1SoundEventPosition

noplay:

    movem.l (sp)+,d0-d7/a0-a6
    rts


