    ORG $7a312

    include generated/symbols_0x80000.inc

    moveq     #0,d0
    move.w    d0,leftclipped
    move.w    d0,rightclipped

    move.l a3,d0                       ; get desired xpos of scenery object
    and.l #$f,d0                       ; convert to skew value for blitter

    beq zeroskew

    move.w d2,d0                       ; get starting position in blocks of 16 pixels
    add.w d4,d0                        ; add number of 16 pixel blocks to be drawn

    cmp.w #$14,d0                      ; will part of sprite be off right side if we add 16 pixels?
    bpl.s setrightclipped              ; if yes, don't add 16 pixels to the right side

    add.w #1,d4                        ; add another 16 pixel block to account for skew
    bra.s zeroskew

setrightclipped:

    move.w    #$ffff,rightclipped

zeroskew:

    tst.w     d2                       ; set flags for d2
    bpl.s     label_7a32c              ; jump when no left clipping required
    tst.w     d6                       ; bytes to skip after each line
    bmi       nothingtodraw            ; if negative, nothing to draw
    move.w    d2,d0
    moveq     #0,d2                    ; clip scenery against left (left endmask should be 0xffff)
                                       ; at this point, left endmask needs be to 0xffff
    move.w    #$ffff,leftclipped
    add.w     d0,d4
    add.w     d0,d0
    suba.w    d0,a0
    add.w     d0,d0
    add.w     d0,d0
    suba.w    d0,a0

label_7a32c:
    tst.w     d5                       ; do we need to clip the top of the sprite?
    bpl.s     label_7a348              ; if we take the jump, no need to clip the top
    tst.w     d7                       ; is the bottom of the sprite off screen too?
    bmi       nothingtodraw
    move.w    d5,d0
    moveq     #0,d5
    add.w     d0,d3
    add.w     d0,d0
    muls.w    d1,d0
    suba.w    d0,a0
    add.w     d0,d0
    add.w     d0,d0
    suba.w    d0,a0

label_7a348:
    cmp.w     #$14,d6
    bmi.s     label_7a35e              ; something to do with clipping against right side of screen
    cmp.w     #$14,d2                  ; does sprite need clipping on right edge?
    bpl       nothingtodraw            ; something to do with clipping - if sprite is entirely off screen?
    move.w    d6,d0
    subi.w    #$14,d0
    sub.w     d0,d4                    ; this is chopping off the sprite on the right edge
    move.w    #$ffff,rightclipped

    ; sprite has been clipped on right edge
    ; so endmask3 needs to be $ffff

label_7a35e:
    cmp.w     $7ad6e,d7
    bls.s     label_7a374
    sub.w     $7ad6e,d7
    addq.w    #1,d7
    sub.w     d7,d3
    bls       nothingtodraw

label_7a374:
    move.w    d4,d6
    add.w     d6,d6
    subi.w    #$28,d6
    neg.w     d6
    move.w    d1,d7            ; d7 = d1
    sub.w     d4,d7            ; d7 = d1 - d4 (blocks of 16 pixels to skip after each line)

    move.w    d7,d0            ; ...
    add.w     d0,d0            ; ...
    add.w     d0,d0            ; ...
    add.w     d0,d7            ; ...
    add.w     d7,d7            ; d7 = d7 * 10 (final value for number of source bytes to skip after each line)
    asl.w     #2,d6            ; d6 = d6 * 4 (final value of destination bytes to skip after each line)
    add.w     d2,d2            ; d2 = d2 * 2
    move.w    d5,d0            ; begin expression...
    add.w     d0,d0            ; ...
    add.w     d0,d0            ; ...
    add.w     d0,d5            ; ...
    asl.w     #3,d5            ; ... d5 = d5 * 40
    add.w     d5,d2            ; begin expression...
    add.w     d2,d2            ; ...
    add.w     d2,d2            ; ...
    adda.w    d2,a2            ; ... d2 = (d2 * 8 [see 7a38c]) + d5 (d5 must the start of a line within logbase, so a multiple of 160)
                                                                              ; we set d5 to 0 and everything renders at the top line of the screen
    adda.l    $7c504,a2        ; add buffer location into a2?
    movea.l   a2,a1            ; transfer destination address into a1
    tst.w     d4
    beq       nothingtodraw
    
    jmp drawscenery

nothingtodraw:

    jmp $7a63a
