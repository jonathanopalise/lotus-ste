do_sound_events:
	tst.w	$7ccf0				; check if music is playing	3
	bmi.s	labelCheckForSoundEvent		; $ffff if music is stopped	1
	jsr	$7098e				; deal with YM stuff		2
labelCheckForSoundEvent
	tst.w	$7097c				; check sound event ID		3
	bmi.s	labelNoSoundEvent		; $ffff if no sound event	1
	jsr	$709b2				; create DMA sound event	2
labelNoSoundEvent
	rts
