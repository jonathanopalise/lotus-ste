leftclipped:

    dc.w 0

rightclipped:

    dc.w 0

drawscenery:

    ; draw a roadside object
    ; a0 is source address
    ; a1 is destination address
    ; d3 is the lines to be drawn
    ; d4 is number of 16 pixel blocks to be drawn (= 8 words)
    ; - so if d4 = 1, we want to draw 16 pixels = 4 words = 8 bytes
    ; d6 is destination bytes to skip after each line
    ; d7 is source bytes to skip after each line

    movem.l a2-a6,-(a7)
    lea $ffff8a38.w,a2
    lea $ffff8a24.w,a4
    lea $ffff8a32.w,a5
    lea $ffff8a3c.w,a6

    addq.l #8,d6               ; convert to value suitable for blitter
    add.w #10,d7               ; convert to value suitable for blitter

    move.w #10,($ffff8a20).w   ; source x increment
    move.w #8,($ffff8a2e).w    ; dest x increment
    move.w #$201,($ffff8a3a).w ; hop/op: read from source, source & destination

    move.l a3,d0               ; get desired xpos of scenery object
    and.w #$f,d0               ; convert to skew value for blitter

    move.w d0,d1
    beq.s nonfsr               ; if skew is zero, we can't use nfsr

    cmp.w #1,d4
    beq.s nonfsr

    tst.w rightclipped
    bne.s nonfsr

    add.w #10,d7
    or.b #$40,d1

nonfsr:

    tst.w leftclipped
    beq.s nofxsr

    sub.w #10,d7
    lea -10(a0),a0
    or.b #$80,d1

    cmp.w #1,d4
    bne.s nofxsr 

    ; when words to draw = 4 and leftclipped != 0, we need to set endmask1 from rightendmasks
    ; In the case of a one word line ENDMASK 1 is used (http://www.atari-wiki.com/index.php/Blitter_manual)
    ; this is a special case and could do with tidying up

    move.w d7,($ffff8a22).w             ; source y increment
    move.w d6,($ffff8a30).w             ; dest y increment
    move.w d4,($ffff8a36).w             ; xcount = number of 16 pixel blocks (one pass per bitplane)
    move.b d1,($ffff8a3d).w

    lea.l rightendmasks(pc),a3
    add.l d0,d0                         ; byte offset in mask lookup table
    move.w (a3,d0.w),d1
    move.w d1,($ffff8a28).w             ; endmask1
    bra.s blitterstart

nofxsr:

    move.w d7,($ffff8a22).w             ; source y increment
    move.w d6,($ffff8a30).w             ; dest y increment
    move.w d4,($ffff8a36).w             ; xcount = number of 16 pixel blocks (once pass per bitplane)
    move.b d1,($ffff8a3d).w

    add.l d0,d0                         ; byte offset in mask lookup table
    move.w #-1,($ffff8a2a).w            ; endmask2

    move.w leftclipped(pc),d1
    bne.s nocalcendmask1                ; branch if zero flag not set

    lea.l leftendmasks(pc),a3
    move.w (a3,d0.w),d1                 ; fetch value of endmask1

nocalcendmask1:
    move.w d1,($ffff8a28).w             ; endmask1

    move.w rightclipped(pc),d1
    bne.s nocalcendmask3                ; branch if zero flag not set

    lea.l rightendmasks(pc),a3
    move.w (a3,d0.w),d1

nocalcendmask3:
    move.w d1,($ffff8a2c).w            ; endmask3

    ; we are now free to use d0, d6 and d4 for our own purposes
    ; looks like d0, d1 and d2 are also available to us

blitterstart:
    move.w #802,d1
    lsl.w #2,d3
    sub.w d3,d1
    move.w d1,2+drawsceneryplane_jsr    ; jump address in unrolled blitter calling table
    moveq.l #1,d1                       ; ycount
    move.b #$c0,d6                      ; blitter start instruction

    rept 3
    bsr drawsceneryplane
    addq.l #2,a1                        ; move to next bitplane
    endr
    bsr drawsceneryplane

    subq.l #6,a1                        ; move destination back to initial bitplane
    move.w #$0207,($ffff8a3a).w         ; hop/op: read from source, source | destination

    rept 3
    addq.l #2,a0                        ; move source to next bitplane
    bsr drawsceneryplane
    addq.l #2,a1                        ; move destination to next bitplane
    endr
    addq.l #2,a0                        ; move source to next bitplane
    bsr drawsceneryplane

    movem.l (a7)+,a2-a6

    rts

drawsceneryplane:
    move.l a0,(a4)             ; set source address
    move.l a1,(a5)             ; set destination

drawsceneryplane_jsr:
    bra drawsceneryplane_aft
    rept 200
    move.w d1,(a2)             ; ycount
    move.b d6,(a6)
    endr
drawsceneryplane_aft:
    rts

drawscenery_3bpp:

    movem.l a2-a6,-(a7)
    lea $ffff8a38.w,a2
    lea $ffff8a24.w,a4
    lea $ffff8a32.w,a5
    lea $ffff8a3c.w,a6

    moveq.l #8,d0
    add.l d0,d6                        ; convert to value suitable for blitter
    add.w d0,d7                        ; convert to value suitable for blitter

    move.w d0,($ffff8a20).w            ; source x increment
    move.w d0,($ffff8a2e).w             ; dest x increment
    move.w #$0201,($ffff8a3a).w         ; hop/op: read from source, source & destination

    move.l a3,d0                        ; get desired xpos of scenery object
    and.w #$f,d0                        ; convert to skew value for blitter
    move.w d0,d1
    beq.s nonfsr_3bpp                        ; if skew is zero, we can't use nfsr

    cmp.w #1,d4
    beq.s nonfsr_3bpp

    tst.w rightclipped
    bne.s nonfsr_3bpp

    add.w #8,d7
    or.b #$40,d1

nonfsr_3bpp:

    tst.w leftclipped
    beq.s nofxsr_3bpp

    sub.w #8,d7 ; d7 is source bytes to skip after each line - might need to be tuned
    sub.w #8,a0 ; blitter source
    or.b #$80,d1

    cmp.w #1,d4
    bne.s nofxsr_3bpp

    ; when words to draw = 4 and leftclipped != 0, we need to set endmask1 from rightendmasks
    ; In the case of a one word line ENDMASK 1 is used (http://www.atari-wiki.com/index.php/Blitter_manual)
    ; this is a special case and could do with tidying up

    move.w d7,($ffff8a22).w             ; source y increment
    move.w d6,($ffff8a30).w             ; dest y increment
    move.w d4,($ffff8a36).w             ; xcount = number of 16 pixel blocks (once pass per bitplane)
    move.b d1,($ffff8a3d).w

    lea.l rightendmasks(pc),a3
    add.l d0,d0                         ; byte offset in mask lookup table
    move.w (a3,d0.w),d1
    move.w d1,($ffff8a28).w             ; endmask1
    bra.s blitterstart_3bpp

nofxsr_3bpp:
    move.w d7,($ffff8a22).w             ; source y increment
    move.w d6,($ffff8a30).w             ; dest y increment
    move.w d4,($ffff8a36).w             ; xcount = number of 16 pixel blocks (once pass per bitplane)
    move.b d1,($ffff8a3d).w

    add.l d0,d0                         ; byte offset in mask lookup table
    move.w #-1,($ffff8a2a).w            ; endmask2

    move.w leftclipped(pc),d1
    bne.s nocalcendmask1_3bpp                ; branch if zero flag not set

    lea.l leftendmasks(pc),a3
    move.w (a3,d0.w),d1

nocalcendmask1_3bpp:
    move.w d1,($ffff8a28).w             ; endmask1

    move.w rightclipped(pc),d1
    bne.s nocalcendmask3_3bpp                ; branch if zero flag not set

    lea.l rightendmasks(pc),a3
    move.w (a3,d0.w),d1

nocalcendmask3_3bpp:
    move.w d1,($ffff8a2c).w            ; endmask3

    ; we are now free to use d0, d6 and d4 for our own purposes
    ; looks like d0, d1 and d2 are also available to us

blitterstart_3bpp:
    move.w #802,d1                      ; size of unrolled blitter calling table plus 2
    lsl.w #2,d3                         ; one entry in the table is 4 bytes
    sub.w d3,d1                         ; generate value to be placed within modified bra instruction
    move.w d1,2+drawsceneryplane_jsr    ; jump address in unrolled blitter calling table
    moveq.l #1,d1                       ; ycount
    move.b #$c0,d6                      ; blitter start instruction

    rept 3
    jsr drawsceneryplane
    addq.l #2,a1                        ; move to next bitplane
    endr
    jsr drawsceneryplane

    subq.l #6,a1                        ; move destination back to initial bitplane
    move.w #$0207,($ffff8a3a).w         ; hop/op: read from source, source | destination

    rept 2
    addq.l #2,a0                        ; move source to next bitplane
    jsr drawsceneryplane
    addq.l #2,a1                        ; move destination to next bitplane
    endr
    addq.l #2,a0                        ; move source to next bitplane
    jsr drawsceneryplane

    movem.l (a7)+,a2-a6

    rts

leftendmasks:

    dc.w %1111111111111111
    dc.w %0111111111111111
    dc.w %0011111111111111
    dc.w %0001111111111111
    dc.w %0000111111111111
    dc.w %0000011111111111
    dc.w %0000001111111111
    dc.w %0000000111111111
    dc.w %0000000011111111
    dc.w %0000000001111111
    dc.w %0000000000111111
    dc.w %0000000000011111
    dc.w %0000000000001111
    dc.w %0000000000000111
    dc.w %0000000000000011
    dc.w %0000000000000001

rightendmasks:

    dc.w %1111111111111111
    dc.w %1000000000000000
    dc.w %1100000000000000
    dc.w %1110000000000000
    dc.w %1111000000000000
    dc.w %1111100000000000
    dc.w %1111110000000000
    dc.w %1111111000000000
    dc.w %1111111100000000
    dc.w %1111111110000000
    dc.w %1111111111000000
    dc.w %1111111111100000
    dc.w %1111111111110000
    dc.w %1111111111111000
    dc.w %1111111111111100
    dc.w %1111111111111110


