init_mountains:
    jsr       $73a5a ; displaced by the jsr to init_mountains

    ; copy the unshifted 320x32 mountain image back to the load/unpack buffer

    ;move.w #(((320*32)/2)/4),d7
    ; 3 bits per pixel, 320x32 pixels
    move.w #(((320*32)*3)/8)/4,d7
    move.l #$27800,a0
    move.l #$23b00,a1

    bra.s end_first_plane_to_buffer
loop_first_plane_to_buffer:
    move.l (a0)+,(a1)+
end_first_plane_to_buffer:
    dbra d7,loop_first_plane_to_buffer

    move.l #$23b00,a0 ; running source
    move.l a0,a2      ; base source
    move.l #$27800,a1 ; destination
    move.w #32,d7     ; 32 lines

    bra.s end_rearrange_mountain
loop_rearrange_mountain:
    move.l a2,a0
    bsr copy_mountain_line
    move.l a2,a0
    bsr copy_mountain_line
    move.l a2,a0
    bsr copy_mountain_line
    move.l a2,a0
    bsr copy_mountain_line
    lea 120(a2),a2
end_rearrange_mountain:
    dbra d7,loop_rearrange_mountain

    tst.w     $7cca4 ; this was displaced by the jsr to init_mountains
    rts

copy_mountain_line:
    move.w #((320*3)/8)/4,d6 ; 320 pixels, 3 bits per pixel, longword copy
    bra.s end_mountain_line
loop_mountain_line:
    move.l (a0)+,(a1)+
end_mountain_line:
    dbra d6,loop_mountain_line
    rts
