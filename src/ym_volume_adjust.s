YMChannelAVolumeAdjust:
    tst.b   d0
    beq.s   labelFinishedChannelAVolumeCheck
    subq.b  #1,d0
labelFinishedChannelAVolumeCheck:
; --- restore instructions that were replaced by jsr
    move.b  d0,(a1)
    move.b  #$9,(a0)
; --------------------------------------------------
    move.b  $7db70,d0				; was PC-relative
    rts

YMChannelBVolumeAdjust:
    tst.b d0
    beq.s labelFinishedChannelBVolumeCheck
    subq.b #1,d0
labelFinishedChannelBVolumeCheck:
; --- restore instructions that were replaced by jsr
    move.b  d0,(a1)
    move.b  #$a,(a0)
; --------------------------------------------------
    move.b  $7db92,d0				; was PC-relative
    rts

YMChannelCVolumeAdjust:
    tst.b d0
    beq.s labelFinishedChannelCVolumeCheck
    subq.b #1,d0
labelFinishedChannelCVolumeCheck:
; --- restore instructions that were replaced by jsr
    move.b  d0,(a1)
    tst.b   6(a2)
; --------------------------------------------------
    rts
