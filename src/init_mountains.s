init_mountains:
    jsr       $73a5a ; displaced by the jsr to init_mountains

    tst.w     $7cca4 ; this was displaced by the jsr to init_mountains
    rts


