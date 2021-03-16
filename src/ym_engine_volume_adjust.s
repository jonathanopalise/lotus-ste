ym_engine_volume_adjust:
	move.w	d4,d2
	or.w	#$800,d2
	cmp.b	#3,d2
    	blo.s   labelClampChannelAEngineVolume
    	subq.b  #2,d2
    	bra.s	labelFinishedChannelAEngineVolumeCheck
labelClampChannelAEngineVolume
	clr.b	d2
labelFinishedChannelAEngineVolumeCheck:
	movep.w	d2,0(a0)
	move.w	d5,d2
	or.w	#$900,d2
	cmp.b	#3,d2
    	blo.s   labelClampChannelBEngineVolume
    	subq.b  #2,d2
    	bra.s	labelFinishedChannelBEngineVolumeCheck
labelClampChannelBEngineVolume
	clr.b	d2
labelFinishedChannelBEngineVolumeCheck:
	movep.w	d2,0(a0)
	rts
	
	
	
; if d2 is 2,1,or0, then make it zero
; if 3 or above, subtract 2
