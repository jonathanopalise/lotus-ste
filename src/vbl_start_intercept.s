vbl_start_intercept:
    movem.l d0-d7/a0-a6,-(sp)

    jsr mixer_vbl

    tst.w $707c4 ; instruction previously located at 70576 but overwritten
    jmp $7057c

