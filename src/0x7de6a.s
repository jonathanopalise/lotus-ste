    ORG $7de6a

    ; **************************************************************************
    ; * Lotus STE                                                              *
    ; *                                                                        *
    ; * YM channel C volume adjust                                             *
    ; *                                                                        *
    ; * This redirects to some code that normalises the volume between the     *
    ; * digital sound mixer and the YM music.                                  *
    ; **************************************************************************

	include generated/symbols_0x80000.inc

	jsr	YMChannelCVolumeAdjust
