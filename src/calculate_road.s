calculate_road: ; replacement for 78f3a
    lea       $2b880,a3
    lea       ascnlinedists,a1
    move.w    $7c5b6,d0
    move.l    $7c596,d4
    bra.s     label_78f6c
    lea       $2b880,a3
    lea       $2b640,a1
    move.w    $7c66c,d0
    move.l    $7c64c,d4
label_78f6c:
    move.w    d0,d7
    move.w    d7,d6
    add.w     d6,d6
    subq.w    #2,d7
    asl.w     #8,d7
    lea       $30e40,a0
    adda.w    d6,a0
    add.w     d6,d6
    add.w     d6,d6
    adda.w    d6,a3
    lea       $2fd40,a2
    subq.w    #4,a3
    move.w    -(a3),d1
    subq.w    #6,a3
    move.w    -(a0),d0
    move.w    d1,d3
    add.w     d3,d3
    add.w     d1,d3
    add.w     d3,d3
    adda.w    d3,a1
    move.w    #$ffff,d6
label_78fa0:
    move.w    -(a3),d5
    move.w    -(a3),d2
    subq.w    #4,a3
    move.w    -(a0),d4
    cmp.w     d5,d1
    bne.s     label_78fb2
    move.w    d4,d0
    bra       label_79020
label_78fb2:
    sub.w     d5,d1
    cmp.w     d6,d1
    beq.s     label_79016
    bmi.s     label_78fca
    add.w     d1,d1
    suba.w    d1,a1
    add.w     d1,d1
    suba.w    d1,a1
    move.w    d4,d0
    move.w    d5,d1
    bra       label_79020
label_78fca:
    neg.w     d1
    ext.l     d0
    move.w    d1,d3
    add.w     d3,d3
    add.w     d3,d3
    move.l    $40(a2,d3.w),d3
    asl.l     #4,d3
    swap      d3
    movea.w   d3,a4
    move.w    d4,d3
    sub.w     d0,d3
    andi.w    #$fff0,d3
    add.w     d1,d3
    add.w     d3,d3
    add.w     d3,d3
    move.l    (a2,d3.w),d3
    subq.w    #2,d1
label_78ff2:
    move.w    d2,(a1)+
    move.w    d0,(a1)+
    move.w    d7,(a1)+
    sub.w     a4,d7
    swap      d0
    add.l     d3,d0
    swap      d0
    dbra      d1,label_78ff2
    move.w    d2,(a1)+
    move.w    d0,(a1)+
    move.w    d7,(a1)+
    sub.w     a4,d7
    andi.w    #$ff00,d7
    addi.w    #$100,d7
    bra.s     label_7901c
label_79016:
    move.w    d2,(a1)+
    move.w    d0,(a1)+
    move.w    d7,(a1)+
label_7901c:
    move.w    d4,d0
    move.w    d5,d1
label_79020:
    subi.w    #$100,d7
    bpl       label_78fa0
    rts 
