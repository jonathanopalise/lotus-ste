    ORG $7910a

    ; **************************************************************************
    ; * Lotus STE                                                              *
    ; *                                                                        *
    ; * Jump to Blitter status panel rendering routine                         *
    ; **************************************************************************

    include generated/symbols_0x80000.inc
 
    jmp render_status_panel

