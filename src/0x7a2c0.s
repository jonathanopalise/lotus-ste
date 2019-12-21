    ORG $7a2c0

    move.l #$7abf6,a3
    move.w d4,(a3)+
    move.w d1,(a3)+
    move.w d7,(a3)+
    asr.w #1,d0
    sub.w d0,d1
    move.l d1,a3


