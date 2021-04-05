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
    dc.w $555
    dc.w $555
    dc.w $555
    dc.w $555

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
    cmp.w post_vbl_timer_b_vector_instruction+4(pc),d2 ; we only want to run the gradient code if the vector points to 70684
    bne legacy

    move.l #$70684,final_bar_vector_instruction+2

    move.w $7c59c,d0 ; gradient_y_at_screen_top
    asr.w #1,d0
    add.w #21,d0

    move.w d0,d1
    move.w d0,d3 ; copy gradient_y_at_screen_top
    neg.w d1 ; $solidLinesRequired = -$gradientYAtScreenTop;

    ; d1 is now solidLinesRequired

    tst.w d1 ; test solidLinesRequired
    bgt.s solid_lines_required_greater_than_zero ; if solid lines required less than or equal to zero, branch

solid_lines_required_zero_or_less:

    ; $initialGradientRgb = $gradientLookup[$gradientYAtScreenTop >> 2];
    lsr.w #2,d0
    add.w d0,d0
    ext.l d0
    add.l #gradient_rgb_values,d0 ; d0 is now start gradient address

    ; is lines remaining > 3?
    moveq.l #0,d2
    move.b post_vbl_timer_b_lines_instruction+3(pc),d2 ; lines remaining
    cmp.b #4,d2
    bls.s lines_remaining_less_than_or_equal_to_4
    ; we want to branch if lines remaining <=4

lines_remaining_greater_than_4:

    lea bars_lookup(pc),a0
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
    addq.w #1,d4

    move.b d4,raster_count
    move.b d2,final_bar_line_count_instruction+3
    move.l d0,current_gradient_address
    move.l d0,a0

    move.w    (a0),$ffff825e.w

    move.b    #0,$fffffa1b.w
    move.b    d1,$fffffa21.w ; new routine after
    move.b    #8,$fffffa1b.w
    move.l    #new_raster_routine,$0120.w
    bclr      #0,$fffffa0f.w

    bra.s endvbl

lines_remaining_less_than_or_equal_to_4:
    ; special case, not yet worked out, so just use default code

    bra.s legacy

solid_lines_required_greater_than_zero:

    lea solid_sky_rgb_value(pc),a0
    move.w (a0),$ffff825e.w

    ; d1 is solidlinesrequired
    moveq.l #0,d2
    move.b post_vbl_timer_b_lines_instruction+3(pc),d2 ; put lines remaining into d2

    sub.w d1,d2 ; d2 = lines remaining - solid lines required
    ble.s legacy ; no gradient visible

    move.w d2,d3 ; copy linesRemainingMinusSolidLinesRequired into d3

    ; now calculate raster count
    addq.w #3,d2
    lsr.w #2,d2

    ; now calculate final bar size
    and.w #3,d3
    lea bars_lookup(pc),a0
    move.b (a0,d3.w),d3 ; new_routine_after: d1 = bars_lookup[$solidLinesRequired & 3];
 
    move.b d2,raster_count
    move.b d3,final_bar_line_count_instruction+3
    lea gradient_rgb_values(pc),a0
    move.l a0,current_gradient_address

    clr.b     $fffffa1b.w
    move.b    d1,$fffffa21.w ; new routine after
    move.b    #8,$fffffa1b.w
    move.l    #new_raster_routine,$0120.w
    bclr      #0,$fffffa0f.w

    bra.s endvbl
    ; $solidLinesRequired > 0
    ; special case, not yet worked out, so just use default code

legacy:

    ; this is the old code

    clr.b    $fffffa1b.w
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
    beq.s final_bar

    move.l    a0,usp
    addq.l    #2,current_gradient_address
    move.l    current_gradient_address(pc),a0
    move.w    (a0),$ffff825e.w
    move.l    usp,a0
    clr.b     $fffffa1b.w
    move.b    #4,$fffffa21.w
    move.b    #8,$fffffa1b.w
    bclr      #0,$fffffa0f.w
    rte

final_bar:
    clr.b     $fffffa1b.w
final_bar_line_count_instruction:
    move.b    #$68,$fffffa21.w
    move.b    #8,$fffffa1b.w
final_bar_vector_instruction:
    move.l    #$70684,$0120.w
    bclr      #0,$fffffa0f.w
    rte

p2_sky_line_count:
    dc.b $0
    dc.b $0 ; for padding
p2_final_bar_vector_instruction_plus_2:
    dc.l $0
p2_raster_count:
    dc.b $0
    dc.b $0 ; for padding
p2_final_bar_line_count_instruction_plus_3:
    dc.b $0
    dc.b $0 ; for padding
p2_current_gradient_address:
    dc.l $0
p2_gradient_start_colour:
    dc.w $0
p2_new_routine_after_lines:
    dc.b $0
    dc.b $0 ; for padding
p2_new_routine_after_vector:
    dc.l $0

p2_initialise_sky:
    move.l #$70754,$70742 ; default normal codepath
    cmp.w #8,d0
    ble.s p2_sky_not_visible

    move.l #p2_raster_routine,$70742 ; go to the new p2 sky routine if more than 8 lines
    move.b d0,d1
    subq.b #8,d1
    move.b d1,p2_sky_line_count
    bsr.s p2_initialise_sky_variables
p2_sky_not_visible:
    rts

p2_initialise_sky_variables:
    movem.l d0-d4/a0,-(sp)

    move.l #$70754,p2_final_bar_vector_instruction_plus_2
    move.w $7c652,d0 ; gradient_y_at_screen_top
    asr.w #1,d0
    add.w #21,d0

    move.w d0,d1
    move.w d0,d3 ; copy gradient_y_at_screen_top
    neg.w d1 ; $solidLinesRequired = -$gradientYAtScreenTop;

    ; d1 is now solidLinesRequired

    tst.w d1 ; test solidLinesRequired
    bgt.s p2_solid_lines_required_greater_than_zero ; if solid lines required less than or equal to zero, branch

p2_solid_lines_required_zero_or_less:

    ; $initialGradientRgb = $gradientLookup[$gradientYAtScreenTop >> 2];
    lsr.w #2,d0
    add.w d0,d0
    ext.l d0
    add.l #gradient_rgb_values,d0 ; d0 is now start gradient address

    ; is lines remaining > 3?
    moveq.l #0,d2
    move.b p2_sky_line_count(pc),d2 ; lines remaining
    cmp.b #4,d2
    bls.s p2_lines_remaining_less_than_or_equal_to_4
    ; we want to branch if lines remaining <=4

p2_lines_remaining_greater_than_4:

    lea bars_lookup(pc),a0
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
    addq.w #1,d4

    move.b d4,p2_raster_count
    move.b d2,p2_final_bar_line_count_instruction_plus_3
    move.l d0,p2_current_gradient_address
    ; TODO: don't forget these lines below in the new handler
    move.l d0,a0
    move.w    (a0),p2_gradient_start_colour

    move.b    d1,p2_new_routine_after_lines ; new routine after
    move.l    #new_raster_routine,p2_new_routine_after_vector

    bra.s p2_endvbl

p2_lines_remaining_less_than_or_equal_to_4:
    ; special case, not yet worked out, so just use default code

    bra.s p2_legacy

p2_solid_lines_required_greater_than_zero:

    move.w solid_sky_rgb_value(pc),p2_gradient_start_colour

    ; d1 is solidlinesrequired
    moveq.l #0,d2
    move.b p2_sky_line_count(pc),d2 ; put lines remaining into d2

    sub.w d1,d2 ; d2 = lines remaining - solid lines required
    ble.s p2_legacy ; no gradient visible

    move.w d2,d3 ; copy linesRemainingMinusSolidLinesRequired into d3

    ; now calculate raster count
    addq.w #3,d2
    lsr.w #2,d2

    ; now calculate final bar size
    and.w #3,d3
    lea bars_lookup(pc),a0
    move.b (a0,d3.w),d3 ; new_routine_after: d1 = bars_lookup[$solidLinesRequired & 3];
 
    move.b d2,p2_raster_count
    move.b d3,p2_final_bar_line_count_instruction_plus_3

    lea gradient_rgb_values(pc),a0
    move.l a0,p2_current_gradient_address

    move.b    d1,p2_new_routine_after_lines ; new routine after
    move.l    #new_raster_routine,p2_new_routine_after_vector

    bra.s p2_endvbl
    ; $solidLinesRequired > 0
    ; special case, not yet worked out, so just use default code

p2_legacy:
    move.b p2_sky_line_count(pc),p2_new_routine_after_lines ; number of lines
    move.l #$70754,p2_new_routine_after_vector
p2_endvbl:
    movem.l (sp)+,d0-d4/a0
    rts

;----- END OF NEW CODE

p2_raster_routine:
    move.l p2_final_bar_vector_instruction_plus_2(pc),final_bar_vector_instruction+2
    move.b p2_final_bar_line_count_instruction_plus_3(pc),final_bar_line_count_instruction+3
    move.l p2_current_gradient_address(pc),current_gradient_address
    move.b p2_raster_count(pc),raster_count
    move.w p2_gradient_start_colour(pc),$ffff825e.w

    move.b #0,$fffffa1b.w
    move.b p2_new_routine_after_lines(pc),$fffffa21.w ; number of lines
    move.b #8,$fffffa1b.w
    move.l p2_new_routine_after_vector(pc),$0120.w
    bclr #0,$fffffa0f.w
    rte
