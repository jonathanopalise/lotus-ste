    ORG $7a2c0

    ; **************************************************************************
    ; * Lotus STE                                                              *
    ; *                                                                        *
    ; * Disable use of preshifted small sprites                                *
    ; *                                                                        *
    ; * The standard ST version of Lotus renders sprite data only at 16 pixel  *
    ; * intervals. This can result in sprites appearing to "jerk" sideways     *
    ; * across the screen. In order to make this effect less pronounced, the   *
    ; * standard ST version stores preshifted versions of some smaller sprites *
    ; * and has some code to select the appropriate preshifted version based   *
    ; * upon the desired x position of the sprite.                             *
    ; *                                                                        *
    ; * When using the blitter to render sprites, these preshifted variations  *
    ; * of the sprites are no longer required. This patch ensures that the     *
    ; * non-preshifted version of a given sprite is always used.               *
    ; **************************************************************************

    move.l #$7abf6,a3
    move.w d4,(a3)+
    move.w d1,(a3)+
    move.w d7,(a3)+
    asr.w #1,d0
    sub.w d0,d1
    move.l d1,a3


