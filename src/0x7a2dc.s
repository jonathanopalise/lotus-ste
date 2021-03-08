    ORG $7a2dc

    ; **************************************************************************
    ; * Lotus STE                                                              *
    ; *                                                                        *
    ; * Store sprite skew value                                                *
    ; *                                                                        *
    ; * The standard ST version renders sprites only at 16 pixel x intervals,  *
    ; * resulting in sprites appearing to "jerk" across the screen. Lotus STE, *
    ; * on the other hand, wants to use the Blitter to render sprites at exact *
    ; * pixel x positions.                                                     *
    ; *                                                                        *
    ; * Thankfully, the standard ST version does calculate a pixel-precise     *
    ; * x position, but rounds it off to the nearest multiple of 16 before     *
    ; * passing the value off to the sprite rendering code.                    *
    ; *                                                                        *
    ; * The purpose of this patch is to capture the pixel-precise x position   *
    ; * for a given sprite before it gets discarded. The value is stored in    *
    ; * the a3 register, which is thankfully not overwritten before the code   *
    ; * subsequently arrives at the blitter-based sprite rendering code at     *
    ; * either 0x7a312 (4bpp sprites) or 0x7a496 (3bpp sprites).               *
    ; **************************************************************************

    move.l d1,a3 
    and.w $7a642,d1
    move.w d1,d2
    asr.w #4,d2
    moveq #0,d1

