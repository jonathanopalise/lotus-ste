
    ORG $80000

leftclipped:

    dc.w 0

rightclipped:

    dc.w 0

initdrawroad:
    move.l #$ffff8a20,a5
    move.w d4,$76688
    move.w #8,(a5)+            ; source x increment 8a20
    move.w #-158,(a5)          ; source y increment 8a22
    addq.l #6,a5
    move.w #-1,(a5)+           ; endmask1 8a28
    move.w #-1,(a5)+           ; endmask2 8a2a
    move.w #-1,(a5)+           ; endmask3 8a2c
    move.w #8,(a5)+            ; dest x increment 8a2e
    move.w #-150,(a5)          ; dest y increment 8x30
    addq.l #6,a5
    move.w #20,(a5)           ; xcount 8a36
    addq.l #4,a5
    move.w #$0203,(a5)        ; hop/op 8a3a
    move.l #$ffff8a38,a5
    move.l #$ffff8a24,a3
    move.l #$ffff8a32,a2
    move.l #$ffff8a3c,a6
    moveq.l #7,d5
    lea.l byte_offsets,a0
    move.l a0,usp
    lea.l gfx_data,a0
    move.l a0,d6
    jmp $76672

drawscenery:

    ; draw a roadside object
    ; a0 is source address
    ; a1 is destination address
    ; d3 is the lines to be drawn
    ; d4 is number of 16 pixel blocks to be drawn (= 8 words)
    ; - so if d4 = 1, we want to draw 16 pixels = 4 words = 8 bytes
    ; d6 is destination bytes to skip after each line
    ; d7 is source bytes to skip after each line

    macro drawsceneryline
    inline
    move.w d3,d6
    sub.w #1,d3
    bmi.s .2
    move.l a0,(a4)             ; set source address
    move.l a1,(a5)             ; set destination
.1:
    move.w #1,(a2)             ; ycount
    move.b #$c0,(a6)
    ;add.l d7,a0 ; update source
    ;add.l d6,a1 ; update destination
    
    dbra d3,.1
    move.w d6,d3

    ;bset.b d2,(a6)             ; start
    ;bset.b d2,(a6)             ; start
    ;bne.s .1
.2:
    einline
    endm

    movem.l a2-a6,-(a7)
    move.l #$ffff8a38,a2
    move.l #$ffff8a24,a4
    move.l #$ffff8a32,a5
    move.l #$ffff8a3c,a6

    addq.l #8,d6                        ; convert to value suitable for blitter
    add.w #10,d7                        ; convert to value suitable for blitter

    move.w #10,($ffff8a20).w            ; source x increment
    move.w #8,($ffff8a2e).w             ; dest x increment
    move.w #$0201,($ffff8a3a).w         ; hop/op: read from source, source & destination

    move.l a3,d0                        ; get desired xpos of scenery object
    and.w #$f,d0                        ; convert to skew value for blitter
    move.w d0,d1
    beq.s nonfsr                        ; if skew is zero, we can't use nfsr

    cmp.w #0,rightclipped
    bne.s nonfsr

    add.w #10,d7
    or.b #$40,d1

nonfsr:

    cmp.w #0,leftclipped
    beq.s nofxsr

    sub.w #10,d7
    sub.w #10,a0
    or.b #$80,d1

    cmp.w #1,d4
    bne.s nofxsr 

    ; when words to draw = 4 and leftclipped != 0, we need to set endmask1 from rightendmasks
    ; In the case of a one word line ENDMASK 1 is used (http://www.atari-wiki.com/index.php/Blitter_manual)
    ; this is a special case and could do with tidying up

    move.w d7,($ffff8a22).w             ; source y increment
    move.w d6,($ffff8a30).w             ; dest y increment
    move.w d4,($ffff8a36).w             ; xcount = number of 16 pixel blocks (once pass per bitplane)
    move.b d1,($ffff8a3d).w

    lea.l rightendmasks,a3
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

    move.w leftclipped,d1
    bne.s nocalcendmask1                ; branch if zero flag not set

    lea.l leftendmasks,a3
    move.w (a3,d0.w),d1                 ; fetch value of endmask1

nocalcendmask1:
    move.w d1,($ffff8a28).w             ; endmask1

    move.w rightclipped,d1
    bne.s nocalcendmask3                ; branch if zero flag not set

    lea.l rightendmasks,a3
    move.w (a3,d0.w),d1

nocalcendmask3:
    move.w d1,($ffff8a2c).w            ; endmask3

    ; we are now free to use d0, d6 and d4 for our own purposes
    ; looks like d0, d1 and d2 are also available to us

blitterstart:
    move.b #$80,d0                      ; store blitter start instruction
    moveq.l #7,d2

    rept 3
    drawsceneryline
    addq.l #2,a1                        ; move to next bitplane
    endr
    drawsceneryline

    subq.l #6,a1                        ; move destination back to initial bitplane
    move.w #$0207,($ffff8a3a).w         ; hop/op: read from source, source | destination

    rept 3
    addq.l #2,a0                        ; move source to next bitplane
    drawsceneryline
    addq.l #2,a1                        ; move destination to next bitplane
    endr
    addq.l #2,a0                        ; move source to next bitplane
    drawsceneryline

    movem.l (a7)+,a2-a6

    rts

drawscenery_3bpp:

    movem.l a2-a6,-(a7)
    move.l #$ffff8a38,a2
    move.l #$ffff8a24,a4
    move.l #$ffff8a32,a5
    move.l #$ffff8a3c,a6

    moveq.l #8,d0
    add.l d0,d6                        ; convert to value suitable for blitter
    add.w d0,d7                        ; convert to value suitable for blitter

    move.w d0,($ffff8a20).w            ; source x increment
    move.w d0,($ffff8a2e).w             ; dest x increment
    move.w #$0201,($ffff8a3a).w         ; hop/op: read from source, source & destination

    move.l a3,d0                        ; get desired xpos of scenery object
    and.w #$f,d0                        ; convert to skew value for blitter
    ;move.l #0,d0
    move.w d0,d1
    beq.s nonfsr_3bpp                        ; if skew is zero, we can't use nfsr

    cmp.w #0,rightclipped
    bne.s nonfsr_3bpp

    add.w #8,d7
    or.b #$40,d1

nonfsr_3bpp:
    move.w d7,($ffff8a22).w             ; source y increment
    move.w d6,($ffff8a30).w             ; dest y increment
    move.w d4,($ffff8a36).w             ; xcount = number of 16 pixel blocks (once pass per bitplane)
    move.b d1,($ffff8a3d).w

    add.l d0,d0                         ; byte offset in mask lookup table
    move.w #-1,($ffff8a2a).w            ; endmask2

    move.w leftclipped,d1
    bne.s nocalcendmask1_3bpp                ; branch if zero flag not set

    lea.l leftendmasks,a3
    move.w (a3,d0.w),d1

nocalcendmask1_3bpp:
    move.w d1,($ffff8a28).w             ; endmask1

    move.w rightclipped,d1
    bne.s nocalcendmask3_3bpp                ; branch if zero flag not set

    lea.l rightendmasks,a3
    move.w (a3,d0.w),d1

nocalcendmask3_3bpp:
    move.w d1,($ffff8a2c).w            ; endmask3

    ; we are now free to use d0, d6 and d4 for our own purposes
    ; looks like d0, d1 and d2 are also available to us

    move.b #$80,d0                      ; store blitter start instruction
    moveq.l #7,d2

    rept 3
    drawsceneryline
    addq.l #2,a1                        ; move to next bitplane
    endr
    drawsceneryline

    subq.l #6,a1                        ; move destination back to initial bitplane
    move.w #$0207,($ffff8a3a).w         ; hop/op: read from source, source | destination

    rept 2
    addq.l #2,a0                        ; move source to next bitplane
    drawsceneryline
    addq.l #2,a1                        ; move destination to next bitplane
    endr
    addq.l #2,a0                        ; move source to next bitplane
    drawsceneryline

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

newtimerbtop1:
		move.w	#$DBA,$FFFF825E.w
		move.b	#$00,$FFFFFA1B.w
		move.b	#$04,$FFFFFA21.w
		move.b	#$08,$FFFFFA1B.w
		move.l	#newtimerbtop2,$120.w
		bclr	#$00,$FFFFFA0F.W
	rte

newtimerbtop2:
		move.w	#$6BA,$FFFF825E.w
		move.l	#newtimerbtop3,$120.w
		bclr	#$00,$FFFFFA0F.W
	rte

newtimerbtop3:
		move.w	#$EBA,$FFFF825E.w
		move.l	#newtimerbtop4,$120.w
		bclr	#$00,$FFFFFA0F.W
	rte

newtimerbtop4:
		move.w	#$7BA,$FFFF825E.w
		move.l	#newtimerbtop5,$120.w
		bclr	#$00,$FFFFFA0F.W
	rte

newtimerbtop5:
		move.w	#$FBA,$FFFF825E.w
		move.l	#newtimerbtop6,$120.w
		bclr	#$00,$FFFFFA0F.W
	rte

newtimerbtop6:
		move.w	#$F43,$FFFF825E.w
		move.b	#$00,$FFFFFA1B.w
		move.b	#$08+7,$FFFFFA21.w
		move.b	#$08,$FFFFFA1B.w
		move.l	#$00070684,$120.w
		bclr	#$00,$FFFFFA0F.W
	rte

map_palette_data:

    move.w d0,d1
    andi.w #$eee,d0
    lsr.w  #1,d0
    andi.w #$111,d1
    lsl.w  #3,d1
    or.w d1,d0
    move.w d0,(a1)+
    rts

    align 2

    include "road.s"

