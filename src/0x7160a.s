    ORG $7160a

    ; **************************************************************************
    ; * Lotus STE                                                              *
    ; *                                                                        *
    ; * Call to init_mountains_game                                            *
    ; **************************************************************************
    
	include generated/symbols_0x80000.inc

	jsr	init_mountains_game
    nop
    nop
