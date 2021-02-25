
    align 2
sample1:
    dc.l 0
sample2:
    dc.l 0
sample3:
    dc.l 0
sample4:
    dc.l 0
dma_frame:
    align 2
    dcb.b 1024,0
dma_position:
    dc.b 0
pcm_dummy:
    align 2
    dcb.b 1024,0
sample1_size:
    dc.b 0
sample2_size:
    dc.b 0
sample3_size:
    dc.b 0
sample4_size:
    dc.b 0
sample1_len:
    dc.b 0
sample2_len:
    dc.b 0
sample3_len:
    dc.b 0
sample4_len:
    dc.b 0
sample1_qlen:
    dc.b 0
sample2_qlen:
    dc.b 0
sample3_qlen:
    dc.b 0
sample4_qlen:
    dc.b 0
sample1_queue:
    dc.b 0
sample2_queue:
    dc.b 0
sample3_queue:
    dc.b 0
sample4_queue:
    dc.b 0
sample1_loop:
    dc.b 0
sample2_loop:
    dc.b 0
sample3_loop:
    dc.b 0
sample4_loop:
    dc.b 0
sample1_playing:
    dc.b 0
sample2_playing:
    dc.b 0
sample3_playing:
    dc.b 0
sample4_playing:
    dc.b 0
pcm_mix:
    dc.b 0
dma_irq:
    align 2
    dc.w 0
old_timera:
    align 2
    dc.l 0
dma0_start_high:
    dc.b 0
dma0_start_med:
    dc.b 0
dma0_start_low:
    dc.b 0
dma1_start_high:
    dc.b 0
dma1_start_med:
    dc.b 0
dma1_start_low:
    dc.b 0
dma2_start_high:
    dc.b 0
dma2_start_med:
    dc.b 0
dma2_start_low:
    dc.b 0
dma0_end_high:
    dc.b 0
dma0_end_med:
    dc.b 0
dma0_end_low:
    dc.b 0
dma1_end_high:
    dc.b 0
dma1_end_med:
    dc.b 0
dma1_end_low:
    dc.b 0
dma2_end_high:
    dc.b 0
dma2_end_med:
    dc.b 0
dma2_end_low:
    dc.b 0
    align 2
sample1_mix:
    dc.l 0
sample2_mix:
    dc.l 0
sample3_mix:
    dc.l 0
sample4_mix:
    dc.l 0
sample1_qmix:
    dc.l 0
sample2_qmix:
    dc.l 0
sample3_qmix:
    dc.l 0
sample4_qmix:
    dc.l 0
sample_frame:
    dc.l 0
LMC1992_data:
    dc.w 0

stop_ste_dma_sound:
	link.w fp,#0
	move.w #-30463,a0
	clr.b (a0)
	move.w #-1529,a0
	move.b (a0),d0
	move.w #-1529,a0
	and.b #-33,d0
	move.b d0,(a0)
	move.w #-1517,a0
	move.b (a0),d0
	move.w #-1517,a0
	and.b #-33,d0
	move.b d0,(a0)
	move.w #134,a0
	move.l old_timera,d0
	move.l d0,(a0)
	nop
	unlk fp
	rts
start_ste_dma_sound:
	link.w fp,#-8
	move.l #pcm_dummy,-4(fp)
	move.l -4(fp),d0
	move.l d0,sample1_mix
	move.l #pcm_dummy,-4(fp)
	move.l -4(fp),d0
	move.l d0,sample2_mix
	move.l #pcm_dummy,-4(fp)
	move.l -4(fp),d0
	move.l d0,sample3_mix
	move.l #pcm_dummy,-4(fp)
	move.l -4(fp),d0
	move.l d0,sample4_mix
	move.l #dma_frame,-4(fp)
	move.l -4(fp),d0
	move.l d0,sample_frame
	move.l #pcm_dummy,d0
	move.l d0,sample1
	move.l #pcm_dummy,d0
	move.l d0,sample2
	move.l #pcm_dummy,d0
	move.l d0,sample3
	move.l #pcm_dummy,d0
	move.l d0,sample4
	move.b #4,sample1_size
	move.b #4,sample2_size
	move.b #4,sample3_size
	move.b #4,sample4_size
	move.b #4,sample1_len
	move.b #4,sample2_len
	move.b #4,sample3_len
	move.b #4,sample4_len
	clr.b sample1_loop
	clr.b sample2_loop
	clr.b sample3_loop
	move.b #-6,sample4_loop
	clr.b sample1_playing
	clr.b sample2_playing
	clr.b sample3_playing
	clr.b sample4_playing
	clr.b pcm_mix
	clr.b pcm_mix
	clr.w dma_irq
	move.l #dma_frame+250,-4(fp)
	move.l -4(fp),-8(fp)
	move.l -8(fp),d0
	clr.w d0
	swap d0
	move.l d0,d0
	move.b d0,dma1_start_high
	move.l -8(fp),d0
	lsr.l #8,d0
	move.l d0,d0
	move.b d0,dma1_start_med
	move.l -8(fp),d0
	move.b d0,dma1_start_low
	move.l #dma_frame+500,-4(fp)
	move.l -4(fp),-8(fp)
	move.l -8(fp),d0
	clr.w d0
	swap d0
	move.l d0,d0
	move.b d0,dma1_end_high
	move.l -8(fp),d0
	lsr.l #8,d0
	move.l d0,d0
	move.b d0,dma1_end_med
	move.l -8(fp),d0
	move.b d0,dma1_end_low
	move.l #dma_frame+500,-4(fp)
	move.l -4(fp),-8(fp)
	move.l -8(fp),d0
	clr.w d0
	swap d0
	move.l d0,d0
	move.b d0,dma2_start_high
	move.l -8(fp),d0
	lsr.l #8,d0
	move.l d0,d0
	move.b d0,dma2_start_med
	move.l -8(fp),d0
	move.b d0,dma2_start_low
	move.l #dma_frame+750,-4(fp)
	move.l -4(fp),-8(fp)
	move.l -8(fp),d0
	clr.w d0
	swap d0
	move.l d0,d0
	move.b d0,dma2_end_high
	move.l -8(fp),d0
	lsr.l #8,d0
	move.l d0,d0
	move.b d0,dma2_end_med
	move.l -8(fp),d0
	move.b d0,dma2_end_low
	move.l #dma_frame,-4(fp)
	move.l -4(fp),-8(fp)
	move.l -8(fp),d0
	clr.w d0
	swap d0
	move.l d0,d0
	move.b d0,dma0_start_high
	move.l -8(fp),d0
	lsr.l #8,d0
	move.l d0,d0
	move.b d0,dma0_start_med
	move.l -8(fp),d0
	move.b d0,dma0_start_low
	move.l #dma_frame+250,-4(fp)
	move.l -4(fp),-8(fp)
	move.l -8(fp),d0
	clr.w d0
	swap d0
	move.l d0,d0
	move.b d0,dma0_end_high
	move.l -8(fp),d0
	lsr.l #8,d0
	move.l d0,d0
	move.b d0,dma0_end_med
	move.l -8(fp),d0
	move.b d0,dma0_end_low
	move.w #134,a0
	move.l (a0),d0
	move.l d0,old_timera
	move.w #134,a0
	move.l #timera_irq_new,d0
	move.l d0,(a0)
	move.w #1025,LMC1992_data
	jsr set_LMC1992
	move.w #1094,LMC1992_data
	jsr set_LMC1992
	move.w #1158,LMC1992_data
	jsr set_LMC1992
	move.w #1256,LMC1992_data
	jsr set_LMC1992
	move.w #1300,LMC1992_data
	jsr set_LMC1992
	move.w #1364,LMC1992_data
	jsr set_LMC1992
	move.w #-1529,a0
	move.b (a0),d0
	move.w #-1529,a0
	or.b #32,d0
	move.b d0,(a0)
	move.w #-1517,a0
	move.b (a0),d0
	move.w #-1517,a0
	or.b #32,d0
	move.b d0,(a0)
	move.w #-1533,a0
	move.b (a0),d0
	move.w #-1533,a0
	and.b #127,d0
	move.b d0,(a0)
	move.w #-1511,a0
	clr.b (a0)
	move.w #-1505,a0
	move.b #1,(a0)
	move.w #-1511,a0
	move.b #8,(a0)
	move.w #-30463,a0
	clr.b (a0)
	move.w #-30431,a0
	move.b #-127,(a0)
	move.b dma0_start_high,d0
	move.w #-30462,a0
	move.b d0,d0
	and.w #255,d0
	move.w d0,(a0)
	move.b dma0_start_med,d0
	move.w #-30460,a0
	move.b d0,d0
	and.w #255,d0
	move.w d0,(a0)
	move.b dma0_start_low,d0
	move.w #-30458,a0
	move.b d0,d0
	and.w #255,d0
	move.w d0,(a0)
	move.b dma0_end_high,d0
	move.w #-30450,a0
	move.b d0,d0
	and.w #255,d0
	move.w d0,(a0)
	move.b dma0_end_med,d0
	move.w #-30448,a0
	move.b d0,d0
	and.w #255,d0
	move.w d0,(a0)
	move.b dma0_end_low,d0
	move.w #-30446,a0
	move.b d0,d0
	and.w #255,d0
	move.w d0,(a0)
	move.w #-30463,a0
	move.b #3,(a0)
    nop
    nop
    nop
	move.b dma1_start_high,d0
	move.w #-30462,a0
	move.b d0,d0
	and.w #255,d0
	move.w d0,(a0)
	move.b dma1_start_med,d0
	move.w #-30460,a0
	move.b d0,d0
	and.w #255,d0
	move.w d0,(a0)
	move.b dma1_start_low,d0
	move.w #-30458,a0
	move.b d0,d0
	and.w #255,d0
	move.w d0,(a0)
	move.b dma1_end_high,d0
	move.w #-30450,a0
	move.b d0,d0
	and.w #255,d0
	move.w d0,(a0)
	move.b dma1_end_med,d0
	move.w #-30448,a0
	move.b d0,d0
	and.w #255,d0
	move.w d0,(a0)
	move.b dma1_end_low,d0
	move.w #-30446,a0
	move.b d0,d0
	and.w #255,d0
	move.w d0,(a0)
	move.b #2,dma_position
	nop
	unlk fp
	rts

