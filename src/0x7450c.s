
    ORG $7450c

    ; **************************************************************************
    ; * Lotus STE                                                              *
    ; *                                                                        *
    ; * Disable road/ground palette setting from ST data                       *
    ; *                                                                        *
    ; * Prior to the beginning of a race, the code at 0x7450c sets the         *
    ; * track-specific palette entries for the road and ground. Unfortunately, *
    ; * the source data used by this code doesn't contain the least            *
    ; * significant bit in the RGB values that would make it leverage the      *
    ; * enhanced STE. It's therefore been disabled here.                       *
    ;                                                                          *
    ; * Thankfully, the source data files do contain the RGB values from the   *
    ; * Amiga version for the road and ground - they're just stored in a       *
    ; * different place. The code that sets these values is now located        *
    ; * in preprocess_palette.s, and called by the patch in 0x744ba.s.         *
    ; **************************************************************************

    addq.l #8,a0
    rept 13
    nop
    endr

