    macro getcourse
    adda.w	#16,a0
	move.b	-11(a0),d4	;-8 to +8
	ext.w	d4
	move.b	-10(a0),d5	;-8 to +8 
	ext.w	d5
	add.w	d5,d5
    endm



$00078a60 : 2039 0007 c596                     move.l    $7c596,d0
$00078a66 : 45f9 0002 b880                     lea       $2b880,a2
$00078a6c : 612a                               bsr.s     $78a98
$00078a6e : 33c0 0007 c5b6                     move.w    d0,$7c5b6
$00078a74 : 33c1 0007 c5a0                     move.w    d1,$7c5a0
$00078a7a : 4e75                               rts       
$00078a7c : 2039 0007 c64c                     move.l    $7c64c,d0
$00078a82 : 45f9 0002 b880                     lea       $2b880,a2
$00078a88 : 610e                               bsr.s     $78a98
$00078a8a : 33c0 0007 c66c                     move.w    d0,$7c66c
$00078a90 : 33c1 0007 c656                     move.w    d1,$7c656
$00078a96 : 4e75                               rts       
shiftnstore:
$00078a98 : 224a                               movea.l   a2,a1
$00078a9a : 49f9 0003 0d40                     lea       $30d40,a4 ; distscnlinebase = 30d40
$00078aa0 : 47f9 0003 0e40                     lea       $30e40,a3 ; distbasewidths = 30e40
$00078aa6 : 3200                               move.w    d0,d1
$00078aa8 : e959                               rol.w     #4,d1
$00078aaa : 0241 000f                          andi.w    #$f,d1
$00078aae : 7c0f                               moveq     #$f,d6
$00078ab0 : 9c41                               sub.w     d1,d6
$00078ab2 : 33c6 0007 8af6                     move.w    d6,value1+2 ; "value1 + 2?"
$00078ab8 : 3c01                               move.w    d1,d6
$00078aba : 5246                               addq.w    #1,d6
$00078abc : 33c6 0007 8e8c                     move.w    d6,$78e8c ; "value2 + 2?"
$00078ac2 : 4840                               swap      d0
$00078ac4 : 48c0                               ext.l     d0
$00078ac6 : 80f9 0007 ca9a                     divu.w    $7ca9a,d0 ; $7ca9a = tracklength
$00078acc : 4840                               swap      d0
$00078ace : e940                               asl.w     #4,d0
$00078ad0 : 41f9 0003 113b                     lea       $3113b,a0 ; $3113b = "courseall - 5"
$00078ad6 : d0c0                               adda.w    d0,a0
$00078ad8 : 7000                               moveq     #0,d0  ;cumulative dir l/r init val depends on how much car has gone off line with track
$00078ada : 7200                               moveq     #0,d1  ;cumulative dir u/d
$00078adc : 7400                               moveq     #0,d2  ;cumulative offset l/r
$00078ade : 7600                               moveq     #0,d3  ;cumulative offset u/d
$00078ae0 : 7e60                               moveq     #96,d7 ;NOTE: 96
    getcourse

value1:
$00078af4 : 33fc 000b 0007 c508                move.w    #$b,$7c508
$00078afc : 6700 003e                          beq       label_78b3c
label_78b00:
$00078b00 : d044                               add.w     d4,d0
$00078b02 : 9245                               sub.w     d5,d1
$00078b04 : d440                               add.w     d0,d2
$00078b06 : d641                               add.w     d1,d3
$00078b08 : 3c02                               move.w    d2,d6
$00078b0a : 0246 fffc                          andi.w    #$fffc,d6
$00078b0e : 8c10                               or.b      (a0),d6
$00078b10 : 0246 fffd                          andi.w    #$fffd,d6
$00078b14 : 34c6                               move.w    d6,(a2)+
$00078b16 : 3c03                               move.w    d3,d6
$00078b18 : cddb                               muls.w    (a3)+,d6
$00078b1a : 4846                               swap      d6
$00078b1c : dc5c                               add.w     (a4)+,d6
$00078b1e : 34c6                               move.w    d6,(a2)+
$00078b20 : bc7c 0060                          cmp.w     #$60,d6
$00078b24 : 6400 03e2                          bcc       label_78f08
$00078b28 : bc47                               cmp.w     d7,d6
$00078b2a : 6a02                               bpl.s     label_78b2e
$00078b2c : 1e06                               move.b    d6,d7
label_78b2e:
$00078b2e : 34c7                               move.w    d7,(a2)+
$00078b30 : 34c0                               move.w    d0,(a2)+
$00078b32 : 5379 0007 c508                     subq.w    #1,$7c508
$00078b38 : 6600 ffc6                          bne       label_78b00
label_78b3c:
$00078b3c : 33fc 0007 0007 c508                move.w    #7,$7c508
$00078b44 : d0fc 0010                          adda.w    #$10,a0
$00078b48 : 1828 fff5                          move.b    $fff5(a0),d4
$00078b4c : 4884                               ext.w     d4
$00078b4e : 1a28 fff6                          move.b    $fff6(a0),d5
$00078b52 : 4885                               ext.w     d5
$00078b54 : da45                               add.w     d5,d5
$00078b56 : d044                               add.w     d4,d0
$00078b58 : 9245                               sub.w     d5,d1
$00078b5a : d440                               add.w     d0,d2
$00078b5c : d641                               add.w     d1,d3
$00078b5e : 3c02                               move.w    d2,d6
$00078b60 : 0246 fffc                          andi.w    #$fffc,d6
$00078b64 : 8c10                               or.b      (a0),d6
$00078b66 : 34c6                               move.w    d6,(a2)+
$00078b68 : 3c03                               move.w    d3,d6
$00078b6a : cddb                               muls.w    (a3)+,d6
$00078b6c : 4846                               swap      d6
$00078b6e : dc5c                               add.w     (a4)+,d6
$00078b70 : 34c6                               move.w    d6,(a2)+
$00078b72 : bc7c 0060                          cmp.w     #$60,d6
$00078b76 : 6400 0390                          bcc       label_78f08
$00078b7a : bc47                               cmp.w     d7,d6
$00078b7c : 6a02                               bpl.s     label_78b80
$00078b7e : 1e06                               move.b    d6,d7
label_78b80:
$00078b80 : 34c7                               move.w    d7,(a2)+
$00078b82 : 34c0                               move.w    d0,(a2)+
$00078b84 : d044                               add.w     d4,d0
$00078b86 : 9245                               sub.w     d5,d1
$00078b88 : d440                               add.w     d0,d2
$00078b8a : d641                               add.w     d1,d3
$00078b8c : 3c02                               move.w    d2,d6
$00078b8e : 0246 fffc                          andi.w    #$fffc,d6
$00078b92 : 8c10                               or.b      (a0),d6
$00078b94 : 34c6                               move.w    d6,(a2)+
$00078b96 : 3c03                               move.w    d3,d6
$00078b98 : cddb                               muls.w    (a3)+,d6
$00078b9a : 4846                               swap      d6
$00078b9c : dc5c                               add.w     (a4)+,d6
$00078b9e : 34c6                               move.w    d6,(a2)+
$00078ba0 : bc7c 0060                          cmp.w     #$60,d6
$00078ba4 : 6400 0362                          bcc       label_78f08
$00078ba8 : bc47                               cmp.w     d7,d6
$00078baa : 6a02                               bpl.s     label_78bae
$00078bac : 1e06                               move.b    d6,d7
label_78bae:
$00078bae : 34c7                               move.w    d7,(a2)+
$00078bb0 : 34c0                               move.w    d0,(a2)+

; STORESHDATA start
$00078bb2 : d044                               add.w     d4,d0
$00078bb4 : 9245                               sub.w     d5,d1
$00078bb6 : d440                               add.w     d0,d2
$00078bb8 : d641                               add.w     d1,d3
$00078bba : 3c02                               move.w    d2,d6
$00078bbc : 0246 fffc                          andi.w    #$fffc,d6
$00078bc0 : 8c10                               or.b      (a0),d6
$00078bc2 : 0246 fffd                          andi.w    #$fffd,d6
$00078bc6 : 34c6                               move.w    d6,(a2)+
$00078bc8 : 3c03                               move.w    d3,d6
$00078bca : cddb                               muls.w    (a3)+,d6
$00078bcc : 4846                               swap      d6
$00078bce : dc5c                               add.w     (a4)+,d6
$00078bd0 : 34c6                               move.w    d6,(a2)+
$00078bd2 : bc7c 0060                          cmp.w     #$60,d6
; STORESHDATA end

$00078bd6 : 6400 0330                          bcc       label_78f08
$00078bda : bc47                               cmp.w     d7,d6
$00078bdc : 6a02                               bpl.s     $78be0
$00078bde : 1e06                               move.b    d6,d7
$00078be0 : 34c7                               move.w    d7,(a2)+
$00078be2 : 34c0                               move.w    d0,(a2)+

; STORESHDATA start
$00078be4 : d044                               add.w     d4,d0
$00078be6 : 9245                               sub.w     d5,d1
$00078be8 : d440                               add.w     d0,d2
$00078bea : d641                               add.w     d1,d3
$00078bec : 3c02                               move.w    d2,d6
$00078bee : 0246 fffc                          andi.w    #$fffc,d6
$00078bf2 : 8c10                               or.b      (a0),d6
$00078bf4 : 0246 fffd                          andi.w    #$fffd,d6
$00078bf8 : 34c6                               move.w    d6,(a2)+
$00078bfa : 3c03                               move.w    d3,d6
$00078bfc : cddb                               muls.w    (a3)+,d6
$00078bfe : 4846                               swap      d6
$00078c00 : dc5c                               add.w     (a4)+,d6
$00078c02 : 34c6                               move.w    d6,(a2)+
$00078c04 : bc7c 0060                          cmp.w     #$60,d6
; STORESHDATA end

$00078c08 : 6400 02fe                          bcc       label_78f08
$00078c0c : bc47                               cmp.w     d7,d6
$00078c0e : 6a02                               bpl.s     $78c12
$00078c10 : 1e06                               move.b    d6,d7
$00078c12 : 34c7                               move.w    d7,(a2)+
$00078c14 : 34c0                               move.w    d0,(a2)+

; STORESHDATA start
$00078c16 : d044                               add.w     d4,d0
$00078c18 : 9245                               sub.w     d5,d1
$00078c1a : d440                               add.w     d0,d2
$00078c1c : d641                               add.w     d1,d3
$00078c1e : 3c02                               move.w    d2,d6
$00078c20 : 0246 fffc                          andi.w    #$fffc,d6
$00078c24 : 8c10                               or.b      (a0),d6
$00078c26 : 0246 fffd                          andi.w    #$fffd,d6
$00078c2a : 34c6                               move.w    d6,(a2)+
$00078c2c : 3c03                               move.w    d3,d6
$00078c2e : cddb                               muls.w    (a3)+,d6
$00078c30 : 4846                               swap      d6
$00078c32 : dc5c                               add.w     (a4)+,d6
$00078c34 : 34c6                               move.w    d6,(a2)+
$00078c36 : bc7c 0060                          cmp.w     #$60,d6
; STORESHDATA end

$00078c3a : 6400 02cc                          bcc       label_78f08
$00078c3e : bc47                               cmp.w     d7,d6
$00078c40 : 6a02                               bpl.s     $78c44
$00078c42 : 1e06                               move.b    d6,d7
$00078c44 : 34c7                               move.w    d7,(a2)+
$00078c46 : 34c0                               move.w    d0,(a2)+

; STORESHDATA start
$00078c48 : d044                               add.w     d4,d0
$00078c4a : 9245                               sub.w     d5,d1
$00078c4c : d440                               add.w     d0,d2
$00078c4e : d641                               add.w     d1,d3
$00078c50 : 3c02                               move.w    d2,d6
$00078c52 : 0246 fffc                          andi.w    #$fffc,d6
$00078c56 : 8c10                               or.b      (a0),d6
$00078c58 : 0246 fffd                          andi.w    #$fffd,d6
$00078c5c : 34c6                               move.w    d6,(a2)+
$00078c5e : 3c03                               move.w    d3,d6
$00078c60 : cddb                               muls.w    (a3)+,d6
$00078c62 : 4846                               swap      d6
$00078c64 : dc5c                               add.w     (a4)+,d6
$00078c66 : 34c6                               move.w    d6,(a2)+
$00078c68 : bc7c 0060                          cmp.w     #$60,d6
; STORESHDATA end

$00078c6c : 6400 029a                          bcc       label_78f08
$00078c70 : bc47                               cmp.w     d7,d6
$00078c72 : 6a02                               bpl.s     $78c76
$00078c74 : 1e06                               move.b    d6,d7
$00078c76 : 34c7                               move.w    d7,(a2)+
$00078c78 : 34c0                               move.w    d0,(a2)+

; STORESHDATA start
$00078c7a : d044                               add.w     d4,d0
$00078c7c : 9245                               sub.w     d5,d1
$00078c7e : d440                               add.w     d0,d2
$00078c80 : d641                               add.w     d1,d3
$00078c82 : 3c02                               move.w    d2,d6
$00078c84 : 0246 fffc                          andi.w    #$fffc,d6
$00078c88 : 8c10                               or.b      (a0),d6
$00078c8a : 0246 fffd                          andi.w    #$fffd,d6
$00078c8e : 34c6                               move.w    d6,(a2)+
$00078c90 : 3c03                               move.w    d3,d6
$00078c92 : cddb                               muls.w    (a3)+,d6
$00078c94 : 4846                               swap      d6
$00078c96 : dc5c                               add.w     (a4)+,d6
$00078c98 : 34c6                               move.w    d6,(a2)+
$00078c9a : bc7c 0060                          cmp.w     #$60,d6
; STORESHDATA end

$00078c9e : 6400 0268                          bcc       label_78f08
$00078ca2 : bc47                               cmp.w     d7,d6
$00078ca4 : 6a02                               bpl.s     $78ca8
$00078ca6 : 1e06                               move.b    d6,d7
$00078ca8 : 34c7                               move.w    d7,(a2)+
$00078caa : 34c0                               move.w    d0,(a2)+

; STORESHDATA start
$00078cac : d044                               add.w     d4,d0
$00078cae : 9245                               sub.w     d5,d1
$00078cb0 : d440                               add.w     d0,d2
$00078cb2 : d641                               add.w     d1,d3
$00078cb4 : 3c02                               move.w    d2,d6
$00078cb6 : 0246 fffc                          andi.w    #$fffc,d6
$00078cba : 8c10                               or.b      (a0),d6
$00078cbc : 0246 fffd                          andi.w    #$fffd,d6
$00078cc0 : 34c6                               move.w    d6,(a2)+
$00078cc2 : 3c03                               move.w    d3,d6
$00078cc4 : cddb                               muls.w    (a3)+,d6
$00078cc6 : 4846                               swap      d6
$00078cc8 : dc5c                               add.w     (a4)+,d6
$00078cca : 34c6                               move.w    d6,(a2)+
$00078ccc : bc7c 0060                          cmp.w     #$60,d6
; STORESHDATA end


$00078cd0 : 6400 0236                          bcc       label_78f08
$00078cd4 : bc47                               cmp.w     d7,d6
$00078cd6 : 6a02                               bpl.s     $78cda
$00078cd8 : 1e06                               move.b    d6,d7
$00078cda : 34c7                               move.w    d7,(a2)+
$00078cdc : 34c0                               move.w    d0,(a2)+

; STORESHDATA start
$00078cde : d044                               add.w     d4,d0
$00078ce0 : 9245                               sub.w     d5,d1
$00078ce2 : d440                               add.w     d0,d2
$00078ce4 : d641                               add.w     d1,d3
$00078ce6 : 3c02                               move.w    d2,d6
$00078ce8 : 0246 fffc                          andi.w    #$fffc,d6
$00078cec : 8c10                               or.b      (a0),d6
$00078cee : 0246 fffd                          andi.w    #$fffd,d6
$00078cf2 : 34c6                               move.w    d6,(a2)+
$00078cf4 : 3c03                               move.w    d3,d6
$00078cf6 : cddb                               muls.w    (a3)+,d6
$00078cf8 : 4846                               swap      d6
$00078cfa : dc5c                               add.w     (a4)+,d6
$00078cfc : 34c6                               move.w    d6,(a2)+
$00078cfe : bc7c 0060                          cmp.w     #$60,d6
; STORESHDATA end


$00078d02 : 6400 0204                          bcc       label_78f08
$00078d06 : bc47                               cmp.w     d7,d6
$00078d08 : 6a02                               bpl.s     $78d0c
$00078d0a : 1e06                               move.b    d6,d7
$00078d0c : 34c7                               move.w    d7,(a2)+
$00078d0e : 34c0                               move.w    d0,(a2)+

; STORESHDATA end
$00078d10 : d044                               add.w     d4,d0
$00078d12 : 9245                               sub.w     d5,d1
$00078d14 : d440                               add.w     d0,d2
$00078d16 : d641                               add.w     d1,d3
$00078d18 : 3c02                               move.w    d2,d6
$00078d1a : 0246 fffc                          andi.w    #$fffc,d6
$00078d1e : 8c10                               or.b      (a0),d6
$00078d20 : 0246 fffd                          andi.w    #$fffd,d6
$00078d24 : 34c6                               move.w    d6,(a2)+
$00078d26 : 3c03                               move.w    d3,d6
$00078d28 : cddb                               muls.w    (a3)+,d6
$00078d2a : 4846                               swap      d6
$00078d2c : dc5c                               add.w     (a4)+,d6
$00078d2e : 34c6                               move.w    d6,(a2)+
$00078d30 : bc7c 0060                          cmp.w     #$60,d6
; STORESHDATA end

$00078d34 : 6400 01d2                          bcc       label_78f08
$00078d38 : bc47                               cmp.w     d7,d6
$00078d3a : 6a02                               bpl.s     $78d3e
$00078d3c : 1e06                               move.b    d6,d7
$00078d3e : 34c7                               move.w    d7,(a2)+
$00078d40 : 34c0                               move.w    d0,(a2)+

; STORESHDATA start
$00078d42 : d044                               add.w     d4,d0
$00078d44 : 9245                               sub.w     d5,d1
$00078d46 : d440                               add.w     d0,d2
$00078d48 : d641                               add.w     d1,d3
$00078d4a : 3c02                               move.w    d2,d6
$00078d4c : 0246 fffc                          andi.w    #$fffc,d6
$00078d50 : 8c10                               or.b      (a0),d6
$00078d52 : 0246 fffd                          andi.w    #$fffd,d6
$00078d56 : 34c6                               move.w    d6,(a2)+
$00078d58 : 3c03                               move.w    d3,d6
$00078d5a : cddb                               muls.w    (a3)+,d6
$00078d5c : 4846                               swap      d6
$00078d5e : dc5c                               add.w     (a4)+,d6
$00078d60 : 34c6                               move.w    d6,(a2)+
$00078d62 : bc7c 0060                          cmp.w     #$60,d6
; STORESHDATA end

$00078d66 : 6400 01a0                          bcc       label_78f08
$00078d6a : bc47                               cmp.w     d7,d6
$00078d6c : 6a02                               bpl.s     $78d70
$00078d6e : 1e06                               move.b    d6,d7
$00078d70 : 34c7                               move.w    d7,(a2)+
$00078d72 : 34c0                               move.w    d0,(a2)+

; STORESHDATA start
$00078d74 : d044                               add.w     d4,d0
$00078d76 : 9245                               sub.w     d5,d1
$00078d78 : d440                               add.w     d0,d2
$00078d7a : d641                               add.w     d1,d3
$00078d7c : 3c02                               move.w    d2,d6
$00078d7e : 0246 fffc                          andi.w    #$fffc,d6
$00078d82 : 8c10                               or.b      (a0),d6
$00078d84 : 0246 fffd                          andi.w    #$fffd,d6
$00078d88 : 34c6                               move.w    d6,(a2)+
$00078d8a : 3c03                               move.w    d3,d6
$00078d8c : cddb                               muls.w    (a3)+,d6
$00078d8e : 4846                               swap      d6
$00078d90 : dc5c                               add.w     (a4)+,d6
$00078d92 : 34c6                               move.w    d6,(a2)+
$00078d94 : bc7c 0060                          cmp.w     #$60,d6
; STORESHDATA end

$00078d98 : 6400 016e                          bcc       label_78f08
$00078d9c : bc47                               cmp.w     d7,d6
$00078d9e : 6a02                               bpl.s     $78da2
$00078da0 : 1e06                               move.b    d6,d7
$00078da2 : 34c7                               move.w    d7,(a2)+
$00078da4 : 34c0                               move.w    d0,(a2)+

; STORESHDATA start
$00078da6 : d044                               add.w     d4,d0
$00078da8 : 9245                               sub.w     d5,d1
$00078daa : d440                               add.w     d0,d2
$00078dac : d641                               add.w     d1,d3
$00078dae : 3c02                               move.w    d2,d6
$00078db0 : 0246 fffc                          andi.w    #$fffc,d6
$00078db4 : 8c10                               or.b      (a0),d6
$00078db6 : 0246 fffd                          andi.w    #$fffd,d6
$00078dba : 34c6                               move.w    d6,(a2)+
$00078dbc : 3c03                               move.w    d3,d6
$00078dbe : cddb                               muls.w    (a3)+,d6
$00078dc0 : 4846                               swap      d6
$00078dc2 : dc5c                               add.w     (a4)+,d6
$00078dc4 : 34c6                               move.w    d6,(a2)+
$00078dc6 : bc7c 0060                          cmp.w     #$60,d6
; STORESHDATA end

$00078dca : 6400 013c                          bcc       label_78f08
$00078dce : bc47                               cmp.w     d7,d6
$00078dd0 : 6a02                               bpl.s     $78dd4
$00078dd2 : 1e06                               move.b    d6,d7
$00078dd4 : 34c7                               move.w    d7,(a2)+
$00078dd6 : 34c0                               move.w    d0,(a2)+

; STORESHDATA start
$00078dd8 : d044                               add.w     d4,d0
$00078dda : 9245                               sub.w     d5,d1
$00078ddc : d440                               add.w     d0,d2
$00078dde : d641                               add.w     d1,d3
$00078de0 : 3c02                               move.w    d2,d6
$00078de2 : 0246 fffc                          andi.w    #$fffc,d6
$00078de6 : 8c10                               or.b      (a0),d6
$00078de8 : 0246 fffd                          andi.w    #$fffd,d6
$00078dec : 34c6                               move.w    d6,(a2)+
$00078dee : 3c03                               move.w    d3,d6
$00078df0 : cddb                               muls.w    (a3)+,d6
$00078df2 : 4846                               swap      d6
$00078df4 : dc5c                               add.w     (a4)+,d6
$00078df6 : 34c6                               move.w    d6,(a2)+
$00078df8 : bc7c 0060                          cmp.w     #$60,d6
; STORESHDATA end

$00078dfc : 6400 010a                          bcc       label_78f08
$00078e00 : bc47                               cmp.w     d7,d6
$00078e02 : 6a02                               bpl.s     $78e06
$00078e04 : 1e06                               move.b    d6,d7
$00078e06 : 34c7                               move.w    d7,(a2)+
$00078e08 : 34c0                               move.w    d0,(a2)+

; STORESHDATA start
$00078e0a : d044                               add.w     d4,d0
$00078e0c : 9245                               sub.w     d5,d1
$00078e0e : d440                               add.w     d0,d2
$00078e10 : d641                               add.w     d1,d3
$00078e12 : 3c02                               move.w    d2,d6
$00078e14 : 0246 fffc                          andi.w    #$fffc,d6
$00078e18 : 8c10                               or.b      (a0),d6
$00078e1a : 0246 fffd                          andi.w    #$fffd,d6
$00078e1e : 34c6                               move.w    d6,(a2)+
$00078e20 : 3c03                               move.w    d3,d6
$00078e22 : cddb                               muls.w    (a3)+,d6
$00078e24 : 4846                               swap      d6
$00078e26 : dc5c                               add.w     (a4)+,d6
$00078e28 : 34c6                               move.w    d6,(a2)+
$00078e2a : bc7c 0060                          cmp.w     #$60,d6
; STORESHDATA end

$00078e2e : 6400 00d8                          bcc       label_78f08
$00078e32 : bc47                               cmp.w     d7,d6
$00078e34 : 6a02                               bpl.s     $78e38
$00078e36 : 1e06                               move.b    d6,d7
$00078e38 : 34c7                               move.w    d7,(a2)+
$00078e3a : 34c0                               move.w    d0,(a2)+

; STORESHDATA start
$00078e3c : d044                               add.w     d4,d0
$00078e3e : 9245                               sub.w     d5,d1
$00078e40 : d440                               add.w     d0,d2
$00078e42 : d641                               add.w     d1,d3
$00078e44 : 3c02                               move.w    d2,d6
$00078e46 : 0246 fffc                          andi.w    #$fffc,d6
$00078e4a : 8c10                               or.b      (a0),d6
$00078e4c : 0246 fffd                          andi.w    #$fffd,d6
$00078e50 : 34c6                               move.w    d6,(a2)+
$00078e52 : 3c03                               move.w    d3,d6
$00078e54 : cddb                               muls.w    (a3)+,d6
$00078e56 : 4846                               swap      d6
$00078e58 : dc5c                               add.w     (a4)+,d6
$00078e5a : 34c6                               move.w    d6,(a2)+
$00078e5c : bc7c 0060                          cmp.w     #$60,d6
; STORESHDATA end

$00078e60 : 6400 00a6                          bcc       label_78f08
$00078e64 : bc47                               cmp.w     d7,d6
$00078e66 : 6a02                               bpl.s     $78e6a
$00078e68 : 1e06                               move.b    d6,d7
$00078e6a : 34c7                               move.w    d7,(a2)+
$00078e6c : 34c0                               move.w    d0,(a2)+
$00078e6e : 5379 0007 c508                     subq.w    #1,$7c508
$00078e74 : 6600 fcce                          bne       $78b44
$00078e78 : d0fc 0010                          adda.w    #$10,a0
$00078e7c : 1828 fff5                          move.b    $fff5(a0),d4
$00078e80 : 4884                               ext.w     d4
$00078e82 : 1a28 fff6                          move.b    $fff6(a0),d5
$00078e86 : 4885                               ext.w     d5
$00078e88 : da45                               add.w     d5,d5
value2:
$00078e8a : 33fc 0005 0007 c508                move.w    #5,$7c508
$00078e92 : d044                               add.w     d4,d0
$00078e94 : 9245                               sub.w     d5,d1
$00078e96 : d440                               add.w     d0,d2
$00078e98 : d641                               add.w     d1,d3
$00078e9a : 3c02                               move.w    d2,d6
$00078e9c : 0246 fffc                          andi.w    #$fffc,d6
$00078ea0 : 8c10                               or.b      (a0),d6
$00078ea2 : 34c6                               move.w    d6,(a2)+
$00078ea4 : 3c03                               move.w    d3,d6
$00078ea6 : cddb                               muls.w    (a3)+,d6
$00078ea8 : 4846                               swap      d6
$00078eaa : dc5c                               add.w     (a4)+,d6
$00078eac : 34c6                               move.w    d6,(a2)+
$00078eae : bc7c 0060                          cmp.w     #$60,d6
$00078eb2 : 6400 0054                          bcc       label_78f08
$00078eb6 : bc47                               cmp.w     d7,d6
$00078eb8 : 6a02                               bpl.s     $78ebc
$00078eba : 1e06                               move.b    d6,d7
$00078ebc : 34c7                               move.w    d7,(a2)+
$00078ebe : 34c0                               move.w    d0,(a2)+
$00078ec0 : 6000 0034                          bra       $78ef6
$00078ec4 : d044                               add.w     d4,d0
$00078ec6 : 9245                               sub.w     d5,d1
$00078ec8 : d440                               add.w     d0,d2
$00078eca : d641                               add.w     d1,d3
$00078ecc : 3c02                               move.w    d2,d6
$00078ece : 0246 fffc                          andi.w    #$fffc,d6
$00078ed2 : 8c10                               or.b      (a0),d6
$00078ed4 : 0246 fffd                          andi.w    #$fffd,d6
$00078ed8 : 34c6                               move.w    d6,(a2)+
$00078eda : 3c03                               move.w    d3,d6
$00078edc : cddb                               muls.w    (a3)+,d6
$00078ede : 4846                               swap      d6
$00078ee0 : dc5c                               add.w     (a4)+,d6
$00078ee2 : 34c6                               move.w    d6,(a2)+
$00078ee4 : bc7c 0060                          cmp.w     #$60,d6
$00078ee8 : 6400 001e                          bcc       label_78f08
$00078eec : bc47                               cmp.w     d7,d6
$00078eee : 6a02                               bpl.s     $78ef2
$00078ef0 : 1e06                               move.b    d6,d7
$00078ef2 : 34c7                               move.w    d7,(a2)+
$00078ef4 : 34c0                               move.w    d0,(a2)+
$00078ef6 : 5379 0007 c508                     subq.w    #1,$7c508
$00078efc : 6600 ffc6                          bne       $78ec4
$00078f00 : 3207                               move.w    d7,d1
$00078f02 : 303c 0080                          move.w    #$80,d0
$00078f06 : 6020                               bra.s     $78f28
label_78f08:
$00078f08 : bc7c 0060                          cmp.w     #$60,d6
$00078f0c : 6a12                               bpl.s     $78f20
$00078f0e : 4252                               clr.w     (a2)
$00078f10 : 426a fffe                          clr.w     $fffe(a2)
$00078f14 : 7200                               moveq     #0,d1
$00078f16 : 300a                               move.w    a2,d0
$00078f18 : 9089                               sub.l     a1,d0
$00078f1a : e648                               lsr.w     #3,d0
$00078f1c : 5240                               addq.w    #1,d0
$00078f1e : 6008                               bra.s     $78f28
$00078f20 : 3207                               move.w    d7,d1
$00078f22 : 300a                               move.w    a2,d0
$00078f24 : 9089                               sub.l     a1,d0
$00078f26 : e648                               lsr.w     #3,d0
$00078f28 : 0259 0001                          andi.w    #1,(a1)+
$00078f2c : 32fc 0060                          move.w    #$60,(a1)+
$00078f30 : 32fc 0060                          move.w    #$60,(a1)+
$00078f34 : 32bc 0000                          move.w    #0,(a1)
$00078f38 : 4e75                               rts       

