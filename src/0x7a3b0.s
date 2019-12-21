    ORG $7a3b0

    ; a0 is source address
    ; a1 is destination address
    ; d3 is the lines to be drawn
    ; d4 is number of 16 pixel blocks to be drawn (= 8 words)
    ; - so if d4 = 1, we want to draw 16 pixels = 4 words = 8 bytes
    ; d6 is destination bytes to skip after each line
    ; d7 is source bytes to skip after each line

    addq.l #8,d6
    addq.l #10,d7

    move.w #-1,($ffff8a28).w            ; endmask1
    move.w #-1,($ffff8a2a).w            ; endmask2
    move.w #-1,($ffff8a2c).w            ; endmask3
    move.w #10,($ffff8a20).w            ; source x increment
    move.w d7,($ffff8a22).w             ; source y increment
    move.w #8,($ffff8a2e).w             ; dest x increment
    move.w d6,($ffff8a30).w             ; dest y increment
    move.w d4,($ffff8a36).w             ; xcount = number of 16 pixel blocks (once pass per bitplane)
    move.w #$0201,($ffff8a3a).w         ; hop/op
    move.b #$00,($ffff8a3d).w

    ; we are now free to use d7, d6 and d4 for our own purposes
    move.l #$c0,d7

    rept 4

    move.w d3,($ffff8a38).w             ; ycount
    move.l a0,($ffff8a24).w             ; set source address
    move.l a1,($ffff8a32).w             ; set destination
    move.b d7,($ffff8a3c).w             ; start

    addq.l #2,a1                        ; move to next bitplane

    endr

    rts

