load_samples:

    ; this is existing code from lotus
    move.w    #$fa,d0
    move.l    #$23b00,d1
    jsr       $745d2
    lea       $23b00,a0
    lea       $2bb20,a1
    lea       $10000,a2
    jsr       $74640

    ; this is new code to load the samples

    rts

