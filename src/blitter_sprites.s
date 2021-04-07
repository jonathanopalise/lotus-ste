leftclipped:
    dc.w 0

rightclipped:
    dc.w 0

sprite_jump_table:
    dc.l 0 ; should never be used
    dc.l draw_eight_line_chunks    ; 16 wide
    dc.l draw_four_line_chunks    ; 32 wide
    dc.l draw_two_line_chunks    ; 48 wide

drawscenery_3bpp:
    moveq.l #8,d5
    bra.s drawscenery

drawscenery_4bpp:
    moveq.l #10,d5

drawscenery:

    ; draw a roadside object
    ; a0 is source address
    ; a1 is destination address
    ; d3 is the lines to be drawn
    ; d4 is number of 16 pixel blocks to be drawn (= 8 words)
    ; - so if d4 = 1, we want to draw 16 pixels = 4 words = 8 bytes
    ; d6 is destination bytes to skip after each line
    ; d7 is source bytes to skip after each line

    lea $ffff8a38.w,a2
    lea $ffff8a24.w,a4
    lea $ffff8a32.w,a5
    lea $ffff8a3c.w,a6

    addq.l #8,d6               ; convert to value suitable for blitter
    add.w d5,d7               ; convert to value suitable for blitter | TODO: #10 for 4bpp and #8 for 3bpp

    move.w d5,($ffff8a20).w   ; source x increment | TODO: #10 for 4bpp and #8 for 3bpp
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

    add.w d5,d7               ; TODO: #10 for 4bpp, #8 for 3bpp
    or.b #$40,d1

nonfsr:

    tst.w leftclipped
    beq.s nofxsr

    sub.w d5,d7     ; TODO: #10 for 4bpp, #8 for 3bpp
    sub.l d5,a0

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

    cmp.w #3,d4
    bgt draw_one_line_chunks

    lea sprite_jump_table(pc),a3
    move.w d4,d2
    add.w d2,d2
    add.w d2,d2
    move.l (a3,d2.w),a3
    jmp (a3)

;draw_all:
;    move.w #798,2+drawsceneryplane_jsr    ; jump address in unrolled blitter calling table
;    move.w d3,finalblit+2                 ; ycount
;    bra.s draw_now

draw_eight_line_chunks:
    lea eight_line_chunks_lookup(pc),a3
    move.w d3,d2
    and.w #7,d2
    move.b (a3,d2.w),d2
    move.w d2,finalblit+2

    move.w #798,d1
    subq.w #1,d3
    and.w #$f8,d3
    lsr.w #1,d3
    sub.w d3,d1
    move.w d1,2+drawsceneryplane_jsr    ; jump address in unrolled blitter calling table
    moveq.l #8,d1                       ; ycount
    bra.s draw_now

eight_line_chunks_lookup:
    dc.b 8
    dc.b 1
    dc.b 2
    dc.b 3
    dc.b 4
    dc.b 5
    dc.b 6
    dc.b 7

draw_four_line_chunks:
    lea four_line_chunks_lookup(pc),a3
    move.w d3,d2
    and.w #3,d2
    move.b (a3,d2.w),d2
    move.w d2,finalblit+2

    move.w #798,d1
    subq.w #1,d3
    and.w #$fc,d3
    sub.w d3,d1
    move.w d1,2+drawsceneryplane_jsr    ; jump address in unrolled blitter calling table
    moveq.l #4,d1                       ; ycount
    bra.s draw_now

four_line_chunks_lookup:
    dc.b 4
    dc.b 1
    dc.b 2
    dc.b 3

draw_two_line_chunks:
    lea two_line_chunks_lookup(pc),a3
    move.w d3,d2
    and.w #1,d2
    move.b (a3,d2.w),d2
    move.w d2,finalblit+2

    move.w #798,d1
    subq.w #1,d3
    and.w #$fe,d3
    add.w d3,d3
    sub.w d3,d1
    move.w d1,2+drawsceneryplane_jsr    ; jump address in unrolled blitter calling table
    moveq.l #2,d1                       ; ycount
    bra.s draw_now

two_line_chunks_lookup:
    dc.b 2
    dc.b 1

draw_one_line_chunks:
    move.w #802,d1                      ; size of unrolled blitter calling table plus 2
    lsl.w #2,d3                         ; one entry in the table is 4 bytes
    sub.w d3,d1                         ; generate value to be placed within modified bra instruction
    move.w d1,2+drawsceneryplane_jsr    ; jump address in unrolled blitter calling table
    moveq.l #1,d1                       ; ycount
    move.w d1,finalblit+2

draw_now:
    move.b #$c0,d6                      ; blitter start instruction

    rept 3
    bsr.s drawsceneryplane
    addq.l #2,a1                        ; move to next bitplane
    endr
    bsr.s drawsceneryplane

    subq.l #6,a1                        ; move destination back to initial bitplane
    move.w #$0207,($ffff8a3a).w         ; hop/op: read from source, source | destination

    addq.l #2,a0                        ; move source to next bitplane
    bsr.s drawsceneryplane
    addq.l #2,a1                        ; move destination to next bitplane
    addq.l #2,a0                        ; move source to next bitplane
    bsr.s drawsceneryplane
    addq.l #2,a1                        ; move destination to next bitplane
    addq.l #2,a0                        ; move source to next bitplane
    bsr.s drawsceneryplane

    cmp.w #10,d5
    bne.s alldone

    ; stop here if 3bpp
    addq.l #2,a1                        ; move destination to next bitplane
    addq.l #2,a0                        ; move source to next bitplane
    bsr drawsceneryplane

alldone:
    rts

drawsceneryplane:
    move.l a0,(a4)             ; set source address
    move.l a1,(a5)             ; set destination

drawsceneryplane_jsr:
    bra drawsceneryplane_aft
    rept 199
    move.w d1,(a2)             ; ycount
    move.b d6,(a6)
    endr
finalblit:
    move.w #1,(a2)
    move.b d6,(a6)
drawsceneryplane_aft:
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


