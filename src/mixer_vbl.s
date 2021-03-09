; --- variable + fixed frequency 2-channel mixer. ideally put near the top of the vbl
mixer_vbl:
	movem.l		d0-d3/a0-a3,-(sp)

	lea.l		$ffff8900.w,a0																; dma audio registers base address
	lea.l		addressAudioCurrentStart,a1
	move.b		9(a1),$03(a0)											; set start address high byte
	move.b		10(a1),$05(a0)											; set start address middle byte (of buffer a)
	move.b		11(a1),$07(a0)											; set start address low byte
	move.b		13(a1),$0f(a0)											; set end address high byte
	move.b		14(a1),$11(a0)											; set end address middle byte (of buffer a)
	move.b		15(a1),$13(a0)											; set end address low byte
	move.b		#1,$01(a0)																	; (re)start dma

	move.l		(a1),d0													; these lines swap the current/working audio buffers
	move.l		4(a1),d1
	move.l		8(a1),d2
	move.l		12(a1),d3
	move.l		d0,8(a1)
	move.l		d1,12(a1)
	move.l		d2,(a1)
	move.l		d3,4(a1)

	move.l		d0,a2


; --- need to do 1 or 2 player checks here, and write 2 player mixer
; --- need to find state machine/flag to determine which routine to jump to

	move.w		#%10011101000,d0															; master volume = +0dB

;	tst.w		$707c4																		; state machine: 0 = ingame, 1 = not ingame
;	bne.s		labelFinishedVolumeCheck													; not ingame, so stay with full volume

	move.w		$72002,d1																	; fetch player 1 revs volume
	sub.w		#23,d1																		; 63 volume levels on the Amiga, but only 40 from +0dB on the STE, so subtract difference
	neg			d1																			; invert the value
	add.w		#40,d1																		; add amount of STE steps
	sub.w		d1,d0																		; subtract result from master volume centre volume

labelFinishedVolumeCheck
	jsr			write_microwire																; write value to microwire master volume register

	move.w		variableP1EngineEffectPosition,d0											; current step into engine effect
	lea.l		dataSoundEngine,a0															; base address of engine sound effect
	lea.l		(a0,d0.w),a0																; offset current engine effect position into engine sound effect base address

	move.w		$7cc3c,d0																	; fetch 'auserevs' (player 1 ingame revs)
	sub.w		#1000,d0																	; subtract 1000rpm
	lsl.w		#2,d0																		; multiply revs by 4 to get scaler table offset
	lea.l		table12517HzScaler,a1														; scaler table base address
	move.l		(a1,d0.w),d1																; fetch value from scaler table offset

;	move.w		$72002,

	move.w		variableP1SoundEventLatch,d2												; is there a sound event?
	bmi			labelMixEngineOnly															; if not then just mix the engine sound

labelMixEngineAndSoundEvent
	mulu.w		#6,d2																		; multiply sound event value by 6 to get sound event table offset
	lea.l		tableSoundEvents,a1															; sound event table base address
	move.l		(a1,d2),a3																	; fetch sound event base address from sound event table offset
	addq.b		#4,d2																		; move to sound event length offset
	move.w		(a1,d2),d3																	; fetch sound event length from sound event table offset
	move.w		variableP1SoundEventPosition,d0												; move current sound event sample position into d0
	lea.l		(a3,d0),a1																	; offset sample base address to current sound event sample position
	moveq		#0,d0

	rept		250
	move.b		(a0,d0.w),d2																; fetch sample cycle at engine effect current address + new offset
	swap		d0																			; effectively multiply offset by 65536
	add.l		d1,d0																		; add scaler to offset
	swap		d0																			; effectively divide offset by 65536
	add.b		(a1)+,d2
	move.b		d2,(a2)+																	; put accumulated sample value into dma buffer
	endr

	add.w		#250,variableP1SoundEventPosition												; store current position of sound event effect
	cmp.w		variableP1SoundEventPosition,d3												; compare current sound event position with sound event length
	bhi.s		labelFinishedP1SoundEventFalse												; if sound event length is higher than current position then nothing to do
	move.w		#$ffff,variableP1SoundEventLatch												; set sound event latch to null
labelFinishedP1SoundEventFalse

	bra			labelFinishedSoundMixing													; finished

labelMixEngineOnly
	moveq		#0,d0

	rept		250
	move.b		(a0,d0.w),d2																; fetch sample cycle at engine effect current address + new offset
	swap		d0																			; effectively multiply offset by 65536
	add.l		d1,d0																		; add scaler to offset
	swap		d0																			; effectively divide offset by 65536
	move.b		d2,(a2)+																	; put accumulated sample value into dma buffer
	endr

labelFinishedSoundMixing

	add.w		d0,variableP1EngineEffectPosition											; store current position of engine sound effect
	cmp.w		#3116,variableP1EngineEffectPosition										; compare engine sound effect length with current position
	blo.s		labelResetP1EngineEffectPositionFalse												; if current position is less than length then nothing to do
	sub.w		#3116,variableP1EngineEffectPosition								; otherwise adjust position
labelResetP1EngineEffectPositionFalse

	movem.l		(sp)+,d0-d3/a0-a3
	rts
