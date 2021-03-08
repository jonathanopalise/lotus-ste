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

	move.w		#1000,$7cc3c					; force revs to 1000rpm

	movem.l		d0/a0,-(sp)

	lea.l		$ffff8920.w,a0					; ste dma sound base address

microwire_init:
        move.w		#%10000000001,d0        			; ym+dma mix (doesn't actually make a difference thanks to a hardware design error!)
	bsr.s		write_microwire
        move.w		#%10001000110,d0        			; bass = +0dB
	bsr.s		write_microwire
        move.w		#%10010000011,d0				; treble = -6dB (to be close to Amiga lowpass filter
	bsr.s		write_microwire
        move.w		#%10011101000,d0				; master volume = +0dB
	bsr.s		write_microwire
        move.w		#%10100010100,d0				; right balance = +0dB
	bsr.s		write_microwire
        move.w		#%10101010100,d0				; left balance = +0dB
	bsr.s		write_microwire
	bra.s		finished_microwire

write_microwire:
	move.w		#%0000011111111111,4(a0)
	move.w		d0,2(a0)
	rts
	
finished_microwire:
	move.b		#%10000001,1(a0)				; set dma sound to mono 12517Hz
	
        movem.l		(sp)+,d0/a0
	
	rts
