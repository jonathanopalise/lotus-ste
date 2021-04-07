ym_effect_volume_adjust:
	lsr.w	#8,d0
	lsr.w	#4,d0
	cmp.b	#4,d0
    bls.s   labelClampChannelCEngineVolume
    subq.b  #4,d0
    bra.s	labelFinishedChannelCEngineVolumeCheck
labelClampChannelCEngineVolume
	clr.b	d0
labelFinishedChannelCEngineVolumeCheck:

	or.w	#$a00,d0

	jmp		$70bac
