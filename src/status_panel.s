render_status_panel:
    lea $ffff8a20.w,a5       ; source x increment 8a20
    move.w #8,(a5)+          ; source x increment 8a20
    move.w #24,(a5)+          ; source y increment 8a22
    move.l a5,a6             ; back up source address 8a24
    addq.l #4,a5
    moveq.l #-1,d2
    move.w d2,(a5)+         ; endmask1 8a28
    move.w d2,(a5)+         ; endmask2 8a2a
    move.w d2,(a5)+         ; endmask2 8a2c
    move.w #8,(a5)+          ; dest x increment 8a2e
    move.w #160,(a5)+        ; dest y increment 8a30
    move.l a5,a2             ; backup destination address 8a32
    addq.l #4,a5
    move.w #1,(a5)+          ; xcount 8a36
    move.l a5,a4             ; a4 is now address of ycount (8a38)
    addq.l #2,a5             ; proceed to hop/op 8a3a
    move.l a5,a3             ; copy hop/op 8a3a into a3 reg
    addq.l #2,a5             ; a5 is now blitter control 8a3c
    move.w #$c080,d3

lap_counter:
    move.l a0,-(sp)
    move.l a1,-(sp)

    subq.l    #$8,a0
    moveq.l #5,d2             ; 5 rows at a time for lap counter
    bsr draw_lap_block

status_panel:
    move.l (sp)+,a1
    move.l (sp)+,a0

    add.l #17*8,a1
    move.w #8,($ffff8a22).w   ; source y increment
    move.w #3,($ffff8a36).w   ; x count
    move.w #144,($ffff8a30).w ; dest y increment
    moveq.l #3,d2             ; ycount - 2 rows at a time for status panel

    lea 32*2(a0),a0
    lea 160*2(a1),a1

    bsr draw_grey_7_row_block

    lea 32*8(a0),a0
    lea 160*8(a1),a1

    bsr draw_white_7_row_block

    lea 32*8(a0),a0
    lea 160*8(a1),a1

    bsr draw_grey_7_row_block

    lea 32*8(a0),a0
    lea 160*8(a1),a1

    bsr draw_white_7_row_block

    lea 32*9(a0),a0
    lea 160*9(a1),a1

    bsr draw_grey_7_row_block

    lea 32*8(a0),a0
    lea 160*8(a1),a1

    bsr draw_metre_block

    lea 32*6(a0),a0
    lea 160*6(a1),a1

    bsr draw_grey_7_row_block

    lea 32*8(a0),a0
    lea 160*8(a1),a1

    bsr draw_metre_block

    lea 32*6(a0),a0
    lea 160*6(a1),a1

    bsr draw_grey_7_row_block

    lea 32*9(a0),a0
    lea 160*9(a1),a1

    bsr draw_position_block

    rts

draw_lap_block:
    move.w #$0201,(a3) ; source & destination

    rept 3
    bsr draw_lap_plane
    addq.l #2,a1                        ; move to next bitplane
    endr
    bsr draw_lap_plane

    subq.l #4,a1                        ; move destination back to initial bitplane
    move.w #$0207,(a3)         ; hop/op: read from source, source | destination

    addq.l #4,a0                        ; move source to next bitplane
    bsr draw_lap_plane
    rts

draw_lap_plane:
    move.l a0,(a6)    ; source
    move.l a1,(a2)    ; destination

    rept 19
    move.w d2,(a4)             ; ycount
    move.w d3,(a5)         ; control
    endr
    rts

draw_position_block:
    move.w #$0201,(a3) ; source & destination
    moveq.l #2,d2

    bsr draw_position_and_plane
    addq.l #2,a1                        ; move to next bitplane
    bsr draw_position_and_plane
    addq.l #2,a1                        ; move to next bitplane
    bsr draw_position_and_plane
    addq.l #2,a1                        ; move to next bitplane
    bsr draw_position_and_plane

    move.w #$0207,(a3)         ; hop/op: read from source, source | destination
    moveq.l #5,d2

    lea 156(a1),a1
    lea 36(a0),a0
    bsr draw_position_or_plane
    addq.l #2,a1                        ; move destination to next bitplane
    addq.l #2,a0                        ; move source to next bitplane
    bsr draw_position_or_plane
    lea -160(a1),a1
    lea -32(a0),a0
    rts

draw_position_and_plane:
    move.l a0,(a6)    ; source
    move.l a1,(a2)    ; destination

    rept 11
    move.w d2,(a4)             ; ycount
    move.w d3,(a5)         ; control
    endr
    rts

draw_position_or_plane:
    move.l a0,(a6)    ; source
    move.l a1,(a2)    ; destination

    rept 4
    move.w d2,(a4)             ; ycount
    move.w d3,(a5)         ; control
    endr
    rts

draw_grey_7_row_block:
    move.w #$0201,(a3) ; source & destination

    rept 3
    bsr draw_7_row_and_plane
    addq.l #2,a1                        ; move to next bitplane
    endr
    bsr draw_7_row_and_plane

    move.w #$0207,(a3)         ; hop/op: read from source, source | destination

    lea 154(a1),a1
    lea 34(a0),a0

    bsr draw_5_row_or_plane
    addq.l #4,a1                        ; move destination to next bitplane
    addq.l #4,a0                        ; move source to next bitplane
    bsr draw_5_row_or_plane

    lea -164(a1),a1
    lea -38(a0),a0

    ; a1 is +4 at this point
    ; a0 is +4 at this point
    rts

draw_white_7_row_block:
    move.w #$0201,(a3) ; source & destination

    rept 3
    bsr draw_7_row_and_plane
    addq.l #2,a1                        ; move to next bitplane
    endr
    bsr draw_7_row_and_plane

    move.w #$0207,(a3)         ; hop/op: read from source, source | destination

    lea 156(a1),a1
    lea 36(a0),a0

    bsr draw_5_row_or_plane
    addq.l #2,a1                        ; move destination to next bitplane
    addq.l #2,a0                        ; move source to next bitplane
    bsr draw_5_row_or_plane

    lea -(160+4)(a1),a1
    lea -(32+6)(a0),a0
    rts

draw_metre_block:
    move.w #$0201,(a3) ; source & destination

    rept 3
    bsr draw_5_row_and_plane
    addq.l #2,a1                        ; move to next bitplane
    endr
    bsr draw_5_row_and_plane

    subq.l #6,a1                        ; move destination back to initial bitplane
    move.w #$0207,(a3)         ; hop/op: read from source, source | destination

    lea 160(a1),a1
    lea 32(a0),a0

    addq.l #2,a0                        ; move source to next bitplane
    bsr draw_3_row_or_plane
    addq.l #2,a1                        ; move destination to next bitplane
    addq.l #2,a0                        ; move source to next bitplane
    bsr draw_3_row_or_plane
    addq.l #2,a1                        ; move destination to next bitplane
    addq.l #2,a0                        ; move source to next bitplane
    bsr draw_3_row_or_plane

    lea -160(a1),a1
    lea -32(a0),a0

    ; a1 is +4 at this point
    ; a0 is +4 at this point
    subq.l #6,a0
    subq.l #4,a1
    rts

draw_3_row_or_plane:
    move.l a0,(a6)    ; source
    move.l a1,(a2)    ; destination

    move.w #3,(a4)             ; ycount
    move.w d3,(a5)         ; control
    rts

draw_5_row_and_plane:
    move.l a0,(a6)    ; source
    move.l a1,(a2)    ; destination

    move.w #5,(a4)             ; ycount
    move.w d3,(a5)         ; control
    rts

draw_5_row_or_plane:
    move.l a0,(a6)    ; source
    move.l a1,(a2)    ; destination

    move.w #5,(a4)             ; ycount
    move.w d3,(a5)         ; control
    rts

draw_7_row_and_plane:
    move.l a0,(a6)    ; source
    move.l a1,(a2)    ; destination

    move.w #3,(a4)             ; ycount
    move.w d3,(a5)         ; control
    move.w #4,(a4)             ; ycount
    move.w d3,(a5)         ; control
    rts


