
    ORG $70660

    ; **************************************************************************
    ; * Lotus STE                                                              *
    ; *                                                                        *
    ; * VBL modifications                                                      *
    ; *                                                                        *
    ; * Address $70660 lies within the in-raceVBL handler. The purpose of      *
    ; * these changes is twofold:                                              *
    ; *                                                                        *
    ; * 1) To call the sound mixer;                                            *
    ; * 2) To change the existing Timer B code to redirect to the new sky      *
    ; *    gradient code.                                                      *
    ; **************************************************************************

    include generated/symbols_0x80000.inc

    ;the jsr is equivalent to 6 nops
    ;jsr timera_irq_new
    jmp gradient_init
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop


