ym_engine_volume_adjust:
	move.w	d4,d2
	moveq	#4,d4
	or.w	#$800,d2
	cmp.b	d4,d2
    bls.s   labelClampChannelAEngineVolume
    subq.b  #4,d2
    bra.s	labelFinishedChannelAEngineVolumeCheck
labelClampChannelAEngineVolume
	clr.b	d2
labelFinishedChannelAEngineVolumeCheck:
	movep.w	d2,0(a0)
	move.w	d5,d2
	or.w	#$900,d2
	cmp.b	d4,d2
    bls.s   labelClampChannelBEngineVolume
    subq.b  #4,d2
    bra.s	labelFinishedChannelBEngineVolumeCheck
labelClampChannelBEngineVolume
	clr.b	d2
labelFinishedChannelBEngineVolumeCheck:
	movep.w	d2,0(a0)
	jmp		$70be8
