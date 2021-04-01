    ORG $7133e

    ; **************************************************************************
    ; * Lotus STE                                                              *
    ; *                                                                        *
    ; * Call to init_mountains_demo                                            *
    ; **************************************************************************
    
	include generated/symbols_0x80000.inc

	jsr	init_mountains_demo
    nop
    nop
