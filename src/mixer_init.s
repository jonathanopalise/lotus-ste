; --- audio buffer address initialisation. only needs to be done once
mixer_init:
	lea.l		bufferAudioMixer,a0
	lea.l		addressAudioCurrentStart,a1
	move.l		a0,(a1)+
	lea.l		250(a0),a0
	move.l		a0,(a1)+
	move.l		a0,(a1)+
	lea.l		250(a0),a0
	move.l		a0,(a1)

	move.w		#1000,$7cc3c					; force revs to 1000rpm - not needed now

	movem.l		d0/a0,-(sp)						; is this needed?

microwire_init:
    move.w		#%10000000001,d0       			; ym+dma mix (doesn't actually make a difference thanks to a hardware design error!)
	jsr			write_microwire
    move.w		#%10001000110,d0       			; bass = +0dB
	jsr			write_microwire
    move.w		#%10010000110,d0				; treble = +0dB
	jsr			write_microwire
    move.w		#%10011101000,d0				; master volume = +0dB
	jsr			write_microwire
    move.w		#%10100010100,d0				; right balance = +0dB
	jsr			write_microwire
    move.w		#%10101010100,d0				; left balance = +0dB
	jsr			write_microwire

	move.b		#%10000001,1(a0)				; set dma sound to mono 12517Hz
	
    movem.l		(sp)+,d0/a0						; is this needed?
	
	rts
