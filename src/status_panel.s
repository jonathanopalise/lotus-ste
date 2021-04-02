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

    macro status_panel_blitter_blit
    endm

render_status_panel:
    lea $ffff8a20.w,a5       ; source x increment 8a20
    move.w #8,(a5)+          ; source x increment 8a20
    move.w #-6,(a5)+       ; source y increment 8a22
    ;move.l a5,a6             ; back up source address 8a24
    lea 10(a5),a5
    move.w #8,(a5)+          ; dest x increment 8a2e
    move.w #152-16,(a5)+       ; dest y increment 8a30
    move.l a5,a2             ; backup destination address 8a32
    addq.l #4,a5
    move.w #4,(a5)+         ; xcount 8a36
    move.l a5,a4             ; a4 is now address of ycount (8a38)
    addq.l #2,a5             ; a3 is now address of hop/op (8a3a)
    move.w #$f,(a5)+         ; hop/op 8a3a, advance a3 to linenum 8a3c
    ; a5 is now 8a3c

status_panel_line:
    ; first pass
    status_panel_cpu_blit

    adda.w    #$80,a1

    ; transfer a0 to blitter source
    ; transfer a1 to blitter destination

    ;move.l a0,($ffff8a24).w
    ;move.l a1,($ffff8a32).w

    ; BLITTER START HERE
    ; approx $5f lines

    ; set source & destination
    move.w #$0201,($ffff8a3a).w ; source & destination

    rept 3
    jsr drawstatusplane
    addq.l #2,a1                        ; move to next bitplane
    endr
    jsr drawstatusplane

    subq.l #6,a1                        ; move destination back to initial bitplane
    move.w #$0207,($ffff8a3a).w         ; hop/op: read from source, source | destination

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
    move.l a0,($ffff8a24).w    ; source
    move.l a1,($ffff8a32).w    ; destination

    rept 20
    move.w #1,($ffff8a38).w             ; ycount
    move.w #$c080,($ffff8a3c).w         ; control
    endr
    rts

