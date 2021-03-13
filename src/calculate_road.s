; $00076560 : 6100 efec                          bsr       $7554e
; $00076564 : 5279 0007 ad76                     addq.w    #1,$7ad76
; $0007656a : 4a79 0007 c586                     tst.w     $7c586
; $00076570 : 660c                               bne.s     $7657e
; $00076572 : 6100 24ec                          bsr       $78a60
; $00076576 : 6100 29c2                          bsr       $78f3a
; $0007657a : 6100 2ab2                          bsr       $7902e
; $0007657e : 4a79 0007 c586                     tst.w     $7c586
; $00076584 : 6604                               bne.s     $7658a
; $00076586 : 6100 0076                          bsr       $765fe
; $0007658a : 6100 2be4                          bsr       $79170
; $0007658e : 4a79 0007 c586                     tst.w     $7c586
; $00076594 : 660c                               bne.s     $765a2


adolines: ; replacement for 78f3a
    lea       distxoffsets,a3
    lea       ascnlinedists,a1
    move.w    $7c5b6,d0
    move.l    $7c596,d4
    bra.s     dolines
bdolines:
    lea       distxoffsets,a3
    lea       $2b640,a1
    move.w    $7c66c,d0
    move.l    $7c64c,d4
dolines:
    move.w    d0,d7               ; startcount
    move.w    d7,d6
    add.w     d6,d6
    subq.w    #2,d7               ; was 1 but 2 means can use as a dec and bmi
    asl.w     #8,d7
    lea       distbasewidths,a0   ; *16 remember
    adda.w    d6,a0
    add.w     d6,d6
    add.w     d6,d6               ; 8 bytes per distseg	
    adda.w    d6,a3
    lea       oneovertab,a2       ; 0-64 top hi, 0-15 bot lo, ;top/bot in pix hi's
    subq.w    #4,a3
    move.w    -(a3),d1            ; first scnline
    subq.w    #6,a3
    move.w    -(a0),d0            ; first width
    move.w    d1,d3
    add.w     d3,d3
    add.w     d1,d3
    add.w     d3,d3               ; mul 6
    adda.w    d3,a1               ; point a1 to correct start pos
    move.w    #-1,d6
nextloop:
    move.w    -(a3),d5
    move.w    -(a3),d2
    subq.w    #4,a3
    move.w    -(a0),d4
    cmp.w     d5,d1
    bne.s     doafill
dolines_zeero:
    move.w    d4,d0
    bra       deebraq
doafill:
    sub.w     d5,d1
    cmp.w     d6,d1
    beq.s     nofillup
    bmi.s     upfill
dnfill:
    add.w     d1,d1
    suba.w    d1,a1
    add.w     d1,d1
    suba.w    d1,a1
    move.w    d4,d0
    move.w    d5,d1
    bra       deebraq
upfill:
    neg.w     d1
    ext.l     d0
    move.w    d1,d3
    add.w     d3,d3
    add.w     d3,d3
    move.l    64(a2,d3.w),d3
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
nupfill:
    move.w    d2,(a1)+
    move.w    d0,(a1)+
    move.w    d7,(a1)+
    sub.w     a4,d7
    swap      d0
    add.l     d3,d0
    swap      d0
    dbra      d1,nupfill
    move.w    d2,(a1)+
    move.w    d0,(a1)+
    move.w    d7,(a1)+
    sub.w     a4,d7
    andi.w    #$ff00,d7
    addi.w    #$100,d7
    bra.s     donefill
nofillup:
    move.w    d2,(a1)+
    move.w    d0,(a1)+
    move.w    d7,(a1)+
donefill:
    move.w    d4,d0
    move.w    d5,d1
deebraq:
    subi.w    #$100,d7
    bpl       nextloop
    rts 
