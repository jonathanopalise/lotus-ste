    ORG $7160a

    ; **************************************************************************
    ; * Lotus STE                                                              *
    ; *                                                                        *
    ; * Call to init_mountains                                                 *
    ; **************************************************************************
    
	include generated/symbols_0x80000.inc

	jsr	init_mountains
    nop
    nop
