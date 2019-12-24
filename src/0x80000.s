
    ORG $80000

    bra drawroad
    align 2                            ; jmp instructions must be at 4 byte intervals regardless of their length
    bra drawscenery

drawroad:

    movem.l d0-d4/a0-a2,-(a7)

    moveq.l #-1,d3

    ; optimize blitter code: http://atari-forum.com/viewtopic.php?f=68&t=2804

    move.w #8,($ffff8a20).w            ; source x increment
    move.w #-158,($ffff8a22).w         ; source y increment
    move.w d3,($ffff8a28).w            ; endmask1
    move.w d3,($ffff8a2a).w            ; endmask2
    move.w d3,($ffff8a2c).w            ; endmask3
    move.w #8,($ffff8a2e).w            ; dest x increment
    move.w #-150,($ffff8a30).w         ; dest y increment
    move.w #$0203,($ffff8a3a).w        ; hop/op
    move.w #20,($ffff8a36).w           ; xcount
    move.w #4,($ffff8a38).w            ; ycount

    lsr.l #4,d0                        ; bring the road width value into a 0-255 range
    and.l #$ff,d0                      ; bring the road width value into a 0-255 range
    add.l d0,d0 
    add.l d0,d0                        ; bring the road width value into a 0-1023 range with increments of 4

	lsr.w #5,d2                        ; d2 should contain something telling us about the road position of current line
	andi.w #$20,d2
    tst.w d2
    beq.s skipoffsetadd 
    add.l #1024,d0

skipoffsetadd:

    move.l #byte_offsets,a0
    add d0,a0                          ; d0 is the offset to the pointer to the road width segment we want
    move.l (a0),a0                     ; a0 now contains the pointer to the road graphics data offset for the current line
    move.l #gfx_data,a2
    add.l a2,a0                        ; a0 now contains memory location of central source

    ext.l d1                           ; d1 is the shift value for the current line
    move.l d1,d4                       ; copy to d4
    and.b #15,d4                       ; convert to skew value
    asr.w #1,d1
    and.b #$f8,d1
    sub.l d1,a0                        ; d1 now contains adjusted source

    move.l a0,($ffff8a24).w            ; set source address
    move.l a1,($ffff8a32).w            ; set destination

    ; to generate the start offset, we need the value in d1 at pc = 0x76690

    or.w #$c080,d4
    move.w d4,($ffff8a3c).w

    movem.l (a7)+,d0-d4/a0-a2

    add.l #160,a1
    jmp $767bc

drawscenery:

    ; draw a roadside object
    ; a0 is source address
    ; a1 is destination address
    ; d3 is the lines to be drawn
    ; d4 is number of 16 pixel blocks to be drawn (= 8 words)
    ; - so if d4 = 1, we want to draw 16 pixels = 4 words = 8 bytes
    ; d6 is destination bytes to skip after each line
    ; d7 is source bytes to skip after each line

    addq.l #8,d6                        ; convert to value suitable for blitter
    add.w #10,d7                        ; convert to value suitable for blitter

    move.w #-1,($ffff8a28).w            ; endmask1
    move.w #-1,($ffff8a2a).w            ; endmask2
    move.w #-1,($ffff8a2c).w            ; endmask3

    move.w #10,($ffff8a20).w            ; source x increment
    move.w d7,($ffff8a22).w             ; source y increment
    move.w #8,($ffff8a2e).w             ; dest x increment
    move.w d6,($ffff8a30).w             ; dest y increment
    move.w d4,($ffff8a36).w             ; xcount = number of 16 pixel blocks (once pass per bitplane)
    move.w #$0201,($ffff8a3a).w         ; hop/op: read from source, source & destination

    move.l a3,d7                        ; get desired xpos of scenery object
    and.l #$f,d7                        ; convert to skew value for blitter
    move.b d7,($ffff8a3d).w

    ; we are now free to use d7, d6 and d4 for our own purposes
    ; looks like d0, d1 and d2 are also available to us

    move.b #$c0,d7                      ; store blitter start instruction

    rept 3

    move.w d3,($ffff8a38).w             ; ycount
    move.l a0,($ffff8a24).w             ; set source address
    move.l a1,($ffff8a32).w             ; set destination
    move.b d7,($ffff8a3c).w             ; start

    addq.l #2,a1                        ; move to next bitplane

    endr

    ; fourth pass of mask doesn't need the addq at the end
    move.w d3,($ffff8a38).w             ; ycount
    move.l a0,($ffff8a24).w             ; set source address
    move.l a1,($ffff8a32).w             ; set destination
    move.b d7,($ffff8a3c).w             ; start

    subq.l #6,a1
    move.w #$0207,($ffff8a3a).w         ; hop/op: read from source, source | destination

    rept 4

    addq.l #2,a0

    move.w d3,($ffff8a38).w             ; ycount
    move.l a0,($ffff8a24).w             ; set source address
    move.l a1,($ffff8a32).w             ; set destination
    move.b d7,($ffff8a3c).w             ; start

    addq.l #2,a1

    endr

    rts

    align 2

    include "road.s"
