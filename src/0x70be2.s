	ORG	$70be2

	include generated/symbols_0x80000.inc
	
	jmp	ym_engine_volume_adjust

	movem.l	(sp)+,d0-d7/a0-a6
	rts
	nop
	nop
	nop
	nop
	nop
	nop
	nop
