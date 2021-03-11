; --- variable + fixed frequency 2-channel mixer. ideally put near the top of the vbl
mixer_vbl:
	movem.l		d0-d3/a0-a3,-(sp)

; --- conditions:
; --- 7cce6 = 1					play intro sample (to do later...)
; --- 7cce6 = 29 & 7cd56 = 0	master volume to +0dB
; --- 7cce6 = 29 & 7cd56 != 0	master volume to +0dB, clear audio buffer
; --- 7cd56 != 0				don't fade
; --- anything else				master volume to +0dB and clear audio buffer

	move.w		#%10011101000,d0															; master volume = +0dB
	tst.w		$707c4																		; check game state flag
	beq			labelAudioInGame															; if not zero, then not in game

	move.w		$7cce6,d1																	; fetch out of game state machine

;	cmp.w		#1,d0																		; for testing Magnetic Fields intro screen (to do later)
;	bne.s		labelCheckIfAudioInStereoScreen or similar...

	cmp.w		#$29,d1																		; check if on stereo screen
	bne.s		labelClearAudioBuffer

	tst.w		$7cd56																		; check if music track is selected
	beq			labelFinishedVolumeCheck													; if not then don't clear audio buffer

labelClearAudioBuffer
	cmp.w		#$34,d1																		; check if on race results screen
	bne.s		labelNoMuteBeforeClear
	move.w		#%10011000000,d0															; master volume = -80dB to mask click when clearing audio buffer due to no music

labelNoMuteBeforeClear
	moveq		#0,d1																		; value to write to buffer
	lea.l		bufferAudioMixer,a0															; base address of both buffers

	rept		125																			; buffer size in bytes / 4
	move.l		d1,(a0)+																	; wipe it
	endr

	bra			labelFinishedVolumeCheck													; thank you

labelAudioInGame
	tst.w		$7cd56																		; if no music track selected, then don't fade out
	bne.s		labelFinishedVolumeCheck

	move.w		$72002,d1																	; fetch ausevol
	lsr.w		#1,d1																		; divide by 2
	sub.w		#31,d1																		; subtract maximum value
	neg			d1																			; invert the value
	sub.w		d1,d0																		; subtract result from master volume centre position
		
labelFinishedVolumeCheck
	jsr			write_microwire																; use value in d0 to write master volume data to microwire

	lea.l		$ffff8900.w,a0																; dma audio registers base address
	lea.l		addressAudioCurrentStart,a1
	move.b		9(a1),$03(a0)																; set start address high byte
	move.b		10(a1),$05(a0)																; set start address middle byte (of buffer a)
	move.b		11(a1),$07(a0)																; set start address low byte
	move.b		13(a1),$0f(a0)																; set end address high byte
	move.b		14(a1),$11(a0)																; set end address middle byte (of buffer a)
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

	move.w		variableP1EngineEffectPosition,d0											; current step into engine effect
	lea.l		dataSoundEngine,a0															; base address of engine sound effect
	lea.l		(a0,d0.w),a0																; offset current engine effect position into engine sound effect base address

	move.w		$7cc3c,d0																	; fetch 'auserevs' (player 1 ingame revs)
	sub.w		#1000,d0																	; subtract 1000rpm
	lsl.w		#2,d0																		; multiply revs by 4 to get scaler table offset
	lea.l		table12517HzScaler,a1														; scaler table base address
	move.l		(a1,d0.w),d1																; fetch value from scaler table offset

	moveq		#0,d0																		; clear it for use as engine offset

	tst.w		variableP1SoundEventLatch													; is there a sound event?
	bmi			labelMixEngineOnly															; if not then just mix the engine sound

labelMixEngineAndSoundEvent
	move.l		variableP1SoundEventAddress,a1												; current sound event sample base address											
	move.w		variableP1SoundEventPosition,d2												; offset into sample data
	lea.l		(a1,d2),a1																	; adjust address

	rept		250
	move.b		(a0,d0.w),d2																; fetch sample cycle at engine effect current address + new offset
	swap		d0																			; effectively multiply offset by 65536
	add.l		d1,d0																		; add scaler to offset
	swap		d0																			; effectively divide offset by 65536
	add.b		(a1)+,d2																	; add sound event sample to mix
	move.b		d2,(a2)+																	; put accumulated sample value into dma buffer
	endr

	add.w		#250,variableP1SoundEventPosition											; store current position of sound event effect
	move.w		variableP1SoundEventLength,d1												; fetch sound event length
	cmp.w		variableP1SoundEventPosition,d1												; compare current sound event position with sound event length
	bhi			labelFinishedSoundMixing													; if sound event length is higher than current position then nothing to do
	move.w		#$ffff,variableP1SoundEventLatch											; set sound event latch to null

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

	add.w		d0,variableP1EngineEffectPosition											; store current position of engine sound effect
	cmp.w		#3116,variableP1EngineEffectPosition										; compare engine sound effect length with current position
	blo.s		labelResetP1EngineEffectPositionFalse										; if current position is less than length then nothing to do
	sub.w		#3116,variableP1EngineEffectPosition										; otherwise adjust position
labelResetP1EngineEffectPositionFalse

	movem.l		(sp)+,d0-d3/a0-a3
	rts

