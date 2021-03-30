
    ORG $79450

    include generated/symbols_0x80000.inc

    move.w    d1,d0           ; this is the 0-319 value!
    lsr.w     #4,d1
    move.w    d1,d2
    add.w     d1,d1
    add.w     d2,d1
    add.w     d1,d1
    adda.w    d1,a1           ; update source address (x position - offset within line)

; -------------------------------------------------------------
; this block shouldn't be necessary when blitter code is put in

    lea       $794ba,a2       ; base address of unrolled looop
    adda.w    d1,a2           ; add starting point within unrolled loop

; ------------------------------------------
; update source address - y position (line)

    move.w    $60(a6),d4      ; horizon height?
    move.w    d4,d1           ; copy to d1
    asl.w     #4,d4           ; multiply by 16
    sub.w     d1,d4           ; (multiply by 15)
    asl.w     #3,d4           ; (multiply by 120)
    adda.w    d4,a1           ; update source address (y position - line)

;--------------------------------------------------------------------------------------------
; preshifting logic - shouldn't be necessary for blitter

    andi.w    #$f,d0          ; preshift logic? redundant?
    eori.w    #$f,d0          ; preshift logic? redundant?
    lsr.w     #2,d0           ; preshift logic? redundant?
    move.w    d0,d1           ; preshift logic 1 - redundant?
    asl.w     #4,d1           ; preshift logic 2 - redundant?
    sub.w     d0,d1           ; preshift logic 3 - redundant?
    asl.w     #8,d1           ; preshift logic 4 - redundant?
    adda.w    d1,a1           ; update source address (set preshifted version)

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
    moveq     #$ff,d1         ; this is the word value for the hardcoded words
    subq.w    #1,d7

;----------------------------------------------------------------------------------------------
; this is where we can start putting blitter support in

    move.w    $7c(a2),-(sp)   ; push the existing instruction onto the stack
    move.w    #$4e75,$7c(a2)  ; replace it with an rts
    jsr       (a2)            ; draw one line
    adda.w    #$78,a1         ; update source
    dbra      d7,$794a8       ; next line
    move.w    (sp)+,$7c(a2)   ; restore previous instruction

    ; this final instruction should be at 0x794b6
    bra       $795aa          ; go to code after the unrolled loop (which will go on to render the sky)





