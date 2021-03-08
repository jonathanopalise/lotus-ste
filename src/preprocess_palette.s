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


