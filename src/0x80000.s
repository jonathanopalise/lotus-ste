
    ORG $80000

leftclipped:

    dc.w 0

rightclipped:

    dc.w 0

initdrawroad:
    move.l #$ffff8a20,a5
    move.w d4,$76688
    move.w #8,(a5)+            ; source x increment 8a20
    move.w #-158,(a5)          ; source y increment 8a22
    addq.l #6,a5
    move.w #-1,(a5)+           ; endmask1 8a28
    move.w #-1,(a5)+           ; endmask2 8a2a
    move.w #-1,(a5)+           ; endmask3 8a2c
    move.w #8,(a5)+            ; dest x increment 8a2e
    move.w #-150,(a5)          ; dest y increment 8x30
    addq.l #6,a5
    move.w #20,(a5)           ; xcount 8a36
    addq.l #4,a5
    move.w #$0203,(a5)        ; hop/op 8a3a
    move.l #$ffff8a38,a5      ; ycount
    move.l #$ffff8a24,a3      ; source
    move.l #$ffff8a32,a2      ; destination
    move.l #$ffff8a3c,a6      ; linenum (to start blitter)
    moveq.l #1,d5 ; d5 is now free for use
    lea.l byte_offsets,a0
    move.l a0,usp
    lea.l gfx_data,a0
    move.l a0,d6
    jmp $76672

drawscenery:

    ; draw a roadside object
    ; a0 is source address
    ; a1 is destination address
    ; d3 is the lines to be drawn
    ; d4 is number of 16 pixel blocks to be drawn (= 8 words)
    ; - so if d4 = 1, we want to draw 16 pixels = 4 words = 8 bytes
    ; d6 is destination bytes to skip after each line
    ; d7 is source bytes to skip after each line

    macro drawsceneryline
    inline
    move.w d3,d6               ; backup number of lines
    move.l a0,(a4)             ; set source address
    move.l a1,(a5)             ; set destination
    bra.s .3
.1:
    move.w #1,(a2)             ; ycount
    move.b #$c0,(a6)
.3: 
    dbra d3,.1
    move.w d6,d3               ; restore number of lines
.2:
    einline
    endm

    movem.l a2-a6,-(a7)
    move.l #$ffff8a38,a2
    move.l #$ffff8a24,a4
    move.l #$ffff8a32,a5
    move.l #$ffff8a3c,a6

    addq.l #8,d6               ; convert to value suitable for blitter
    add.w #10,d7               ; convert to value suitable for blitter

    move.w #10,($ffff8a20).w   ; source x increment
    move.w #8,($ffff8a2e).w    ; dest x increment
    move.w #$201,($ffff8a3a).w ; hop/op: read from source, source & destination

    move.l a3,d0               ; get desired xpos of scenery object
    and.w #$f,d0               ; convert to skew value for blitter
    move.w d0,d1
    beq.s nonfsr               ; if skew is zero, we can't use nfsr

    cmp.w #0,rightclipped
    bne.s nonfsr

    add.w #10,d7
    or.b #$40,d1

nonfsr:

    cmp.w #0,leftclipped
    beq.s nofxsr

    sub.w #10,d7
    sub.w #10,a0
    or.b #$80,d1

    cmp.w #1,d4
    bne.s nofxsr 

    ; when words to draw = 4 and leftclipped != 0, we need to set endmask1 from rightendmasks
    ; In the case of a one word line ENDMASK 1 is used (http://www.atari-wiki.com/index.php/Blitter_manual)
    ; this is a special case and could do with tidying up

    move.w d7,($ffff8a22).w             ; source y increment
    move.w d6,($ffff8a30).w             ; dest y increment
    move.w d4,($ffff8a36).w             ; xcount = number of 16 pixel blocks (one pass per bitplane)
    move.b d1,($ffff8a3d).w

    lea.l rightendmasks,a3
    add.l d0,d0                         ; byte offset in mask lookup table
    move.w (a3,d0.w),d1
    move.w d1,($ffff8a28).w             ; endmask1
    bra.s blitterstart

nofxsr:

    move.w d7,($ffff8a22).w             ; source y increment
    move.w d6,($ffff8a30).w             ; dest y increment
    move.w d4,($ffff8a36).w             ; xcount = number of 16 pixel blocks (once pass per bitplane)
    move.b d1,($ffff8a3d).w

    add.l d0,d0                         ; byte offset in mask lookup table
    move.w #-1,($ffff8a2a).w            ; endmask2

    move.w leftclipped,d1
    bne.s nocalcendmask1                ; branch if zero flag not set

    lea.l leftendmasks,a3
    move.w (a3,d0.w),d1                 ; fetch value of endmask1

nocalcendmask1:
    move.w d1,($ffff8a28).w             ; endmask1

    move.w rightclipped,d1
    bne.s nocalcendmask3                ; branch if zero flag not set

    lea.l rightendmasks,a3
    move.w (a3,d0.w),d1

nocalcendmask3:
    move.w d1,($ffff8a2c).w            ; endmask3

    ; we are now free to use d0, d6 and d4 for our own purposes
    ; looks like d0, d1 and d2 are also available to us

blitterstart:
    move.w #802,d1
    lsl.w #2,d3
    sub.w d3,d1
    move.w d1,2+drawsceneryplane_jsr    ; jump address in unrolled blitter calling table
    moveq.l #1,d1                       ; ycount
    move.b #$c0,d6                      ; blitter start instruction

    rept 3
    jsr drawsceneryplane
    addq.l #2,a1                        ; move to next bitplane
    endr
    jsr drawsceneryplane

    subq.l #6,a1                        ; move destination back to initial bitplane
    move.w #$0207,($ffff8a3a).w         ; hop/op: read from source, source | destination

    rept 3
    addq.l #2,a0                        ; move source to next bitplane
    jsr drawsceneryplane
    addq.l #2,a1                        ; move destination to next bitplane
    endr
    addq.l #2,a0                        ; move source to next bitplane
    jsr drawsceneryplane

    movem.l (a7)+,a2-a6

    rts

drawsceneryplane:
    move.l a0,(a4)             ; set source address
    move.l a1,(a5)             ; set destination

drawsceneryplane_jsr:
    bra drawsceneryplane_aft
    rept 200
    move.w d1,(a2)             ; ycount
    move.b d6,(a6)
    endr
drawsceneryplane_aft:
    rts

drawscenery_3bpp:

    movem.l a2-a6,-(a7)
    move.l #$ffff8a38,a2
    move.l #$ffff8a24,a4
    move.l #$ffff8a32,a5
    move.l #$ffff8a3c,a6

    moveq.l #8,d0
    add.l d0,d6                        ; convert to value suitable for blitter
    add.w d0,d7                        ; convert to value suitable for blitter

    move.w d0,($ffff8a20).w            ; source x increment
    move.w d0,($ffff8a2e).w             ; dest x increment
    move.w #$0201,($ffff8a3a).w         ; hop/op: read from source, source & destination

    move.l a3,d0                        ; get desired xpos of scenery object
    and.w #$f,d0                        ; convert to skew value for blitter
    ;move.l #0,d0
    move.w d0,d1
    beq.s nonfsr_3bpp                        ; if skew is zero, we can't use nfsr

    cmp.w #0,rightclipped
    bne.s nonfsr_3bpp

    add.w #8,d7
    or.b #$40,d1

nonfsr_3bpp:
    move.w d7,($ffff8a22).w             ; source y increment
    move.w d6,($ffff8a30).w             ; dest y increment
    move.w d4,($ffff8a36).w             ; xcount = number of 16 pixel blocks (once pass per bitplane)
    move.b d1,($ffff8a3d).w

    add.l d0,d0                         ; byte offset in mask lookup table
    move.w #-1,($ffff8a2a).w            ; endmask2

    move.w leftclipped,d1
    bne.s nocalcendmask1_3bpp                ; branch if zero flag not set

    lea.l leftendmasks,a3
    move.w (a3,d0.w),d1

nocalcendmask1_3bpp:
    move.w d1,($ffff8a28).w             ; endmask1

    move.w rightclipped,d1
    bne.s nocalcendmask3_3bpp                ; branch if zero flag not set

    lea.l rightendmasks,a3
    move.w (a3,d0.w),d1

nocalcendmask3_3bpp:
    move.w d1,($ffff8a2c).w            ; endmask3

    ; we are now free to use d0, d6 and d4 for our own purposes
    ; looks like d0, d1 and d2 are also available to us

    move.b #$80,d0                      ; store blitter start instruction
    moveq.l #7,d2

    rept 3
    drawsceneryline
    addq.l #2,a1                        ; move to next bitplane
    endr
    drawsceneryline

    subq.l #6,a1                        ; move destination back to initial bitplane
    move.w #$0207,($ffff8a3a).w         ; hop/op: read from source, source | destination

    rept 2
    addq.l #2,a0                        ; move source to next bitplane
    drawsceneryline
    addq.l #2,a1                        ; move destination to next bitplane
    endr
    addq.l #2,a0                        ; move source to next bitplane
    drawsceneryline

    movem.l (a7)+,a2-a6

    rts

leftendmasks:

    dc.w %1111111111111111
    dc.w %0111111111111111
    dc.w %0011111111111111
    dc.w %0001111111111111
    dc.w %0000111111111111
    dc.w %0000011111111111
    dc.w %0000001111111111
    dc.w %0000000111111111
    dc.w %0000000011111111
    dc.w %0000000001111111
    dc.w %0000000000111111
    dc.w %0000000000011111
    dc.w %0000000000001111
    dc.w %0000000000000111
    dc.w %0000000000000011
    dc.w %0000000000000001

rightendmasks:

    dc.w %1111111111111111
    dc.w %1000000000000000
    dc.w %1100000000000000
    dc.w %1110000000000000
    dc.w %1111000000000000
    dc.w %1111100000000000
    dc.w %1111110000000000
    dc.w %1111111000000000
    dc.w %1111111100000000
    dc.w %1111111110000000
    dc.w %1111111111000000
    dc.w %1111111111100000
    dc.w %1111111111110000
    dc.w %1111111111111000
    dc.w %1111111111111100
    dc.w %1111111111111110

; Table 1: This table shows which branch instructions will result in a branch
; taken when testing for a given relationship of D1 to D0 after a CMP D0,D1
; instruction.
;
; Relationship    Signed     Unsigned
; -------------------------------------------------------
; D1 <  D0        BLT        BCS (branch on Carry Set)
; D1 <= D0        BLE        BLS
; D1 =  D0        BEQ        BEQ
; D1 <> D0        BNE        BNE
; D1 >  D0        BGT        BHI
; D1 >= D0        BGE        BCC (branch on Carry Clear)

lines_remaining equ $70668 

solid_rgb_value:
    dc.w $000

gradient_rgb_values:
    dc.w $a0a
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
    add.w #25,d0

    move.w d0,d1
    move.w d0,d3 ; copy gradient_y_at_screen_top
    neg.w d1 ; $solidLinesRequired = -$gradientYAtScreenTop;

    ; d1 is now solidLinesRequired

    tst.w d1 ; test solidLinesRequired
    bgt.s solid_lines_required_greater_than_zero ; if solid lines required less than or equal to zero, branch

solid_lines_required_zero_or_less:

    ; $initialGradientRgb = $gradientLookup[$gradientYAtScreenTop >> 2];
    lsr.w #2,d0
    lsl.w #1,d0
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

    move.l    (a0),a0 ; there must be a better way than all this indirection
    move.w    a0,$ffff825e.w

trigger_new_raster_routine:
    move.b    #0,$fffffa1b.w
    move.b    d1,$fffffa21.w ; new routine after
    move.b    #8,$fffffa1b.w
    move.l    #new_raster_routine,$0120.w
    bclr      #0,$fffffa0f.w

    bra.s endvbl 

lines_remaining_less_than_or_equal_to_4:
    ; special case, not yet worked out, so just use default code

    bra legacy

solid_lines_required_greater_than_zero:

    move.w    #$a0b,$ffff825e.w

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
    lea.l     current_gradient_address,a0
    move.l    (a0),a0
    move.w    (a0),a0
    move.w    a0,$ffff825e.w
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

map_palette_data:

    move.w d0,d1
    andi.w #$eee,d0
    lsr.w  #1,d0
    andi.w #$111,d1
    lsl.w  #3,d1
    or.w d1,d0
    move.w d0,(a1)+
    rts

    align 2

    include "road.s"

