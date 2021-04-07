    ORG $7de36

    ; **************************************************************************
    ; * Lotus STE                                                              *
    ; *                                                                        *
    ; * YM channel A volume adjust                                             *
    ; *                                                                        *
    ; * This redirects to some code that normalises the volume between the     *
    ; * digital sound mixer and the YM music.                                  *
    ; **************************************************************************

	include generated/symbols_0x80000.inc

	jmp	YMChannelAVolumeAdjust
