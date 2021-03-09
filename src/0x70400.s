    ORG $70400

    ; **************************************************************************
    ; * Lotus STE                                                              *
    ; *                                                                        *
    ; * Entry point intercept                                                  *
    ; *                                                                        *
    ; * $70400 is where the loader (loader.s) places the program counter after *
    ; * loading CARS.REL from disk into memory. We've intercepted this entry   *
    ; * point here to perform additional startup tasks - see the init_lotus    *
    ; * label within 0x7666c.s for more information on these tasks.            *
    ; *                                                                        *
    ; * The new functionality has been placed within the 0x7666 patch because  *
    ; * some memory has been freed in that area as a result of migrating the   *
    ; * road drawing routine to being driven by the Blitter.                   *
    ; **************************************************************************

    include generated/symbols_0x7666c.inc

    jmp init_lotus

