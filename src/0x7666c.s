    ; Redirect to blitter-driven road drawing routine

    include symbols.inc
 
    ORG $7666c

    jmp initdrawroad

label_76672:
    move.w    (a4)+,d3
    move.w    (a4)+,d0
    move.w    (a4)+,d2
    move.w    d3,d6
    addi.w    #$191,d2
    andi.w    #$fffc,d3
    move.w    d0,d1
    add.w     d1,d1
    addi.w    #$3d8,d3
    muls.w    d3,d1
    swap      d1
    neg.w     d1

    ; optimize blitter code: http://atari-forum.com/viewtopic.php?f=68&t=2804

; 76690 starts here
    move.w #4,(a5)                     ; ycount

    lsr.w #4,d0                        ; bring the road width value into a 0-255 range
    and.w #$ff,d0                      ; bring the road width value into a 0-255 range
    add.w d0,d0 
    add.w d0,d0                        ; bring the road width value into a 0-1023 range with increments of 4

    lsr.w #5,d2                        ; d2 should contain something telling us about the road position of current line
    andi.w #$20,d2
    beq.s skipoffsetadd 
    add.w #1024,d0

skipoffsetadd:

    move.l #byte_offsets,a0
    move.l (a0,d0.w),a0                ; a0 now contains the pointer to the road graphics data offset for the current line
    add.l #gfx_data,a0                 ; a0 now contains memory location of central source

    ext.l d1                           ; d1 is the shift value for the current line
    move.l d1,d4                       ; copy to d4
    and.b #15,d4                       ; convert to skew value
    asr.w #1,d1
    and.b #$f8,d1
    sub.l d1,a0                        ; d1 now contains adjusted source

    move.l a0,(a3)            ; set source address
    move.l a1,(a2)            ; set destination

    ; to generate the start offset, we need the value in d1 at pc = 0x76690

    or.w #$8080,d4
    move.w d4,(a6)

blitroad:
    bset.b d5,(a6)             ; start
    bne.s blitroad

    add.l #160,a1
    addq.w    #1,d7
    cmp.w     #$60,d7
    bne       label_76672
    rts

