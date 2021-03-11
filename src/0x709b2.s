
    ORG $709b2

    ; **************************************************************************
    ; * Lotus STE                                                              *
    ; *                                                                        *
    ; * Play PCM sound effect on event                                         *
    ; *                                                                        *
    ; * Further discovery is required to make this mechanism work in both 1    *
    ; * player and 2 player contexts
    ; **************************************************************************

    include generated/symbols_0x80000.inc

    movem.l     d0/a0,-(sp)

    move.w      $7097c,d0                                           ; fetch new sound event ID
    and.w       #7,d0                                               ; mask off garbage bits - ID is now between 1 and 7
    cmp.w       variableP1SoundEventLatch,d0                        ; compare with current sound event ID (either between 1 and 7, or $ffff (no current sound event))
    blo.s       labelCreateNewSoundEvent                            ; if new sound event ID value is lower (i.e. higher priority) then create new sound event

    move.w      variableP1SoundEventPosition,d0                     ; otherwise, check current sound event position
    cmp.w       variableP1SoundEventRetrigPeriod,d0                 ; check position against sound event retrig period
    blo.s       labelFinishedSoundEventCheck                        ; if current sound event position is lower than retrig period then don't retrigger the sound

    move.w      #0,variableP1SoundEventPosition                     ; otherwise, reset sample offset position
    bra.s       labelFinishedSoundEventCheck                        ; job done

labelCreateNewSoundEvent
    move.w      d0,variableP1SoundEventLatch                        ; store sound event ID
    lsl.w       #3,d0                                               ; multiply sound event ID by 8 to get sound event table offset
    lea.l       tableSoundEvents,a0                                 ; sound event table base address
    move.l      (a0,d0),variableP1SoundEventAddress                 ; fetch sound event base address from sound event table
    move.w      4(a0,d0),variableP1SoundEventLength                 ; fetch sound event length from sound event table
    move.w      6(a0,d0),variableP1SoundEventRetrigPeriod           ; fetch sound event retrig period from sound event table
    move.w      #0,variableP1SoundEventPosition                     ; set sound event sample offset position to 0

labelFinishedSoundEventCheck

    movem.l     (sp)+,d0/a0
    rts

