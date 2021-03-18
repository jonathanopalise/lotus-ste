YMChannelAVolumeAdjust:
    cmp.b   #2,d0
    bls.s   labelClampChannelAVolume
    subq.b  #2,d0
    bra.s   labelFinishedChannelAVolumeCheck
labelClampChannelAVolume
    moveq   #0,d0
labelFinishedChannelAVolumeCheck
; --- restore instructions that were replaced by jsr
    move.b  d0,(a1)
    move.b  #$9,(a0)
; --------------------------------------------------
    move.b  $7db70,d0				; was PC-relative
    rts

YMChannelBVolumeAdjust:
    cmp.b   #2,d0
    bls.s   labelClampChannelBVolume
    subq.b  #2,d0
    bra.s   labelFinishedChannelBVolumeCheck
labelClampChannelBVolume
    moveq   #0,d0
labelFinishedChannelBVolumeCheck
; --- restore instructions that were replaced by jsr
    move.b  d0,(a1)
    move.b  #$a,(a0)
; --------------------------------------------------
    move.b  $7db92,d0				; was PC-relative
    rts

YMChannelCVolumeAdjust:
    cmp.b   #2,d0
    bls.s   labelClampChannelCVolume
    subq.b  #2,d0
    bra.s   labelFinishedChannelCVolumeCheck
labelClampChannelCVolume
    moveq   #0,d0
labelFinishedChannelCVolumeCheck
; --- restore instructions that were replaced by jsr
    move.b  d0,(a1)
    tst.b   6(a2)
; --------------------------------------------------
    rts
