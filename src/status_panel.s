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
    move.w #0,(a5)+          ; source y increment 8a22
    move.l a5,a6             ; back up source address 8a24
    addq.l #4,a5
    moveq.l #-1,d2
    move.w d2,(a5)+         ; endmask1 8a28
    move.w d2,(a5)+         ; endmask2 8a2a
    move.w d2,(a5)+         ; endmask2 8a2c
    moveq.l #1,d2
    move.w #8,(a5)+          ; dest x increment 8a2e
    move.w #152-16,(a5)+     ; dest y increment 8a30
    move.l a5,a2             ; backup destination address 8a32
    addq.l #4,a5
    move.w #4,(a5)+          ; xcount 8a36
    move.l a5,a4             ; a4 is now address of ycount (8a38)
    addq.l #2,a5             ; proceed to hop/op 8a3a
    move.l a5,a3             ; copy hop/op 8a3a into a3 reg
    addq.l #2,a5             ; a5 is now blitter control 8a3c
    move.w #$c080,d3

status_panel_line:
    ; first pass
    status_panel_cpu_blit

    adda.w    #$80,a1

    ; this shouldn't be necessary - understand why
    suba.w    #$8,a0

    ; transfer a0 to blitter source
    ; transfer a1 to blitter destination

    ;move.l a0,($ffff8a24).w
    ;move.l a1,($ffff8a32).w

    ; BLITTER START HERE
    ; approx $5f lines

    ; set source & destination
    move.w #$0201,(a3) ; source & destination

    rept 3
    jsr drawstatusplane
    addq.l #2,a1                        ; move to next bitplane
    endr
    jsr drawstatusplane

    subq.l #6,a1                        ; move destination back to initial bitplane
    move.w #$0207,(a3)         ; hop/op: read from source, source | destination

    rept 2
    addq.l #2,a0                        ; move source to next bitplane
    jsr drawstatusplane
    addq.l #2,a1                        ; move destination to next bitplane
    endr
    addq.l #2,a0                        ; move source to next bitplane
    jsr drawstatusplane

    adda.w    #$80,a1

    ; BLITTER END HERE

    ; transfer blitter source to a0
    ; transfer blitter destination to a1

    move.l ($ffff8a24).w,a0
    move.l ($ffff8a32).w,a1

    status_panel_cpu_blit
    status_panel_cpu_blit
    status_panel_cpu_blit
    ; final pass end
    rts

drawstatusplane:
    move.l a0,(a6)    ; source
    move.l a1,(a2)    ; destination

    ; might be able to exploit the fact that there are empty lines in the status display
    rept 92
    move.w d2,(a4)             ; ycount
    move.w d3,(a5)         ; control
    endr
    rts

