timera_irq_new:
	;move.w		#$2300,sr
	;movem.l		d0-d7/a0-a6,-(sp)

	lea			$ffff8902.w,a0
	lea			$ffff8904.w,a1
	lea			$ffff8906.w,a2
	lea			$ffff890E.w,a3
	lea			$ffff8910.w,a4
	lea			$ffff8912.w,a5

    clr.w       d0
	move.b	    dma_position,d0
    cmpi.b      #0,d0
	beq.w       dma0_new

	cmpi.b      #1,d0
	beq.w       dma1_new

	cmpi.b      #2,d0
	beq.w       dma2_new

	bra.w		mix_next

dma0_new:
    move.b      #1,dma_position
	move.b		dma0_start_high,d0
	move.b		dma0_start_med,d1
	move.b      dma0_start_low,d2

	move.b		dma0_end_high,d3
	move.b		dma0_end_med,d4
	move.b		dma0_end_low,d5

	move.w      d0,(a0)
	move.w      d1,(a1)
	move.w      d2,(a2)

	move.w      d3,(a3)
	move.w      d4,(a4)
	move.w      d5,(a5)

	move.l     sample1,d1
	move.l     sample2,d2
	move.l     sample4,d4
	lea.l      dma_frame,a6
    move.l      d1,a1
	move.l      d2,a2
	move.l      d4,a4

	move.l      a6,d7

	addi.l      #250,d7

	move.l      d7,a6

	clr.l       d0
	moveq       #(62/31)-1,d5

	bra.w		mix_next

dma1_new:
    move.b      #2,dma_position
	move.b		dma1_start_high,d0
	move.b		dma1_start_med,d1
	move.b      dma1_start_low,d2

	move.b		dma1_end_high,d3
	move.b		dma1_end_med,d4
	move.b		dma1_end_low,d5

	move.w      d0,(a0)
	move.w      d1,(a1)
	move.w      d2,(a2)

	move.w      d3,(a3)
	move.w      d4,(a4)
	move.w      d5,(a5)

	move.l     sample1,d1
	move.l     sample2,d2
	move.l     sample4,d4
	lea.l      dma_frame,a6
    move.l      d1,a1
	move.l      d2,a2
	move.l      d4,a4

	move.l      a6,d7
	addi.l      #500,d7
	move.l      d7,a6

	clr.l       d0
	moveq       #(62/31)-1,d5

	bra.w	    mix_next

dma2_new:
    move.b      #0,dma_position
	move.b		dma2_start_high,d0
	move.b		dma2_start_med,d1
	move.b      dma2_start_low,d2

	move.b		dma2_end_high,d3
	move.b		dma2_end_med,d4
	move.b		dma2_end_low,d5

	move.w      d0,(a0)
	move.w      d1,(a1)
	move.w      d2,(a2)

	move.w      d3,(a3)
	move.w      d4,(a4)
	move.w      d5,(a5)

	move.l     sample1,d1
	move.l     sample2,d2
	move.l     sample4,d4
	lea.l      dma_frame,a6
    move.l      d1,a1
	move.l      d2,a2
	move.l      d4,a4

	clr.l      d0
	moveq      #(62/31)-1,d5

mix_next:
    rept 31
    move.l      (a1)+,d0
    add.l       (a2)+,d0
	add.l       (a4)+,d0
    move.l      d0,(a6)+
    endr

	dbra    d5,mix_next

    move.w      (a1)+,d0
    add.w       (a2)+,d0
    add.w       (a4)+,d0
    move.w      d0,(a6)+

    addi.l  #250,sample1
    addi.l  #250,sample2
	addi.l  #250,sample4

    lea.l   pcm_dummy,a5

zero_check_sample1:
	subi.b  #1,sample1_size
	bne.s   zero_check_sample2
	move.l  a5,sample1
	move.l  a5,sample1_mix
	addi.b  #1,sample1_size
	move.b  #0,sample1_playing

	cmpi.b  #255,sample1_loop
	bne.s   zero_check_sample2
    move.b  sample1_len,sample1_size
	move.l  sample1_mix,sample1
	move.b  #255,sample1_playing

zero_check_sample2:
    subi.b  #1,sample2_size
	bne.s   zero_check_sample4
	move.l  a5,sample2
    addi.b  #1,sample2_size
	move.b  #0,sample2_playing

	cmpi.b  #255,sample2_loop
	bne.s   zero_check_sample4
    move.b  sample2_len,sample2_size
	move.l  sample2_mix,sample2
	move.b  #255,sample2_playing

zero_check_sample4:
    subi.b  #1,sample4_size
	bne.w   zero_check_out
	move.l  a5,sample4
    addi.b	#1,sample4_size
	move.b  #0,sample4_playing

	cmpi.b  #255,sample4_loop
	bne.s   music_check
    move.b  sample4_len,sample4_size
	move.l  sample4_mix,sample4
	move.b  #255,sample4_playing
	bra.w   zero_check_out

music_check:
    cmpi.b  #250,sample4_loop
    bne.s   zero_check_out

queue_check_sample4:
    cmpi.b  #255,sample4_queue
    bne.s   zero_check_out
	move.b  #0,sample4_queue
    move.b  sample4_qlen,sample4_size
	move.l  sample4_qmix,sample4

zero_check_out:
    bclr.b		#5,$fffffa0f.w
	;movem.l		(sp)+,d0-d7/a0-a6
	rts

set_LMC1992:
	movem.l		d0-d7/a0-a6,-(sp)
	move.w      LMC1992_data,d0
	move.w      sr,-(sp)
	move.w      #$2700,sr
	move.w      #$7FF,$ffff8924.w
	move.w		d0,$ffff8922.w
ws:	cmpi.w      #$7FF,$ffff8924.w
	beq.s       ws
	move.w      (sp)+,sr
we:	cmpi.w      #$7FF,$ffff8924.w
	bne.s       we
	movem.l		(sp)+,d0-d7/a0-a6
	rts
