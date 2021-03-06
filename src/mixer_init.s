; --- audio buffer address initialisation. only needs to be done once
mixer_init:
	lea.l		bufferAudioCurrent,a0
	move.l		a0,addressAudioCurrentStart
	lea.l		250(a0),a0
	move.l		a0,addressAudioCurrentEnd
	lea.l		bufferAudioWorking,a0
	move.l		a0,addressAudioWorkingStart
	lea.l		250(a0),a0
	move.l		a0,addressAudioWorkingEnd

	move.b		#%10000001,$ffff8921.w														; set dma sound to mono 12517Hz
    rts
