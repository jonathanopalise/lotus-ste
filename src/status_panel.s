    macro status_panel_cpu_blit
    move.w    (a0)+,d0       ; load something into d0
    move.w    d0,d1          ; copy something into d1
    swap      d0             ; swap d0
    move.w    d1,d0          ; low word and high word of d0 now contain the same
    and.l     d0,(a1)        ; apply mask to two consecutive words
    move.l    (a0)+,d1       ; get next value from source data
    or.l      d1,(a1)+
    and.l     d0,(a1)+       ; write mask to positions 4 and 6
    move.w    (a0)+,d1       ; get another value from source data
    or.w      d1,-4(a1)
    endm

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
    moveq.l #5,d2
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
    ; this shouldn't be necessary - understand why
    move.l a0,-(sp)
    move.l a1,-(sp)

    suba.w    #$8,a0
    bsr draw_lap_block

status_panel:
    move.l (sp)+,a1
    move.l (sp)+,a0

    add.l #17*8,a1
    move.w #8,($ffff8a22).w   ; source y increment
    move.w #3,($ffff8a36).w   ; x count
    move.w #144,($ffff8a30).w ; dest y increment

    bsr draw_status_block

    rts

draw_lap_block:
    move.w #$0201,(a3) ; source & destination

    rept 3
    bsr draw_lap_plane
    addq.l #2,a1                        ; move to next bitplane
    endr
    bsr draw_lap_plane

    subq.l #6,a1                        ; move destination back to initial bitplane
    move.w #$0207,(a3)         ; hop/op: read from source, source | destination

    rept 2
    addq.l #2,a0                        ; move source to next bitplane
    bsr draw_lap_plane
    addq.l #2,a1                        ; move destination to next bitplane
    endr
    addq.l #2,a0                        ; move source to next bitplane
    bsr draw_lap_plane

draw_lap_plane:
    move.l a0,(a6)    ; source
    move.l a1,(a2)    ; destination

    ; might be able to exploit the fact that there are empty lines in the lap display
    rept 19
    move.w d2,(a4)             ; ycount
    move.w d3,(a5)         ; control
    endr
    rts

draw_status_block:
    move.w #$0201,(a3) ; source & destination

    rept 3
    bsr draw_status_plane
    addq.l #2,a1                        ; move to next bitplane
    endr
    bsr draw_status_plane

    subq.l #6,a1                        ; move destination back to initial bitplane
    move.w #$0207,(a3)         ; hop/op: read from source, source | destination

    rept 2
    addq.l #2,a0                        ; move source to next bitplane
    bsr draw_status_plane
    addq.l #2,a1                        ; move destination to next bitplane
    endr
    addq.l #2,a0                        ; move source to next bitplane
    bsr draw_status_plane

draw_status_plane:
    move.l a0,(a6)    ; source
    move.l a1,(a2)    ; destination

    ; might be able to exploit the fact that there are empty lines in the status display
    rept 19
    move.w d2,(a4)             ; ycount
    move.w d3,(a5)         ; control
    endr
    rts

