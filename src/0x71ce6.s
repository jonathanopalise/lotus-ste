	ORG	$71ce6
	
    include generated/symbols_0x80000.inc

	jsr	do_sound_events

	tst.w	$7ccf0					; test for music (again)
	bmi.s	labelCheckEngineType	; if no music, then check if YM or DMA engine sound
	bra.s	$71d66							1 word
labelCheckEngineType
	tst.w	$7cd62			; test for 1 or 2 player	3 words
	beq.s	$71d66			; skip YM engine sound		1 word
	nop
	nop
