render_status_panel:
    move.w    #$5f,d7

status_panel_line:
    move.w    (a0)+,d0       ; load something into d0
    move.w    d0,d1          ; copy something into d1
    swap      d0             ; swap d0
    move.w    d1,d0          ; low word and high word of d0 now contain the same
    and.l     d0,(a1)        ; apply mask to two consecutive words
    move.l    (a0)+,d1       ; get next value from source data
    or.l      d1,(a1)+
    and.l     d0,(a1)+       ; write mask to positions 4 and 6
    move.w    (a0)+,d1       ; get another value from source data
    or.w      d1,-4(a1)

    adda.w    #$80,a1

    move.w    (a0)+,d0       ; load something into d0
    move.w    d0,d1          ; copy something into d1
    swap      d0             ; swap d0
    move.w    d1,d0          ; low word and high word of d0 now contain the same
    and.l     d0,(a1)        ; apply mask to two consecutive words
    move.l    (a0)+,d1       ; get next value from source data
    or.l      d1,(a1)+
    and.l     d0,(a1)+       ; write mask to positions 4 and 6
    move.w    (a0)+,d1       ; get another value from source data
    or.w      d1,-4(a1)

    move.w    (a0)+,d0       ; load something into d0
    move.w    d0,d1          ; copy something into d1
    swap      d0             ; swap d0
    move.w    d1,d0          ; low word and high word of d0 now contain the same
    and.l     d0,(a1)        ; apply mask to two consecutive words
    move.l    (a0)+,d1       ; get next value from source data
    or.l      d1,(a1)+
    and.l     d0,(a1)+       ; write mask to positions 4 and 6
    move.w    (a0)+,d1       ; get another value from source data
    or.w      d1,-4(a1)

    move.w    (a0)+,d0       ; load something into d0
    move.w    d0,d1          ; copy something into d1
    swap      d0             ; swap d0
    move.w    d1,d0          ; low word and high word of d0 now contain the same
    and.l     d0,(a1)        ; apply mask to two consecutive words
    move.l    (a0)+,d1       ; get next value from source data
    or.l      d1,(a1)+
    and.l     d0,(a1)+       ; write mask to positions 4 and 6
    move.w    (a0)+,d1       ; get another value from source data
    or.w      d1,-4(a1)

    dbra      d7,status_panel_line
    rts

