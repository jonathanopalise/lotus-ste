	ORG	$71ce6
	
	; disables music check in game which disables sound effects if track is playing
	; can probably incorporate 709b2 here and free that space up
	
	tst.w	$7ccf0				; check if music is playing
	bmi	labelCheckForSoundEvent		; $ffff if music is stopped
	jsr	$7098e				; deal with YM stuff
labelCheckForSoundEvent
	tst.w	$7097c				; check sound event ID
	bmi	labelNoSoundEvent		; $ffff if no sound event
	jsr	$709b2				; create DMA sound event
labelNoSoundEvent
	clr.w	$71ffe				; not sure what this clears
	clr.w	$72000				; but looks like it needs to stay
	rts

; --- there is stuff to add here to enable two player YM engine effects...
