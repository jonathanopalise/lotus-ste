    ORG $793fc

    subq.w #1,d7             ; from original code
    moveq.l #1,d1            ; ycount value
    ;move.b #$c0,d2           ; linenum value
    lea $ffff8a2e.w,a0       ; dest x increment address
    move.w #-2,(a0)+         ; dest x increment 8a2e
    clr.w (a0)+              ; dest y increment 8a30
    move.l a0,a2             ; backup destination address 8a32
    move.l a4,(a0)+      ; destination 8a32
    move.w #80,(a0)+         ; xcount 8a36
    move.l a0,a1             ; a1 is now address of ycount (8a38)
    addq.l #2,a0             ; a0 is now address of hop/op (8a3a)
    move.w #$f,(a0)+         ; hop/op 8a3a, advance a0 to linenum 8a3c

    ; a0 is now 8a3c (linenum)

line:
    move.w d1,(a1)           ; ycount = 1
    ;move.b d2,(a0)           ; linenum = 0xc0
    move.b #$c0,(a0)
    dbra d7,line
    move.l (a2),a4

