
    ORG $7942a

    include generated/symbols_0x80000.inc

    beq       jump_to_795aa
    movea.l   #$27800,a1
    move.w    $58(a6),d1
    andi.w    #$fff,d1
    move.w    d1,d0
    asl.w     #4,d1
    sub.w     d0,d1
    lsr.w     #6,d1
label_79444:
    cmp.w     #$140,d1
    bcs.s     label_79450
    subi.w    #$140,d1
    bra.s     label_79444

label_79450:
    move.w    d1,d0           ; this is the 0-319 value!
    move.w    d1,d3
    neg.w     d3
    subq.w    #1,d3
    and.w     #15,d3
    lsr.w     #4,d1
    move.w    d1,d2
    add.w     d1,d1
    add.w     d2,d1
    add.w     d1,d1
    adda.w    d1,a1           ; update source address (x position - offset within line)

; -------------------------------------------------------------
; this block shouldn't be necessary when blitter code is put in

    ;lea       $794ba,a2       ; base address of unrolled looop
    ;adda.w    d1,a2           ; add starting point within unrolled loop

; ------------------------------------------
; update source address - y position (line)

    move.w    $60(a6),d4      ; horizon height?
    move.w    d4,d1           ; copy to d1
    asl.w     #4,d4           ; multiply by 16
    sub.w     d1,d4           ; (multiply by 15)
    asl.w     #5,d4           ; (multiply by 360)
    adda.w    d4,a1           ; update source address (y position - line)

;--------------------------------------------------------------------------------------------
; preshifting logic - shouldn't be necessary for blitter

    ;andi.w    #$f,d0          ; preshift logic? redundant?
    ;eori.w    #$f,d0          ; preshift logic? redundant?
    ;lsr.w     #2,d0           ; preshift logic? redundant?
    ;move.w    d0,d1           ; preshift logic 1 - redundant?
    ;asl.w     #4,d1           ; preshift logic 2 - redundant?
    ;sub.w     d0,d1           ; preshift logic 3 - redundant?
    ;asl.w     #8,d1           ; preshift logic 4 - redundant?
    ;adda.w    d1,a1           ; update source address (set preshifted version)

;----------------------------------------------------------------------------------------------
; remainder of rendering code

    move.w    $5c(a6),d0      ; get a variable related to horizon
    move.w    d0,d1           ; d1 overwritten here suggests that the above preshift logic is redundant
    add.w     d0,d0
    add.w     d0,d0
    add.w     d1,d0
    asl.w     #5,d0           ; multiply by 32
    movea.l   d6,a0           ; d6 must be destination address stored from earlier on
    adda.w    d0,a0           ; update destination - we need to keep this
    ;moveq     #$ff,d1         ; this is the word value for the hardcoded words
    subq.w    #1,d7

;----------------------------------------------------------------------------------------------
; this is where we can start putting blitter support in

mountain_blitter_init:
    ;movem.l d0-d7/a0-a6,-(sp)

    lea $ffff8a20.w,a5       ; source x increment 8a20
    move.w #6,(a5)+          ; source x increment 8a20
    move.w #-118,(a5)+       ; source y increment 8a22
    ;move.l a5,a6             ; back up source address 8a24
    lea 10(a5),a5
    move.w #8,(a5)+          ; dest x increment 8a2e
    move.w #-150,(a5)+       ; dest y increment 8a30
    move.l a5,a2             ; backup destination address 8a32
    addq.l #4,a5
    move.w #20,(a5)+         ; xcount 8a36
    move.l a5,a4             ; a4 is now address of ycount (8a38)
    addq.l #2,a5             ; a3 is now address of hop/op (8a3a)
    move.w #$f,(a5)+         ; hop/op 8a3a, advance a3 to linenum 8a3c
    ; a5 is now 8a3c

    ;temporarily kill skew
    or.b #$80,d3              ; enable fxsr
    move.b d3,$ffff8a3d.w
label_794a8:
    move.l a0,(a2)           ; destination ffff8a36
    move.l a1,$ffff8a24.w      ; source
    move.w #$0203,$ffff8a3a.w

    move.w #1,(a4)           ; ycount ffff8a38 = 1 should be (a4)
    move.b #$c0,(a5)         ; control 8a3c should be (a3)

    move.w #1,(a4)           ; ycount ffff8a38= 1
    move.b #$c0,(a5)         ; control 8a3c

    move.w #$f,$ffff8a3a.w
    move.w #1,(a4)           ; ycount ffff8a38= 1
    move.b #$c0,(a5)         ; control 8a3c

    move.w #$0203,$ffff8a3a.w
    move.w #1,(a4)           ; ycount ffff8a38= 1
    move.b #$c0,(a5)         ; control 8a3c

    adda.w    #120*4,a1         ; update source
    adda.w    #160,a0         ; update destination
    dbra      d7,label_794a8  ; next line

    ; this final instruction should be at 0x794b6
    ;movem.l (sp)+,d0-d7/a0-a6
jump_to_795aa:
    bra       $795aa          ; go to code after the unrolled loop (which will go on to render the sky)


