map_palette_data:

    move.w d0,d1
    andi.w #$eee,d0
    lsr.w  #1,d0
    andi.w #$111,d1
    lsl.w  #3,d1
    or.w d1,d0
    move.w d0,(a1)+
    rts

preprocess_palette:

    jsr determine_road_markings

    movem.l d0-d7/a0-a6,-(sp)
    jsr load_samples
    movem.l	(sp)+,d0-d7/a0-a6

    ; these first two lines were previously located at $744ba and have been displaced
    ; by the jsr instruction to this routine
    move.w    (a0)+,d7
    move.w    d7,$7ca9a

    move.l a0,-(a7)            ; back up a0

    move.w #15,d6
    add.l #26,a0
    lea solid_sky_rgb_value,a1

transfer_gradient_step:
    jsr $74584
    dbra d6,transfer_gradient_step

    ; now transfer the road and roadside colours

    move.l (a7)+,a0            ; restore a0

    move.l a0,-(a7)            ; back up a0

transfer_road_colours:
    addq.l #8,a0
    lea $70856,a1
    jsr $74584
    addq.l #2,a0
    jsr $74584
    addq.l #2,a0
    jsr $74584
    addq.l #2,a0
    jsr $74584

    move.l (a7)+,a0            ; restore a0
 
    rts

convert_palette_entry:
    move.w d0,d1
    andi.w #$eee,d0
    lsr.w  #1,d0
    andi.w #$111,d1
    lsl.w  #3,d1
    or.w d1,d0
    rts

determine_road_markings:
    move.w #1,show_road_markings
    cmp.w #2,$7cd5a ; whichdiff
    bne.s end_determine_road_markings
    cmp.w #3,$7d07e ; race number
    beq.s disable_road_markings
    cmp.w #$c,$7d07e ; race number
    beq.s disable_road_markings
    bra.s end_determine_road_markings
disable_road_markings:
    clr.w show_road_markings
end_determine_road_markings:
    rts

