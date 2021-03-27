solid_sky_rgb_value:
    dc.w $a0a
gradient_rgb_values:
    dc.w $a9a
    dc.w $b9a
    dc.w $baa
    dc.w $caa
    dc.w $cba
    dc.w $dba
    dc.w $dca
    dc.w $ec9
    dc.w $ed9
    dc.w $fd9
    dc.w $fe9
    dc.w $fe9
    dc.w $ff9
    dc.w $ff9
    dc.w $ff9

bars_lookup:
    dc.b 4
    dc.b 1
    dc.b 2
    dc.b 3
    dc.b 4
    dc.b 1
    dc.b 2
    dc.b 3

gradient_init:

    move.w #$684,d2
    cmp.w post_vbl_timer_b_vector_instruction+4,d2 ; we only want to run the gradient code if the vector points to 70684
    bne legacy

    move.w $7c59c,d0 ; gradient_y_at_screen_top
    asr.w #1,d0
    add.w #21,d0

    move.w d0,d1
    move.w d0,d3 ; copy gradient_y_at_screen_top
    neg.w d1 ; $solidLinesRequired = -$gradientYAtScreenTop;

    ; d1 is now solidLinesRequired

    tst.w d1 ; test solidLinesRequired
    bgt solid_lines_required_greater_than_zero ; if solid lines required less than or equal to zero, branch

solid_lines_required_zero_or_less:

    ; $initialGradientRgb = $gradientLookup[$gradientYAtScreenTop >> 2];
    lsr.w #2,d0
    add.w d0,d0
    ext.l d0
    add.l #gradient_rgb_values,d0 ; d0 is now start gradient address

    ; is lines remaining > 3?
    moveq.l #0,d2
    move.b post_vbl_timer_b_lines_instruction+3,d2 ; lines remaining
    cmp.b #4,d2
    bls.s lines_remaining_less_than_or_equal_to_4
    ; we want to branch if lines remaining <=4

lines_remaining_greater_than_4:

    lea bars_lookup,a0
    and.w #3,d1 ; solid_lines_required &=3
    move.b (a0,d1.w),d1 ; new_routine_after: d1 = bars_lookup[$solidLinesRequired & 3];

    and.w #3,d3 ; gradient_y_at_screen_top &= 3
    move.w d2,d4 ; copy lines remaining for later
    and.w #3,d2 ; lines_remaining &= 3
    add.w d3,d2
    move.b (a0,d2.w),d2 ; final_bar_size: d2 = bars_lookup[($gradientYAtScreenTop & 3)+($linesRemaining & 3)];

    sub.w d2,d4
    sub.w d1,d4
    lsr.w #2,d4
    add.w #1,d4

    move.b d4,raster_count
    move.b d2,final_bar_line_count_instruction+3
    move.l d0,current_gradient_address
    move.l d0,a0

    ;move.l    (a0),a0 ; there must be a better way than all this indirection
    move.w    (a0),$ffff825e.w

    move.b    #0,$fffffa1b.w
    move.b    d1,$fffffa21.w ; new routine after
    move.b    #8,$fffffa1b.w
    move.l    #new_raster_routine,$0120.w
    bclr      #0,$fffffa0f.w

    bra endvbl

lines_remaining_less_than_or_equal_to_4:
    ; special case, not yet worked out, so just use default code

    bra legacy

solid_lines_required_greater_than_zero:

    lea solid_sky_rgb_value,a0
    move.w (a0),$ffff825e.w

    ; d1 is solidlinesrequired
    moveq.l #0,d2
    move.b post_vbl_timer_b_lines_instruction+3,d2 ; put lines remaining into d2

    sub.w d1,d2 ; d2 = lines remaining - solid lines required
    ble legacy ; no gradient visible

    move.w d2,d3 ; copy linesRemainingMinusSolidLinesRequired into d3

    ; now calculate raster count
    add.w #3,d2
    lsr.w #2,d2

    ; now calculate final bar size
    and.w #3,d3
    lea bars_lookup,a0
    move.b (a0,d3.w),d3 ; new_routine_after: d1 = bars_lookup[$solidLinesRequired & 3];
 
    move.b d2,raster_count
    move.b d3,final_bar_line_count_instruction+3
    lea gradient_rgb_values,a0
    move.l a0,current_gradient_address

    move.b    #0,$fffffa1b.w
    move.b    d1,$fffffa21.w ; new routine after
    move.b    #8,$fffffa1b.w
    move.l    #new_raster_routine,$0120.w
    bclr      #0,$fffffa0f.w

    bra endvbl
    ; $solidLinesRequired > 0
    ; special case, not yet worked out, so just use default code

legacy:

    ; this is the old code

    move.b    #0,$fffffa1b.w
post_vbl_timer_b_lines_instruction:
    move.b    #$68,$fffffa21.w
    move.b    #8,$fffffa1b.w
post_vbl_timer_b_vector_instruction:
    move.l    #$70790,$0120.w
    bclr      #0,$fffffa0f.w

endvbl:

    jmp $7067a

raster_count:
    dc.b 4
    dc.b 0 ; to align

current_gradient_address:
    dc.l 0

new_raster_routine:

    subq.b #1,raster_count
    beq final_bar

    move.w    #$2700,sr
    move.l    a0,-(sp)
    add.l     #2,current_gradient_address
    ;lea.l     current_gradient_address,a0
    ;move.l    (a0),a0
    move.l    current_gradient_address,a0
    ;move.w    (a0),a0
    move.w    (a0),$ffff825e.w
    move.l    (sp)+,a0
    move.w    #$2300,sr
    move.b    #0,$fffffa1b.w
    move.b    #4,$fffffa21.w
    move.b    #8,$fffffa1b.w
    move.l    #new_raster_routine,$0120.w
    bclr      #0,$fffffa0f.w
    rte

final_bar:

    move.b    #0,$fffffa1b.w
final_bar_line_count_instruction:
    move.b    #$68,$fffffa21.w
    move.b    #8,$fffffa1b.w
    move.l    #$70684,$0120.w
    bclr      #0,$fffffa0f.w
    rte


