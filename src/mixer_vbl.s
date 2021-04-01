; --- variable + fixed frequency 2-channel mixer. ideally put near the top of the vbl
mixer_vbl:
	movem.l		d0-d3/a0-a2,-(sp)

	move.w		#%10011101000,d0															; start master volume at +0dB

	tst.w		$707c4																		; check game state flag
	beq.s		labelDMAAudioOn																; if zero, then race in progress

	tst.w		$7d33a																		; otherwise, race not in progress, so check screen palette fade counter
	bne.s		labelClearSoundEventLatchFalse												; if not zero, then don't clear sound event latch

	move.w		#2000,$7cc3c																; otherwise, (re)set revs to 2000rpm
	move.w		#$ffff,variableSoundEventLatch												; and set sound event latch to null
	bra.s		labelDMAAudioOff															; and don't mix any dma sound

labelClearSoundEventLatchFalse
	move.w		$7cce6,d1																	; fetch state machine value
	cmp.w		#$29,d1																		; check if on stereo screen
	bne.s		labelDMAAudioOff															; if not, then set master volume to +0dB and don't mix any dma sound

	tst.w		$7cd56																		; otherwise, on stereo, so check if engine sound (0) or music track (1-4) is selected
	beq.s		labelDMAAudioOn																; if track is engine, then mix dma sound

labelDMAAudioOff
	bsr			write_microwire																; set master volume to +0dB
	bra			labelFinishedAudio															; and end

labelDMAAudioOn
	move.w		$7cd56,d1																	; fetch music track value
	add.w		$7cd62,d1																	; add 1/2 player game type flag
	bne.s		labelFinishedVolumeCheck													; if either are not zero, then don't fade sound

	move.w		$72002,d1																	; otherwise, fetch ausevol
	cmp.w		#63,d1																		; is it at full volume? if so then no need to change master volume
	beq.s		labelFinishedVolumeCheck
	lsr.w		#1,d1																		; otherwise, divide volume by 2
	sub.w		#31,d1																		; subtract maximum value
	neg			d1																			; invert the value
	sub.w		d1,d0																		; subtract result from master volume centre position
		
labelFinishedVolumeCheck
	bsr			write_microwire																; and use value in d0 to write master volume data to microwire

	lea.l		$ffff8900.w,a0																; dma audio registers base address

	move.w		$7cce6,d1																	; fetch state machine value
	cmp.w		#$0b,d1
	beq.s		label2PlayerSound															; if race in progress and 'car close-up' was the most recent state, then do 2P sounds

	tst.w		$7cd62																		; test if 1 or 2 player game (0 = 1 player, 1 = 2 player)
	beq.s		label1PlayerSound

label2PlayerSound
	tst.w		variableSoundEventLatch														; check sound event latch
	bmi			labelFinishedAudio															; if null then nothing to do

	tst.w		variableSoundEventPosition													; check sound event position
	bne.s		label2PlayerSoundPosition													; if it's not zero then the sound has already been started

	lea.l		variableSoundEventAddress,a1												; otherwise, fetch sound address

	move.b		1(a1),$03(a0)																; set start address high byte
	move.b		2(a1),$05(a0)																; set start address middle byte
	move.b		3(a1),$07(a0)																; set start address low byte

	moveq		#0,d0
	move.w		variableSoundEventLength,d0
	add.l		d0,variableSoundEventAddress

	move.b		1(a1),$0f(a0)																; set end address high byte
	move.b		2(a1),$11(a0)																; set end address middle byte
	move.b		3(a1),$13(a0)																; set end address low byte
	move.b		#0,$01(a0)																	; stop dma
	move.b		#1,$01(a0)																	; start dma	

label2PlayerSoundPosition
	add.w		#250,variableSoundEventPosition												; store current position of sound event effect
	move.w		variableSoundEventLength,d1													; fetch sound event length
	cmp.w		variableSoundEventPosition,d1												; compare current sound event position with sound event length
	bhi			labelFinishedAudio															; if sound event length is higher than current position then nothing to do
	move.w		#$ffff,variableSoundEventLatch												; set sound event latch to null
	bra			labelFinishedAudio

label1PlayerSound
	lea.l		addressAudioCurrentStart,a1
	move.b		9(a1),$03(a0)																; set start address high byte
	move.b		10(a1),$05(a0)																; set start address middle byte
	move.b		11(a1),$07(a0)																; set start address low byte
	move.b		13(a1),$0f(a0)																; set end address high byte
	move.b		14(a1),$11(a0)																; set end address middle byte
	move.b		15(a1),$13(a0)																; set end address low byte
	move.b		#1,$01(a0)																	; (re)start dma

	move.l		(a1),d0																		; these lines swap the current/working audio buffers
	move.l		4(a1),d1
	move.l		8(a1),d2
	move.l		12(a1),d3
	move.l		d0,8(a1)
	move.l		d1,12(a1)
	move.l		d2,(a1)
	move.l		d3,4(a1)

	move.l		d0,a2																		; copy start address of work buffer for mixing routines

	move.w		variableEngineEffectPosition,d0											; current step into engine effect
	move.l		tableSoundEvents,a0															; first entry in table contains base address of engine sound effect
	lea.l		(a0,d0.w),a0																; offset current engine effect position into engine sound effect base address

	move.w		$7cc3c,d0																	; fetch 'auserevs' (player 1 ingame revs)
	sub.w		#1000,d0																	; subtract 1000rpm
	lsl.w		#2,d0																		; multiply revs by 4 to get scaler table offset
	lea.l		table12517HzScaler,a1														; scaler table base address
	move.l		(a1,d0.w),d1																; fetch value from scaler table offset

	moveq		#0,d0																		; clear it for use as engine offset

	tst.w		variableSoundEventLatch														; is there a sound event?
	bmi			labelMixEngineOnly															; if not then just mix the engine sound

	move.l		variableSoundEventAddress,a1												; current sound event sample base address											
	move.w		variableSoundEventPosition,d2												; offset into sample data
	lea.l		(a1,d2),a1																	; adjust address

	rept		250
	move.b		(a0,d0.w),d2																; fetch sample cycle at engine effect current address + new offset
	swap		d0																			; effectively multiply offset by 65536
	add.l		d1,d0																		; add scaler to offset
	swap		d0																			; effectively divide offset by 65536
	add.b		(a1)+,d2																	; add sound event sample to mix
	move.b		d2,(a2)+																	; put accumulated sample value into dma buffer
	endr

	add.w		#250,variableSoundEventPosition											; store current position of sound event effect
	move.w		variableSoundEventLength,d1												; fetch sound event length
	cmp.w		variableSoundEventPosition,d1												; compare current sound event position with sound event length
	bhi			labelFinishedSoundMixing													; if sound event length is higher than current position then nothing to do
	move.w		#$ffff,variableSoundEventLatch											; set sound event latch to null

	bra			labelFinishedSoundMixing													; finished

labelMixEngineOnly
	rept		250
	move.b		(a0,d0.w),d2																; fetch sample cycle at engine effect current address + new offset
	swap		d0																			; effectively multiply offset by 65536
	add.l		d1,d0																		; add scaler to offset
	swap		d0																			; effectively divide offset by 65536
	move.b		d2,(a2)+																	; put accumulated sample value into dma buffer
	endr

labelFinishedSoundMixing

	add.w		d0,variableEngineEffectPosition											; store current position of engine sound effect
	cmp.w		#3116,variableEngineEffectPosition										; compare engine sound effect length with current position
	blo.s		labelFinishedAudio															; if current position is less than length then nothing to do
	sub.w		#3116,variableEngineEffectPosition										; otherwise adjust position

labelFinishedAudio

	movem.l		(sp)+,d0-d3/a0-a2
	rts
