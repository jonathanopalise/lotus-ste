; --- audio buffer address initialisation. only needs to be done once
mixer_init:
	tst.w		hasDmaSound
	beq			mixer_init_end

	movem.l		d0/a0-a1,-(sp)							; is this needed?

	lea.l		$ffff8900.w,a0							; dma audio base address

    move.w		#%10000000001,d0       					; ym+dma mix (doesn't actually make a difference thanks to a hardware design error!)
	bsr			write_microwire
    move.w		#%10001000110,d0       					; bass = +0dB
	bsr			write_microwire
    move.w		#%10010000110,d0						; treble = +0dB
	bsr			write_microwire
	move.w		#%10011101000,d0						; master volume = +0dB				(10011100101 for mf intro, then return to +0dB?)
	bsr			write_microwire
    move.w		#%10100010100,d0						; right balance = +0dB
	bsr			write_microwire
    move.w		#%10101010100,d0						; left balance = +0dB
	bsr			write_microwire

	move.l		#dataSounds,addressAudioCurrentStart
	lea.l		addressAudioCurrentStart,a1

	move.b		1(a1),$03(a0)							; set start address high byte
	move.b		2(a1),$05(a0)							; set start address middle byte
	move.b		3(a1),$07(a0)							; set start address low byte	

	add.l		#120704,(a1)							; size of sample

	move.b		1(a1),$0f(a0)							; set end address high byte
	move.b		2(a1),$11(a0)							; set end address middle byte
	move.b		3(a1),$13(a0)							; set end address low byte

	move.b		#%10000001,$21(a0)						; set dma sound to mono 12517Hz

	move.b		#1,$01(a0)								; start dma	

	lea.l		bufferAudioMixer,a0						; start address of audio mixer buffer
	move.l		a0,(a1)+								; store start address of first half of buffer
	lea.l		250(a0),a0								; add size of first half of buffer
	move.l		a0,(a1)+								; store end address of first half of buffer				
	move.l		a0,(a1)+								; store start address of second half of buffer
	lea.l		250(a0),a0								; add size of second half of buffer
	move.l		a0,(a1)									; store end address of second half of buffer

    movem.l		(sp)+,d0/a0-a1							; is this needed?

mixer_init_end
	
    clr.w		$7ccfa									; replaces instruction overwritten by jump to this routine
    move.w		#$1ea,$7ccf6							; but uses longer delay...
    move.w		#$1f4,$7ccf8							; ... to make sure all of intro sample plays

	rts

write_microwire
	move.w		#%0000011111111111,$24(a0)				; write microwire mask
	move.w		d0,$22(a0)								; write data to microwire
	rts
