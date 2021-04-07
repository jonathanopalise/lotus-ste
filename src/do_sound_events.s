do_sound_events:
	tst.w		hasDmaSound
	beq.s			labelDoSTFMSound

	tst.w		$7ccf0													; check if music is playing
	bmi.s		labelCheckForSoundEvent									; $ffff if music is stopped
	jsr			$7098e													; deal with YM music
labelCheckForSoundEvent
	move.w		$7097c,d0													; check sound event ID
	bmi.s		labelNoSoundEvent										; $ffff if no sound event
    and.w       #7,d0                                              	 	; mask off garbage bits - ID is now between 1 and 7
    cmp.w       variableSoundEventLatch(pc),d0                     		; compare with current sound event ID (either between 1 and 7, or $ffff (no current sound event))
    blo.s       labelCreateNewSoundEvent                            	; if new sound event ID value is lower (i.e. higher priority) then create new sound event
    move.w      variableSoundEventPosition(pc),d1              			; otherwise, check current sound event position
    cmp.w       variableSoundEventRetrigPeriod(pc),d1              		; check position against sound event retrig period
    blo.s       labelFinishedSoundEventCheck                        	; if current sound event position is lower than retrig period then don't retrigger the sound
labelCreateNewSoundEvent
    move.w      d0,variableSoundEventLatch                      		; store sound event ID
    lsl.w       #3,d0                                               	; multiply sound event ID by 8 to get sound event table offset
    lea.l       tableSoundEvents(pc),a0                                	; sound event table base address
    move.l      (a0,d0),variableSoundEventAddress              		  	; fetch sound event base address from sound event table
    move.w      4(a0,d0),variableSoundEventLength              		 	; fetch sound event length from sound event table
    move.w      6(a0,d0),variableSoundEventRetrigPeriod        		  	; fetch sound event retrig period from sound event table
    move.w      #0,variableSoundEventPosition                   		; set sound event sample offset position to 0
labelFinishedSoundEventCheck
    move.w      #$ffff,$7097c					   						; null the sound effect

labelNoSoundEvent

	tst.w		$7ccf0													; test for music (again)
	bpl			label_71d66												; if there is music playing then don't do any other YM stuff
	tst.w		$7cd62													; test for 1 or 2 player
	beq			label_71d66												; if 1 player then skip YM engine sound
	bra.s		label_71d02												; if 2 player then do YM engine sound

; slightly modified version of original 71ce6 routine (which also now contains contents of 709b2) here
labelDoSTFMSound
	tst.w		$7ccf0
	bmi.s		label_71cf6
	jsr			$7098e
	bra			label_71d66
label_71cf6
	move.w		$7097c,d0
	bmi.s		label_71d02
;	jsr			$709b2
	and.w		#$7,d0
	lea.l		$70a34,a0
	asl.w		#4,d0
	adda.w		d0,a0
	move.w		(a0),d0
	cmp.w		$70a24,d0
;	beq.s		label_709d6												; silly!
	bcc.s		label_709e6
label_709d6
	move.w		$70a2e,d0
	cmp.w		$70a26,d0
;	beq.s		label_709e6												; silly!
	bcc.s		label_70a16
label_709e6
;	move.w		(a0)+,$70a24
;	move.w		(a0)+,$70a26
;	move.w		(a0)+,$70a28
;	move.w		(a0)+,$70a2a
;	move.w		(a0)+,$70a2c
;	move.w		(a0)+,$70a2e
;	move.w		(a0)+,$70a30
;	move.w		(a0)+,$70a32
	lea.l		$70a24,a1
	rept		8
	move.w		(a0)+,(a1)+												; efficient!
	endr
label_70a16
	move.w		#$ffff,$7097c
label_71d02
;	tst.w		$71ffe													; inefficient
	move.w		$71ffe,d2
	beq.s		label_71d2c
	move.l		#$f80c0,d0
;	divu		$71ffe,d0												; inefficient
	divu		d2,d0
	swap		d0
	move.w		$72002,d0
	swap		d0
	cmp.w		#$7c,d0
;	bcc.s		label_71d2a												; silly!
	bcc.s		label_71d32
	move.w		#$7c,d0
;label_71d2a
	bra.s		label_71d32
label_71d2c
	move.l		#$3f8,d0
label_71d32
;	tst.w		$72000													; inefficient
	move.w		$72000,d2
	beq.s		label_71d5c
	move.l		#$f80c0,d1
;	divu		$72000,d1												; inefficient
	divu		d2,d1
	swap		d1
	move.w		$72004,d1
	swap		d1
	cmp.w		#$7c,d1
;	bcc.s		label_71d5a												; silly!
	bcc.s		label_71d62
	move.w		#$7c,d1
;label_71d5a
	bra.s		label_71d62
label_71d5c
	move.l		#$3f8,d1
label_71d62
	jsr			$70ab4
label_71d66
	clr.w		$71ffe
	clr.w		$72000
	
	rts
