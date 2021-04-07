	ORG	$71ce6
	
    include generated/symbols_0x80000.inc

	jmp		do_sound_events
	rept	68
	nop
	endr
