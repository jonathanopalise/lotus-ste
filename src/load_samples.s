samples_filename:
    dc.b "A:SAMPLES.LZ4"
    dc.b 0

samples_fhandle:
    dc.w 0

samples_need_loading:
    dc.w 1

load_samples_from_0x73968:
    jsr load_samples

    ; this is existing code from lotus
    move.w    #$fa,d0
    move.l    #$23b00,d1
    jsr       $745d2
    lea       $23b00,a0
    lea       $2bb20,a1
    lea       $10000,a2
    jsr       $74640
    rts

load_samples:

    tst.w samples_need_loading
    beq.s dont_load_samples

    ; open file
    move.w  #0,-(sp)
    pea samples_filename     ; Pointer to Filename
    move.w  #$3d,-(sp) 
    trap    #1
    addq.l  #8,sp
    move.w  d0,samples_fhandle

    ; read file
    move.l #$23b00,-(sp)
    move.l    #200000,-(sp)   ; Offset 4
    move.w    samples_fhandle,-(sp)  ; Offset 2
    move.w    #63,-(sp)     ; Offset 0
    trap      #1            ; GEMDOS
    lea       $C(sp),sp     ; Correct stack

    ; close file
    move.w  samples_fhandle,-(sp)
    move.w  #$3e,-(sp)
    trap    #1
    addq.l  #4,sp

    ; decompress
    move.l #$23b00,a0
    lea dataSounds,a1
    jsr lz4_decode

    clr.w samples_need_loading

dont_load_samples:
    rts

