
    ORG $23b00

    lea system_check_palette,a0
    move.l #$ffff8240,a1
    move.w #16,d6
    bra.s end_pal_loop

pal_loop:
    move.w (a0)+,(a1)+ 
end_pal_loop:
    dbra d6,pal_loop    

    ; get physbase - goes into d0
    move.w    #2,-(sp)     ; Offset 0
    trap      #14          ; Call XBIOS
    addq.l    #2,sp        ; Correct stack

    move.l d0,a1
    lea system_check_graphics,a0
    move.l #(32000/4),d6
    bra.s end_graphics_loop

graphics_loop:
    move.l (a0)+,(a1)+ 
end_graphics_loop:
    dbra d6,graphics_loop
    rts

system_check_graphics:
    include "system_check_graphics.s"

system_check_palette:
    include "system_check_palette.s"

