.globl _set_LMC1992

_timera_irq_new:
	move.w		#0x2300,sr
	movem.l		d0-d7/a0-a6,-(sp)

	lea			0xffff8902.w,a0
	lea			0xffff8904.w,a1
	lea			0xffff8906.w,a2
	lea			0xffff890E.w,a3
	lea			0xffff8910.w,a4
	lea			0xffff8912.w,a5

    clr.w       d0
	move.b	    _dma_position,d0
    cmpi.b      #0,d0
	beq.w       _dma0_new

	cmpi.b      #1,d0
	beq.w       _dma1_new

	cmpi.b      #2,d0
	beq.w       _dma2_new

	bra.w		_mix_next

_dma0_new:
    move.b      #1,_dma_position
	move.b		_dma0_start_high,d0
	move.b		_dma0_start_med,d1
	move.b      _dma0_start_low,d2

	move.b		_dma0_end_high,d3
	move.b		_dma0_end_med,d4
	move.b		_dma0_end_low,d5

	move.w      d0,(a0)
	move.w      d1,(a1)
	move.w      d2,(a2)

	move.w      d3,(a3)
	move.w      d4,(a4)
	move.w      d5,(a5)

	move.l     _sample1,d1
	move.l     _sample2,d2
	move.l     _sample4,d4
	lea.l      _dma_frame,a6
    move.l      d1,a1
	move.l      d2,a2
	move.l      d4,a4

	move.l      a6,d7

	addi.l      #250,d7

	move.l      d7,a6

	clr.l       d0
	moveq       #(62/31)-1,d5

	bra.w		_mix_next

_dma1_new:
    move.b      #2,_dma_position
	move.b		_dma1_start_high,d0
	move.b		_dma1_start_med,d1
	move.b      _dma1_start_low,d2

	move.b		_dma1_end_high,d3
	move.b		_dma1_end_med,d4
	move.b		_dma1_end_low,d5

	move.w      d0,(a0)
	move.w      d1,(a1)
	move.w      d2,(a2)

	move.w      d3,(a3)
	move.w      d4,(a4)
	move.w      d5,(a5)

	move.l     _sample1,d1
	move.l     _sample2,d2
	move.l     _sample4,d4
	lea.l      _dma_frame,a6
    move.l      d1,a1
	move.l      d2,a2
	move.l      d4,a4

	move.l      a6,d7
	addi.l      #500,d7
	move.l      d7,a6

	clr.l       d0
	moveq       #(62/31)-1,d5

	bra.w	    _mix_next

_dma2_new
    move.b      #0,_dma_position
	move.b		_dma2_start_high,d0
	move.b		_dma2_start_med,d1
	move.b      _dma2_start_low,d2

	move.b		_dma2_end_high,d3
	move.b		_dma2_end_med,d4
	move.b		_dma2_end_low,d5

	move.w      d0,(a0)
	move.w      d1,(a1)
	move.w      d2,(a2)

	move.w      d3,(a3)
	move.w      d4,(a4)
	move.w      d5,(a5)

	move.l     _sample1,d1
	move.l     _sample2,d2
	move.l     _sample4,d4
	lea.l      _dma_frame,a6
    move.l      d1,a1
	move.l      d2,a2
	move.l      d4,a4

	clr.l      d0
	moveq      #(62/31)-1,d5

_mix_next:
    rept 31
    move.l      (a1)+,d0
    add.l       (a2)+,d0
	add.l       (a4)+,d0
    move.l      d0,(a6)+
    endr

	dbra    d5,_mix_next

    move.w      (a1)+,d0
    add.w       (a2)+,d0
    add.w       (a4)+,d0
    move.w      d0,(a6)+

    addi.l  #250,_sample1
    addi.l  #250,_sample2
	addi.l  #250,_sample4

    lea.l   _pcm_dummy,a5

_zero_check_sample1:
	subi.b  #1,_sample1_size
	bne.s   _zero_check_sample2
	move.l  a5,_sample1
	move.l  a5,_sample1_mix
	addi.b  #1,_sample1_size
	move.b  #0,_sample1_playing

	cmpi.b  #255,_sample1_loop
	bne.s   _zero_check_sample2
    move.b  _sample1_len,_sample1_size
	move.l  _sample1_mix,_sample1
	move.b  #255,_sample1_playing

_zero_check_sample2:
    subi.b  #1,_sample2_size
	bne.s   _zero_check_sample4
	move.l  a5,_sample2
    addi.b  #1,_sample2_size
	move.b  #0,_sample2_playing

	cmpi.b  #255,_sample2_loop
	bne.s   _zero_check_sample4
    move.b  _sample2_len,_sample2_size
	move.l  _sample2_mix,_sample2
	move.b  #255,_sample2_playing

_zero_check_sample4:
    subi.b  #1,_sample4_size
	bne.w   _zero_check_out
	move.l  a5,_sample4
    addi.b	#1,_sample4_size
	move.b  #0,_sample4_playing

	cmpi.b  #255,_sample4_loop
	bne.s   _music_check
    move.b  _sample4_len,_sample4_size
	move.l  _sample4_mix,_sample4
	move.b  #255,_sample4_playing
	bra.w   _zero_check_out

_music_check:
    cmpi.b  #250,_sample4_loop
    bne.s   _zero_check_out

_queue_check_sample4:
    cmpi.b  #255,_sample4_queue
    bne.s   _zero_check_out
	move.b  #0,_sample4_queue
    move.b  _sample4_qlen,_sample4_size
	move.l  _sample4_qmix,_sample4

_zero_check_out:
    bclr.b		#5,0xfffffa0f.w
	movem.l		(sp)+,d0-d7/a0-a6
	rte

_set_LMC1992:
	movem.l		d0-d7/a0-a6,-(sp)
	move.w      _LMC1992_data,d0
	move.w      sr,-(sp)
	move.w      #0x2700,sr
	move.w      #0x7FF,0xffff8924.w
	move.w		d0,0xffff8922.w
ws:	cmpi.w      #0x7FF,0xffff8924.w
	beq.s       ws
	move.w      (sp)+,sr
we:	cmpi.w      #0x7FF,0xffff8924.w
	bne.s       we
	movem.l		(sp)+,d0-d7/a0-a6
	rts
