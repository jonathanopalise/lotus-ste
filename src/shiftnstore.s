    macro getcourse
    adda.w	#16,a0
	move.b	-11(a0),d4	;-8 to +8
	ext.w	d4
	move.b	-10(a0),d5	;-8 to +8 
	ext.w	d5
	add.w	d5,d5
    endm

    macro storeshdata
    add.w     d4,d0
    sub.w     d5,d1
    add.w     d0,d2
    add.w     d1,d3
    move.w    d2,d6
    andi.w    #$fffc,d6
    or.b      (a0),d6
    andi.w    #$fffd,d6
    move.w    d6,(a2)+
    move.w    d3,d6
    muls.w    (a3)+,d6
    swap      d6
    add.w     (a4)+,d6
    move.w    d6,(a2)+
    cmp.w     #$60,d6
    endm

ashiftnstore:
    move.l    $7c596,d0
    lea       $2b880,a2
    bsr.s     shiftnstore
    move.w    d0,$7c5b6
    move.w    d1,$7c5a0
    rts

bshiftnstore: 
    move.l    $7c64c,d0
    lea       $2b880,a2
    bsr.s     shiftnstore
    move.w    d0,$7c66c
    move.w    d1,$7c656
    rts       

shiftnstore:
    movea.l   a2,a1
    lea       $30d40,a4 ; distscnlinebase = 30d40
    lea       $30e40,a3 ; distbasewidths = 30e40
    move.w    d0,d1
    rol.w     #4,d1
    andi.w    #$f,d1
    moveq     #$f,d6
    sub.w     d1,d6
    move.w    d6,value1+2 ; "value1 + 2?"
    move.w    d1,d6
    addq.w    #1,d6
    move.w    d6,value2+2 ; "value2 + 2?"
    swap      d0
    ext.l     d0
    divu.w    $7ca9a,d0 ; $7ca9a = tracklength
    swap      d0
    asl.w     #4,d0
    lea       $3113b,a0 ; $3113b = "courseall - 5"
    adda.w    d0,a0
    moveq     #0,d0  ;cumulative dir l/r init val depends on how much car has gone off line with track
    moveq     #0,d1  ;cumulative dir u/d
    moveq     #0,d2  ;cumulative offset l/r
    moveq     #0,d3  ;cumulative offset u/d
    moveq     #96,d7 ;NOTE: 96

    getcourse ; macro

value1:
    move.w    #$b,$7c508
    beq       label_78b3c
label_78b00:
    add.w     d4,d0
    sub.w     d5,d1
    add.w     d0,d2
    add.w     d1,d3
    move.w    d2,d6
    andi.w    #$fffc,d6
    or.b      (a0),d6
    andi.w    #$fffd,d6
    move.w    d6,(a2)+
    move.w    d3,d6
    muls.w    (a3)+,d6
    swap      d6
    add.w     (a4)+,d6
    move.w    d6,(a2)+
    cmp.w     #$60,d6
    bcc       label_78f08
    cmp.w     d7,d6
    bpl.s     label_78b2e
    move.b    d6,d7
label_78b2e:
    move.w    d7,(a2)+
    move.w    d0,(a2)+
    subq.w    #1,$7c508
    bne       label_78b00
label_78b3c:
    move.w    #7,$7c508
label_78b44:
    getcourse

    add.w     d4,d0
    sub.w     d5,d1
    add.w     d0,d2
    add.w     d1,d3
    move.w    d2,d6
    andi.w    #$fffc,d6
    or.b      (a0),d6
    move.w    d6,(a2)+
    move.w    d3,d6
    muls.w    (a3)+,d6
    swap      d6
    add.w     (a4)+,d6
    move.w    d6,(a2)+
    cmp.w     #$60,d6
    bcc       label_78f08
    cmp.w     d7,d6
    bpl.s     label_78b80
    move.b    d6,d7
label_78b80:
    move.w    d7,(a2)+
    move.w    d0,(a2)+
    add.w     d4,d0
    sub.w     d5,d1
    add.w     d0,d2
    add.w     d1,d3
    move.w    d2,d6
    andi.w    #$fffc,d6
    or.b      (a0),d6
    move.w    d6,(a2)+
    move.w    d3,d6
    muls.w    (a3)+,d6
    swap      d6
    add.w     (a4)+,d6
    move.w    d6,(a2)+
    cmp.w     #$60,d6
    bcc       label_78f08
    cmp.w     d7,d6
    bpl.s     label_78bae
    move.b    d6,d7
label_78bae:
    move.w    d7,(a2)+
    move.w    d0,(a2)+
    storeshdata
    bcc       label_78f08
    cmp.w     d7,d6
    bpl.s     label_78be0
    move.b    d6,d7
label_78be0:
    move.w    d7,(a2)+
    move.w    d0,(a2)+
    storeshdata
    bcc       label_78f08
    cmp.w     d7,d6
    bpl.s     label_78c12
    move.b    d6,d7
label_78c12:
    move.w    d7,(a2)+
    move.w    d0,(a2)+
    storeshdata
    bcc       label_78f08
    cmp.w     d7,d6
    bpl.s     label_78c44
    move.b    d6,d7
label_78c44:
    move.w    d7,(a2)+
    move.w    d0,(a2)+
    storeshdata
    bcc       label_78f08
    cmp.w     d7,d6
    bpl.s     label_78c76
    move.b    d6,d7
label_78c76:
    move.w    d7,(a2)+
    move.w    d0,(a2)+
    storeshdata
    bcc       label_78f08
    cmp.w     d7,d6
    bpl.s     label_78ca8
    move.b    d6,d7
label_78ca8:
    move.w    d7,(a2)+
    move.w    d0,(a2)+
    storeshdata
    bcc       label_78f08
    cmp.w     d7,d6
    bpl.s     label_78cda
    move.b    d6,d7
label_78cda:
    move.w    d7,(a2)+
    move.w    d0,(a2)+
    storeshdata
    bcc       label_78f08
    cmp.w     d7,d6
    bpl.s     label_78d0c
    move.b    d6,d7
label_78d0c:
    move.w    d7,(a2)+
    move.w    d0,(a2)+
    storeshdata
    bcc       label_78f08
    cmp.w     d7,d6
    bpl.s     label_78d3e
    move.b    d6,d7
label_78d3e:
    move.w    d7,(a2)+
    move.w    d0,(a2)+
    storeshdata
    bcc       label_78f08
    cmp.w     d7,d6
    bpl.s     label_78d70
    move.b    d6,d7
label_78d70:
    move.w    d7,(a2)+
    move.w    d0,(a2)+
    storeshdata
    bcc       label_78f08
    cmp.w     d7,d6
    bpl.s     label_78da2
    move.b    d6,d7
label_78da2:
    move.w    d7,(a2)+
    move.w    d0,(a2)+
    storeshdata
    bcc       label_78f08
    cmp.w     d7,d6
    bpl.s     label_78dd4
    move.b    d6,d7
label_78dd4:
    move.w    d7,(a2)+
    move.w    d0,(a2)+
    storeshdata
    bcc       label_78f08
    cmp.w     d7,d6
    bpl.s     label_78e06
    move.b    d6,d7
label_78e06:
    move.w    d7,(a2)+
    move.w    d0,(a2)+
    storeshdata
    bcc       label_78f08
    cmp.w     d7,d6
    bpl.s     label_78e38
    move.b    d6,d7
label_78e38:
    move.w    d7,(a2)+
    move.w    d0,(a2)+
    storeshdata
    bcc       label_78f08
    cmp.w     d7,d6
    bpl.s     label_78e6a
    move.b    d6,d7
label_78e6a:
    move.w    d7,(a2)+
    move.w    d0,(a2)+
    subq.w    #1,$7c508
    bne       label_78b44
    getcourse
value2:
    move.w    #5,$7c508
    add.w     d4,d0
    sub.w     d5,d1
    add.w     d0,d2
    add.w     d1,d3
    move.w    d2,d6
    andi.w    #$fffc,d6
    or.b      (a0),d6
    move.w    d6,(a2)+
    move.w    d3,d6
    muls.w    (a3)+,d6
    swap      d6
    add.w     (a4)+,d6
    move.w    d6,(a2)+
    cmp.w     #$60,d6
    bcc       label_78f08
    cmp.w     d7,d6
    bpl.s     label_78ebc
    move.b    d6,d7
label_78ebc:
    move.w    d7,(a2)+
    move.w    d0,(a2)+
    bra       label_78ef6
label_78ec4:
    add.w     d4,d0
    sub.w     d5,d1
    add.w     d0,d2
    add.w     d1,d3
    move.w    d2,d6
    andi.w    #$fffc,d6
    or.b      (a0),d6
    andi.w    #$fffd,d6
    move.w    d6,(a2)+
    move.w    d3,d6
    muls.w    (a3)+,d6
    swap      d6
    add.w     (a4)+,d6
    move.w    d6,(a2)+
    cmp.w     #$60,d6
    bcc       label_78f08
    cmp.w     d7,d6
    bpl.s     label_78ef2
    move.b    d6,d7
label_78ef2:
    move.w    d7,(a2)+
    move.w    d0,(a2)+
label_78ef6:
    subq.w    #1,$7c508
    bne       label_78ec4
    move.w    d7,d1
    move.w    #$80,d0
    bra.s     label_78f28
label_78f08:
    cmp.w     #$60,d6
    bpl.s     label_78f20
    clr.w     (a2)
    clr.w     -2(a2)
    moveq     #0,d1
    move.w    a2,d0
    sub.l     a1,d0
    lsr.w     #3,d0
    addq.w    #1,d0
    bra.s     label_78f28
label_78f20:
    move.w    d7,d1
    move.w    a2,d0
    sub.l     a1,d0
    lsr.w     #3,d0
label_78f28:
    andi.w    #1,(a1)+
    move.w    #$60,(a1)+
    move.w    #$60,(a1)+
    move.w    #0,(a1)
    rts       

