; Lotus loader

; Loades cars.rel to $70400 and executes

; Shw/D-Bug 2021

	opt	x-,o+

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp	; we will never return so no save

    jsr system_check

	move.l	#$80000,a7	; set stack

	move.w	#0,-(sp)	; Open
	pea	filename(pc)
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp	; Handle in d0

	move.l	#$70400,-(sp)	; Load address
	move.l	#61800,-(sp)	; Length
	move.w	d0,-(sp)
	move.w	#$3f,-(sp)	; Read
	trap	#1
	add.l	#12,sp

    ; grazey code START

    ;bclr #5,$fffffa09.w

    ; grazey code END

    ; empire code START

    lea    $fffffa01,a0        >MFP
    moveq    #0,d0
    movep.l    d0,(a0)
    movep.l    d0,8(a0)
    movep.l    d0,16(a0)
    move.b    #$48,22(a0)

    ; empire code END

	jmp	$70400	; Do it!

filename	dc.b	"cars.rel",0

    align 2

dbasell     equ	$ffff820d	; addr of low byte of this reg
dbasel		equ	$ffff8203	; display base low
color0		equ	$ffff8240	; color palette #0

system_check:
    lea system_check_palette,a0
    move.l #$ffff8240,a1
    move.w #16,d6
    bra.s end_pal_loop

pal_loop:
    move.w (a0)+,(a1)+ 
end_pal_loop:
    dbra d6,pal_loop    

    ; get physbase - goes into d0
    move.w    #2,-(sp)     ; Offset 0
    trap      #14          ; Call XBIOS
    addq.l    #2,sp        ; Correct stack

    move.l d0,a1
    move.l d0,a5 ; preserve physbase for later

    lea system_check_graphics,a0
    move.l a0,a2
    add.l #(200*160),a2 ; address of memory status message source
    move.l a0,a3
    add.l #(214*160),a3 ; address of ste status message source
    move.l a0,a4
    add.l #(228*160),a4 ; address of verdict status message source
    moveq.l #0,d5 ; number of tests failed

    move.l #(32000/4),d6
    jsr copy_graphics

	move.l 	$42E,d0
	swap 	d0
	lsr.w	#3,d0 ; d2 = double counts of 512 blocks (so 512k = 1, 1 meg = 2...)
    cmp.w   #2,d0
    bcc.s   memory_ok

    add.l #(7*160),a2
    addq.l #1,d5 ; increment tests failed

memory_ok:

    ; draw memory status message
    move.l a5,a1 ; restore physbase from earlier
    add.l #(160*140),a1
    move.l a2,a0
    move.l #(160*7/4),d6
    jsr copy_graphics

    ; now test machine type

	move.b #$5a,dbasell	 ; see if dbasell is RAM
	tst.b	dbasel			; read another register to destroy
						        ; capacitance effects; dbasel is 00.
	move.b	dbasell,d0    ; read; don't say cmp.b because that
						        ; would put $5a on the bus.
	cmp.b	#$5a,d0		  ; NOW cmp.b
	bne	memST

	clr.b	dbasell		  ; try the test again using zero
	tst.w	color0			; color0 is $FFF
	tst.b	dbasell		  ; read back - should be zero.
	bne	memST

    ; OK, dbasell holds its value: you're an STe.

memSTE:
    bra verdict

memST:				; for ST

    add.l #(7*160),a3
    addq.l #1,d5 ; increment tests failed

verdict:
    ; draw machine status message
    move.l a5,a1 ; restore physbase from earlier
    add.l #(160*153),a1
    move.l a3,a0
    move.l #(160*7/4),d6
    jsr copy_graphics

    tst.l d5
    beq verdict_ok

    add.l #(7*160),a4

verdict_ok:

    ; draw verdict message
    move.l a5,a1 ; restore physbase from earlier
    add.l #(160*166),a1
    move.l a4,a0
    move.l #(160*7/4),d6
    jsr copy_graphics

    tst.l d5
    bne endless_loop

    rts

copy_graphics:
    bra.s end_graphics_loop
graphics_loop:
    move.l (a0)+,(a1)+ 
end_graphics_loop:
    dbra d6,graphics_loop
    rts

endless_loop:
    bra endless_loop

system_check_graphics:
    include "generated/system_check_graphics.s"

system_check_palette:
    include "generated/system_check_palette.s"

