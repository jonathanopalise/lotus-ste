    include generated/symbols_0x80000.inc

    ORG $7666c

    jsr initdrawroad

label_76672:                 ; the following code is a replacement for the original code at 0x76672
    move.w    (a4)+,d3
    move.w    (a4)+,d0       ; width of the road at the current line
    move.w    (a4)+,d2       ; distance of current line from camera
    move.w    d3,d4          ; save for later (see not_the_pits)
    addi.w    #$191,d2       ; adjust distance of current line from camera for current frame (this instruction is modified by code elsewhere)
    andi.w    #$fffc,d3
    move.w    d0,d1
    add.w     d1,d1
    addi.w    #$3d8,d3       ; this absolute value gets modified elsewhere
    muls.w    d3,d1          ; this and the following two instructions derive the displayed width of this road line
    swap      d1
    neg.w     d1
    ext.l d1                 ; d1 is the shift value for the current line
    move.l d1,d3             ; copy to d3
    and.b #15,d3             ; convert to skew value
    asr.w d5,d1              ; shift the source data pointer to the correct start point
    and.b #$f8,d1

    lsr.w #2,d0              ; bring the road width value into a 0-255 range
    and.w #$3fc,d0           ; bring the road width value into a 0-255 range

    tst.w show_road_markings
    beq no_road_markings

    andi.w #$400,d2          ; go to the start of the appropriate list of source data pointers
    beq.s line_type_2

line_type_1:
    btst #0,d4               ; is this line in the pits?
    beq.s not_the_pits_1

    add.w #$800,d2           ; use the pits variant of the road graphics

not_the_pits_1:

    add.w d2,d0              ; derive the offset of the appropriate pointer within the source data pointers

    ;move.l usp,a0            ; get the base address of the pointers to road graphics data (see "initdrawroad")
    move.l (a0,d0.w),d6      ; a0 now contains the pointer to the road graphics data offset for the current line
    ;add.l d6,a0              ; a0 now contains memory location of central source

    sub.l d1,d6              ; d1 now contains adjusted source

    or.w #$c080,d3           ; hog mode
    move.l d6,(a3)           ; set source address
    move.l a1,(a2)           ; set destination

    move.w d5,(a5)           ; set ycount in blitter
    move.w d3,(a6)           ; start blitter for one bitplane

    move.w #$f,$ffff8a3a.w   ; second bitplane is always all 1's so no read required
    move.w d5,(a5)           ; set ycount in blitter
    move.w d3,(a6)           ; start blitter for one bitplane
    move.w #$203,$ffff8a3a.w ; restore read/write mode

    addq.l #4,d6
    move.l d6,(a3)           ; advance source address to third bitplane

    move.w d5,(a5)           ; ycount
    move.w d3,(a6)           ; start blitter for one bitplane

    move.w d5,(a5)           ; ycount
    move.w d3,(a6)           ; start blitter for one bitplane

    lea 160(a1),a1           ; advance destination to next line
    addq.w #1,d7             ; advance line counter
    cmp.w #$60,d7            ; have we drawn all the lines?
    bne label_76672
    rts

line_type_2:
    btst #0,d4               ; is this line in the pits?
    beq not_the_pits_2

    add.w #$800,d2           ; use the pits variant of the road graphics

not_the_pits_2:

    ; this is the codepath for the spans with the white lines

    add.w d2,d0              ; derive the offset of the appropriate pointer within the source data pointers

    ;move.l usp,a0            ; get the base address of the pointers to road graphics data (see "initdrawroad")
    move.l (a0,d0.w),d6      ; a0 now contains the pointer to the road graphics data offset for the current line
    ;add.l d6,a0              ; a0 now contains memory location of central source

    sub.l d1,d6              ; d1 now contains adjusted source

    or.w #$c080,d3           ; hog mode
    move.l d6,(a3)           ; set source address
    move.l a1,(a2)           ; set destination

    move.w d5,(a5)           ; set ycount in blitter
    move.w d3,(a6)           ; start blitter for one bitplane

    move.w d5,(a5)           ; set ycount in blitter
    move.w d3,(a6)           ; start blitter for one bitplane

    move.w #$f,$ffff8a3a.w   ; third bitplane is always all 1's so no read required
    move.w d5,(a5)           ; set ycount in blitter
    move.w d3,(a6)           ; start blitter for one bitplane
    move.w #$203,$ffff8a3a.w ; restore read/write mode

    addq.l #6,d6
    move.l d6,(a3)           ; advance source address to final bitplane

    move.w d5,(a5)           ; ycount
    move.w d3,(a6)           ; start blitter for one bitplane

    lea 160(a1),a1           ; advance destination to next line
    addq.w #1,d7             ; advance line counter
    cmp.w #$60,d7            ; have we drawn all the lines?
    bne label_76672
    rts

no_road_markings:
    andi.w #$400,d2          ; go to the start of the appropriate list of source data pointers
    beq.s alt_line_type_2

alt_line_type_1:
    btst #0,d4               ; is this line in the pits?
    beq.s alt_not_the_pits_1

    add.w #$800,d2           ; use the pits variant of the road graphics

alt_not_the_pits_1:

    add.w d2,d0              ; derive the offset of the appropriate pointer within the source data pointers

    ;move.l usp,a0            ; get the base address of the pointers to road graphics data (see "initdrawroad")
    move.l (a0,d0.w),d6      ; a0 now contains the pointer to the road graphics data offset for the current line
    ;add.l d6,a0              ; a0 now contains memory location of central source

    sub.l d1,d6              ; d1 now contains adjusted source

    or.w #$c080,d3           ; hog mode
    move.l d6,(a3)           ; set source address
    move.l a1,(a2)           ; set destination

    addq.l #2,d6
    move.l d6,(a3)           ; advance source address to final bitplane
    move.w #$203,$ffff8a3a.w   ; first 2 bitplanes are always all 1's so no read required
    move.w d5,(a5)           ; set ycount in blitter
    move.w d3,(a6)           ; start blitter for one bitplane

    move.w #$f,$ffff8a3a.w   ; third bitplane all zeroes
    move.w d5,(a5)           ; set ycount in blitter
    move.w d3,(a6)           ; start blitter for one bitplane

    move.w d5,(a5)           ; set ycount in blitter
    move.w d3,(a6)           ; start blitter for one bitplane

    move.w d5,(a5)           ; ycount
    move.w d3,(a6)           ; start blitter for one bitplane
    move.w #$203,$ffff8a3a.w   ; first 2 bitplanes are always all 1's so no read required

    lea 160(a1),a1           ; advance destination to next line
    addq.w #1,d7             ; advance line counter
    cmp.w #$60,d7            ; have we drawn all the lines?
    bne label_76672
    rts

alt_line_type_2:
    btst #0,d4               ; is this line in the pits?
    beq alt_not_the_pits_2

    add.w #$800,d2           ; use the pits variant of the road graphics

alt_not_the_pits_2:

    add.w d2,d0              ; derive the offset of the appropriate pointer within the source data pointers

    ;move.l usp,a0            ; get the base address of the pointers to road graphics data (see "initdrawroad")
    move.l (a0,d0.w),d6      ; a0 now contains the pointer to the road graphics data offset for the current line
    ;add.l d6,a0              ; a0 now contains memory location of central source

    sub.l d1,a6              ; d1 now contains adjusted source

    or.w #$c080,d3           ; hog mode
    move.l d6,(a3)           ; set source address
    move.l a1,(a2)           ; set destination

    ; this is the codepath for the stripes containing white road lines

    addq.l #4,d6
    move.l d6,(a3)           ; advance source address to final bitplane
    move.w #$203,$ffff8a3a.w   ; first 2 bitplanes are always all 1's so no read required
    move.w d5,(a5)           ; set ycount in blitter
    move.w d3,(a6)           ; start blitter for one bitplane

    move.w #$0,$ffff8a3a.w   ; third bitplane all zeroes
    move.w d5,(a5)           ; set ycount in blitter
    move.w d3,(a6)           ; start blitter for one bitplane

    move.w #$f,$ffff8a3a.w ; restore read/write mode
    move.w d5,(a5)           ; set ycount in blitter
    move.w d3,(a6)           ; start blitter for one bitplane

    move.w d5,(a5)           ; ycount
    move.w d3,(a6)           ; start blitter for one bitplane
    move.w #$203,$ffff8a3a.w   ; first 2 bitplanes are always all 1's so no read required

    lea 160(a1),a1           ; advance destination to next line
    addq.w #1,d7             ; advance line counter
    cmp.w #$60,d7            ; have we drawn all the lines?
    bne label_76672

    rts


