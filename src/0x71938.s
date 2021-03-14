    ORG $71938

    ; **************************************************************************
    ; * Lotus STE                                                              *
    ; *                                                                        *
    ; * Patch forced game freeze                                               *
    ; *                                                                        *
    ; * The code at $71938 checks if the longword at $7fffc is zero and        *
    ; * redirects to an infinite loop at $719b0 if it's not zero. The reason   *
    ; * for this is unknown and this patch therefore removes it.               *
    ; **************************************************************************

	nop
    nop
    nop
    nop
