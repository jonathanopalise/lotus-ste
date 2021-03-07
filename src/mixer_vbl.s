; --- variable + fixed frequency 2-channel mixer. ideally put near the top of the vbl
mixer_vbl:
    movem.l		d0-d7/a0-a6,-(sp)

	move.l		addressAudioCurrentStart,d0													; these lines swap the current/working audio buffers
	move.l		addressAudioCurrentEnd,d1
	move.l		addressAudioWorkingStart,d2
	move.l		addressAudioWorkingEnd,d3
	move.l		d0,addressAudioWorkingStart
	move.l		d1,addressAudioWorkingEnd
	move.l		d2,addressAudioCurrentStart
	move.l		d3,addressAudioCurrentEnd

	lea.l		$ffff8900.w,a0																; dma audio registers base address
	move.b		addressAudioCurrentStart+1,$03(a0)											; set start address high byte
	move.b		addressAudioCurrentStart+2,$05(a0)											; set start address middle byte (of buffer a)
	move.b		addressAudioCurrentStart+3,$07(a0)											; set start address low byte
	move.b		addressAudioCurrentEnd+1,$0f(a0)											; set end address high byte
	move.b		addressAudioCurrentEnd+2,$11(a0)											; set end address middle byte (of buffer a)
	move.b		addressAudioCurrentEnd+3,$13(a0)											; set end address low byte
	move.b		#1,$01(a0)																	; (re)start dma

	move.w		variableEngineEffectPosition,d0												; current step into engine effect
	lea.l		dataSoundEngine,a0															; base address of engine sound effect
	lea.l		(a0,d0.w),a0																; offset current engine effect position into engine sound effect base address
	move.l		addressAudioWorkingStart,a2													; dma audio buffer

	cmp.b		#$ff,variableSoundEvent														; is there a sound event?
	beq			labelMixEngineOnly															; if not then just mix the engine sound

labelMixEngineAndSoundEvent
	move.w		$7cc3c,d0           														; fetch revs value - change this to 'move.w	$7cc3c,d0'
	sub.w		#1000,d0																	; subtract 1000rpm
	lsl.w		#2,d0																		; multiply revs by 4 to get scaler table offset
	lea.l		table12517HzScaler,a1														; scaler table base address
	move.l		(a1,d0.w),d1																; fetch value from scaler table offset
	moveq		#0,d0
	move.b		variableSoundEvent,d0														; fetch sound event value
	mulu.w		#6,d0																		; multiply sound event value by 6 to get sound event table offset
	lea.l		tableSoundEvents,a1															; sound event table base address
	move.l		(a1,d0),a3																	; fetch sound event base address from sound event table offset
	addq.b		#4,d0																		; move to sound event length offset
	move.w		(a1,d0),d3																	; fetch sound event length from sound event table offset
	move.w		variableSoundEventPosition,d0												; move current sound event sample position into d0
	lea.l		(a3,d0),a1																	; offset sample base address to current sound event sample position
	moveq		#0,d0

	;move.w		#$1000,d7																	; --- FOR CPU PROFILING ONLY! REMOVE BEFORE PUTTING INTO GAME
.delay																						; --- FOR CPU PROFILING ONLY! REMOVE BEFORE PUTTING INTO GAME
	;dbf.w		d7,.delay																	; --- FOR CPU PROFILING ONLY! REMOVE BEFORE PUTTING INTO GAME
	;move.w		#$0007,$ffff8240.w															; --- FOR CPU PROFILING ONLY! REMOVE BEFORE PUTTING INTO GAME

	rept		250
	move.b		(a0,d0.w),d2																; fetch sample cycle at engine effect current address + new offset
	swap		d0																			; effectively multiply offset by 65536
	add.l		d1,d0																		; add scaler to offset
	swap		d0																			; effectively divide offset by 65536
	add.b		(a1)+,d2
	move.b		d2,(a2)+																	; put accumulated sample value into dma buffer
	endr

	;move.w		#$0777,$ffff8240.w															; --- FOR CPU PROFILING ONLY! REMOVE BEFORE PUTTING INTO GAME

	add.w		d0,variableEngineEffectPosition												; store current position of engine sound effect
	cmp.w		#3116,variableEngineEffectPosition											; compare engine sound effect length with current position
	blo.s		.resetengineeffectpositionfalse												; if current position is less than length then nothing to do
	sub.w		#3116,variableEngineEffectPosition											; otherwise adjust position
.resetengineeffectpositionfalse

	add.w		#250,variableSoundEventPosition												; store current position of sound event effect
	cmp.w		variableSoundEventPosition,d3												; compare current sound event position with sound event length
	bhi.s		.resetsoundeventpositionfalse												; if sound event length is higher than current position then nothing to do
	move.b		#$ff,variableSoundEvent														; set sound event to null
	move.b		#0,variableSoundEventPosition												; set sound event position to 0
.resetsoundeventpositionfalse

	bra			labelFinishedSoundMixing													; finished

labelMixEngineOnly
	move.w		$7cc3c,d0														; fetch revs value - change this to 'move.w	$7cc3c,d0'
	sub.w		#1000,d0																	; subtract 1000rpm
	lsl.w		#2,d0																		; multiply revs by 4 to get scaler table offset
	lea.l		table12517HzScaler,a1														; scaler table base address
	move.l		(a1,d0.w),d1																; fetch value from scaler table offset
	moveq		#0,d0

	;move.w		#$1000,d7																	; --- FOR CPU PROFILING ONLY! REMOVE BEFORE PUTTING INTO GAME
.delay																						; --- FOR CPU PROFILING ONLY! REMOVE BEFORE PUTTING INTO GAME
	;dbf.w		d7,.delay																	; --- FOR CPU PROFILING ONLY! REMOVE BEFORE PUTTING INTO GAME
	;move.w		#$0007,$ffff8240.w															; --- FOR CPU PROFILING ONLY! REMOVE BEFORE PUTTING INTO GAME

	rept		250
	move.b		(a0,d0.w),d2																; fetch sample cycle at engine effect current address + new offset
	swap		d0																			; effectively multiply offset by 65536
	add.l		d1,d0																		; add scaler to offset
	swap		d0																			; effectively divide offset by 65536
	move.b		d2,(a2)+																	; put accumulated sample value into dma buffer
	endr

	;move.w		#$0777,$ffff8240.w															; --- FOR CPU PROFILING ONLY! REMOVE BEFORE PUTTING INTO GAME

	add.w		d0,variableEngineEffectPosition												; store current position of engine sound effect
	cmp.w		#3116,variableEngineEffectPosition											; compare engine sound effect length with current position
	blo.s		.resetengineeffectpositionfalse												; if current position is less than length then nothing to do
	sub.w		#3116,variableEngineEffectPosition											; otherwise adjust position
.resetengineeffectpositionfalse

labelFinishedSoundMixing
	movem.l		(sp)+,d0-d7/a0-a6
    rts
