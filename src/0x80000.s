; - This code needs to be loaded at location 524288 (0x80000) on the emulated ST
; - The emulated ST must have 1 meg of memory
; - In order to call this code, we need to patch 767ac with an instruction to call it:
; w 0x767ac 0x4e 0xf9 0x00 0x08 0x00 0x00

; outstanding questions:
; - how can we convert the d0 value representing the road width to a blitter road width?
 
    ORG $80000

    movem.l d0-d7/a0-a6,-(a7)

    moveq.l #-1,d6

    move.w #8,($ffff8a20).w              ; source x increment
    move.w #-158,($ffff8a22).w           ; source y increment
    move.w d6,($ffff8a28).w              ; endmask1
    move.w d6,($ffff8a2a).w              ; endmask2
    move.w d6,($ffff8a2c).w              ; endmask3
    move.w #8,($ffff8a2e).w              ; dest x increment
    move.w #-150,($ffff8a30).w           ; dest y increment
    move.w #$0203,($ffff8a3a).w          ; hop/op
    move.w #20,($ffff8a36).w             ; xcount
    move.w #4,($ffff8a38).w              ; ycount

    move.l #byte_offsets,a0
    move.l (a0),a0
    move.l #gfx_data,a2
    add.l a2,a0 ; a0 now contains memory location of central source

    ext.l d1 ; d1 is the shift value for the current line
    move.l d1,d4 ; copy to d4
    and.b #15,d4 ; convert to skew value
    asr.w #1,d1
    and.b #$f8,d1
    sub.l d1,a0 ; d1 now contains adjusted source

    move.l a0,($ffff8a24).w              ; set source address
    move.l a1,($ffff8a32).w              ; set destination

    ; to generate the start offset, we need the value in d1 at pc = 0x76690

    or.w #$c080,d4
    move.w d4,($ffff8a3c).w

    movem.l (a7)+,d0-d7/a0-a6

    add.l #160,a1
    jmp $767bc

    ; this cant be reached
    ; we need to patch 767ac with this instruction
    ; w 0x767ac 0x4e 0xf9 0x00 0x08 0x00 0x00
    jmp 524288

    align 2

    include "road.s"
