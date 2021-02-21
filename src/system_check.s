
    ORG $23b00

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
    include "system_check_graphics.s"

system_check_palette:
    include "system_check_palette.s"

