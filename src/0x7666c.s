    include symbols.inc
 
    ORG $7666c

    jmp initdrawroad

label_76672:                 ; the following code is a replacement for the original code at 0x76672
    move.w    (a4)+,d3
    move.w    (a4)+,d0       ; width of the road at the current line
    move.w    (a4)+,d2       ; distance of current line from camera
    move.w    d3,d5          ; save for later (see not_the_pits)
    addi.w    #$191,d2       ; adjust distance of current line from camera for current frame (this instruction is modified by code elsewhere)
    andi.w    #$fffc,d3
    move.w    d0,d1
    add.w     d1,d1
    addi.w    #$3d8,d3       ; this absolute value gets modified elsewhere
    muls.w    d3,d1          ; this and the following two instructions derive the displayed width of this road line
    swap      d1
    neg.w     d1

    lsr.w #2,d0              ; bring the road width value into a 0-255 range
    and.w #$3fc,d0           ; bring the road width value into a 0-255 range

    andi.w #$400,d2          ; go to the start of the appropriate list of source data pointers

    btst #0,d5               ; is this line in the pits?
    beq not_the_pits

    add.w #$800,d2           ; use the pits variant of the road graphics

not_the_pits:

    add.w d2,d0              ; derive the offset of the appropriate pointer within the source data pointers

    move.l usp,a0            ; get the base address of the pointers to road graphics data (see "initdrawroad")
    move.l (a0,d0.w),a0      ; a0 now contains the pointer to the road graphics data offset for the current line
    add.l d6,a0              ; a0 now contains memory location of central source

    ext.l d1                 ; d1 is the shift value for the current line
    move.l d1,d4             ; copy to d4
    and.b #15,d4             ; convert to skew value
    asr.w #1,d1              ; shift the source data pointer to the correct start point
    and.b #$f8,d1
    sub.l d1,a0              ; d1 now contains adjusted source

    or.w #$c080,d4           ; hog mode
    move.l a0,(a3)           ; set source address

    move.w #1,(a5)           ; set ycount in blitter
    move.l a1,(a2)           ; set destination
    move.w d4,(a6)           ; start blitter for one bitplane

    addq.l #2,a1             ; advance destination to next bitplane
    move.w #1,(a5)           ; set ycount in blitter
    move.l a1,(a2)           ; set destination
    move.w d4,(a6)           ; start blitter for one bitplane

    addq.l #2,a1             ; advance destination to next bitplane
    move.w #1,(a5)           ; ycount
    move.l a1,(a2)           ; set destination
    move.w d4,(a6)           ; start blitter for one bitplane

    addq.l #2,a1             ; advance destination to next bitplane
    move.w #1,(a5)           ; ycount
    move.l a1,(a2)           ; set destination
    move.w d4,(a6)           ; start blitter for one bitplane

    add.l #160-6,a1          ; advance destination to next line
    addq.w #1,d7             ; advance line counter
    cmp.w #$60,d7            ; have we drawn all the lines?
    bne label_76672
    rts

