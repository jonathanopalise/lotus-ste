do_sound_events:
	tst.w	$7ccf0				; check if music is playing	3
	bmi	labelCheckForSoundEvent		; $ffff if music is stopped	1
	jsr	$7098e				; deal with YM stuff		2
labelCheckForSoundEvent
	tst.w	$7097c				; check sound event ID		3
	bmi	labelNoSoundEvent		; $ffff if no sound event	1
	jsr	$709b2				; create DMA sound event	2
labelNoSoundEvent
	rts




; from 71ce6:
;	tst.w	$7ccf0			; test for music (again)	3 words
;	bmi.s	labelCheckEngineType	; if no music, then 		1 word
;	bra.s	$71d66							1 word
;labelCheckEngineType
;	tst.w	$7cd62			; test for 1 or 2 player	3 words
;	beq.s	$71d66			; skip YM engine sound		1 word
