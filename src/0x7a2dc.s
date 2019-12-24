    ORG $7a2dc

    ; attempt to store the skew of a sprite in a3 for later use

    move.l d1,a3 
    and.w $7a642,d1
    move.w d1,d2
    asr.w #4,d2
    moveq #0,d1

