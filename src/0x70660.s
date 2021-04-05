
    ORG $70660

    ; **************************************************************************
    ; * Lotus STE                                                              *
    ; *                                                                        *
    ; * VBL sky gradient modifications                                         *
    ; *                                                                        *
    ; * Address $70660 lies within the in-raceVBL handler. The purpose of this *
    ; * change is to redirect from the existing Timer B code to the new        *
    ; * sky gradient code.                                                     *
    ; **************************************************************************

    include generated/symbols_0x80000.inc

    jmp p1_raster_routine
