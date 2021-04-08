; Lotus loader

; Loades cars.rel to $70400 and executes

; Shw/D-Bug 2021

	opt	x-,o+

    include generated/symbols_for_loader.inc

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp	; we will never return so no save

    bsr system_check

	move.l	#$80000,a7	; set stack

	move.w	#0,-(sp)	; Open
	pea	cars_filename(pc)
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp	; Handle in d0

	move.l	#$23b00,-(sp)	; Load address
	move.l	#61800,-(sp)	; Length
	move.w	d0,-(sp)
	move.w	#$3f,-(sp)	; Read
	trap	#1
	lea.l	12(sp),sp

    ; grazey code START

    ;bclr #5,$fffffa09.w

    ; decompress
    move.l #$23b00,a0
    lea $70400,a1
    bsr lz4_decode

    ; grazey code END

    ; 0x80000 - open file
	move.w	#0,-(sp)
	pea ext_filename(pc)	 ; Pointer to Filename
	move.w	#$3d,-(sp) 
	trap	#1
	addq.l	#8,sp
	move.w	d0,fhandle

    ; read file
    move.l #$321c0,-(sp)
    move.l    #200000,-(sp)   ; Offset 4
    move.w    fhandle(pc),-(sp)  ; Offset 2
    move.w    #63,-(sp)     ; Offset 0
    trap      #1            ; GEMDOS
    lea       $C(sp),sp     ; Correct stack

    ; close file
	move.w	fhandle(pc),-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp

    ; decompress
    move.l #$321c0,a0
    move.l #$80000,a1
    bsr lz4_decode

    move.w is_ste(pc),hasDmaSound

    ; empire code START

    lea    $fffffa01.w,a0        >MFP
    moveq    #0,d0
    movep.l    d0,0(a0)
    movep.l    d0,8(a0)
    movep.l    d0,16(a0)
    move.b    #$48,22(a0)

    ; empire code END

	jmp	$70400	; Do it!

is_ste:
    dc.w 0

fhandle:
    dc.w 0

cars_filename	dc.b	"cars.lz4",0
    align 1

ext_filename:
    dc.b "A:0x80000.LZ4",0

    align 1

dbasell     equ	$ffff820d	; addr of low byte of this reg
dbasel		equ	$ffff8203	; display base low
color0		equ	$ffff8240	; color palette #0

system_check:
    lea system_check_palette,a0
    move.w #$8240,a1
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

    lea system_check_graphics(pc),a0
    move.l a0,a2
    lea.l 200*160(a2),a2 ; address of memory status message source
    move.l a0,a3
    add.l #(214*160),a3 ; address of ste status message source
    move.l a0,a4
    add.l #(228*160),a4 ; address of verdict status message source
    moveq.l #0,d5 ; number of tests failed

    move.l #(32000/4),d6
    bsr copy_graphics

	move.l 	$42E.w,d0
	swap 	d0
	lsr.w	#3,d0 ; d2 = double counts of 512 blocks (so 512k = 1, 1 meg = 2...)
    cmp.w   #2,d0
    bcc.s   memory_ok

    lea.l 7*160(a2),a2
    addq.l #1,d5 ; increment tests failed

memory_ok:

    ; draw memory status message
    move.l a5,a1 ; restore physbase from earlier
    lea.l 160*165(a1),a1
    move.l a2,a0
    move.l #(160*7/4),d6
    bsr copy_graphics

    ; now test machine type

	move.b #$5a,dbasell.w	 ; see if dbasell is RAM
	tst.b	dbasel.w			; read another register to destroy
						        ; capacitance effects; dbasel is 00.
	move.b	dbasell.w,d0    ; read; don't say cmp.b because that
						        ; would put $5a on the bus.
	cmp.b	#$5a,d0		  ; NOW cmp.b
	bne.s	memST

	clr.b	dbasell.w		  ; try the test again using zero
	tst.w	color0.w			; color0 is $FFF
	tst.b	dbasell.w		  ; read back - should be zero.
	bne.s	memST

    ; OK, dbasell holds its value: you're an STe.

memSTE:
    move.b      $fffffc00.w,d0
    beq.s       alternate_not_held                                                   ; if it's zero then it's neither a packet from the joystick or keyboard
    move.b      $fffffc02.w,d0
    cmp.b       #$38,d0
    bne.s       alternate_not_held
    clr.w       is_ste
    bra.s       verdict
alternate_not_held
    move.w #%10011101000,is_ste
    bra.s verdict

memST:				; for ST
    clr.w is_ste
    move.w    #-1,-(sp)   ; Offset 2
    move.w    #64,-(sp)    ; Offset 0
    trap      #14          ; Call XBIOS
    addq.l    #4,sp        ; Correct stack
    btst      #1,d0
    bne.s verdict

    lea.l 7*160(a3),a3
    addq.l #1,d5 ; increment tests failed

verdict:
    ; draw machine status message
    move.l a5,a1 ; restore physbase from earlier
    lea.l 160*176(a1),a1
    move.l a3,a0
    move.l #(160*7/4),d6
    bsr.s copy_graphics

    tst.l d5
    beq.s verdict_ok

    lea.l 7*160(a4),a4

verdict_ok:

    ; draw verdict message
    move.l a5,a1 ; restore physbase from earlier
    lea 160*187(a1),a1
    ;add.l #(160*187),a1
    move.l a4,a0
    move.l #(160*7/4),d6
    bsr.s copy_graphics

    tst.l d5
    bne.s endless_loop

    rts

copy_graphics:
    bra.s end_graphics_loop
graphics_loop:
    move.l (a0)+,(a1)+ 
end_graphics_loop:
    dbra d6,graphics_loop
    rts

endless_loop:
    bra.s endless_loop

    include "lz4_decode.s"

system_check_graphics:
    include "generated/system_check_graphics.s"

system_check_palette:
    include "generated/system_check_palette.s"

