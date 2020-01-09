    ORG $7a496

    include symbols.inc

    ; code at 0x7a496 (tst.w d2) seems to be equivalent to what we have in 7a312
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


    tst.w     d2
    bpl.s     label_7a4ae
    tst.w     d6
    bmi       nothingtodraw
    move.w    d2,d0
    moveq     #0,d2
    add.w     d0,d4
    add.w     d0,d0
    add.w     d0,d0
    add.w     d0,d0
    suba.w    d0,a0

label_7a4ae:
    tst.w     d5
    bpl.s     label_7a4c8
    tst.w     d7
    bmi       nothingtodraw
    move.w    d5,d0
    moveq     #0,d5
    add.w     d0,d3
    add.w     d0,d0
    muls.w    d1,d0
    add.w     d0,d0
    add.w     d0,d0
    suba.w    d0,a0
label_7a4c8:
    cmp.w     #$14,d6
    bmi.s     label_7a4de
    cmp.w     #$14,d2
    bpl       nothingtodraw
    move.w    d6,d0
    subi.w    #$14,d0
    sub.w     d0,d4
label_7a4de:
    cmp.w     $7ad6e,d7
    bls.s     label_7a4f4
    sub.w     $7ad6e,d7
    addq.w    #1,d7
    sub.w     d7,d3
    bls       nothingtodraw
label_7a4f4:
    move.w    d4,d6
    add.w     d6,d6
    subi.w    #$28,d6
    neg.w     d6
    move.w    d1,d7
    sub.w     d4,d7
    add.w     d7,d7
    add.w     d7,d7
    add.w     d7,d7
    asl.w     #2,d6
    add.w     d2,d2
    move.w    d5,d0
    add.w     d0,d0
    add.w     d0,d0
    add.w     d0,d5
    asl.w     #3,d5
    add.w     d5,d2
    asl.w     #2,d2
    adda.w    d2,a2
    adda.l    $7c504,a2
    movea.l   a2,a1
    tst.w     d4
    beq       nothingtodraw

    jmp drawscenery_3bpp

nothingtodraw:

    jmp $7a63a
