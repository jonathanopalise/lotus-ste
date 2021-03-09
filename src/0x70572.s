    ORG $70572

    ; **************************************************************************
    ; * Lotus STE                                                              *
    ; *                                                                        *
    ; * VBL intercept for mixer                                                *
    ; *                                                                        *
    ; * $70572 is the start of the VBL routine. We've intercepted this entry   *
    ; * point here so that we can run the digital sound mixer at all times.    *
    ; **************************************************************************
    
	include generated/symbols_0x80000.inc

	jmp vbl_start_intercept
