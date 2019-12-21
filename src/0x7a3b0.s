    ORG $7a3b0

    add.w d4,d4
    add.w d4,d4

    add.w #2,d6

    ; a1 is source address
    ; a1 is destination address
    ; d3 is the lines to be drawn
    ; d4 is number of 16 pixel blocks to be drawn (= 8 words)
    ; - so if d4 = 1, we want to draw 16 pixels = 4 words = 8 bytes
    ; d6 is destination bytes to skip after each line
    ; d7 is source bytes to skip after each line

    move.w #2,($ffff8a20).w             ; source x increment
    move.w #2,($ffff8a22).w             ; source y increment
    move.w #-1,($ffff8a28).w            ; endmask1
    move.w #-1,($ffff8a2a).w            ; endmask2
    move.w #-1,($ffff8a2c).w            ; endmask3
    move.w #2,($ffff8a2e).w             ; dest x increment
    move.w d6,($ffff8a30).w             ; dest y increment
    move.w d4,($ffff8a36).w             ; xcount
    move.w d3,($ffff8a38).w             ; ycount
    move.l a0,($ffff8a24).w             ; set source address
    move.l a1,($ffff8a32).w             ; set destination
    move.w #$0203,($ffff8a3a).w         ; hop/op
    move.b #$c0,($ffff8a3c).w           ; start
    move.b #$cc,($ffff8a3d).w           ; start

    rts

