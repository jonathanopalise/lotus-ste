    include generated/symbols_0x80000.inc

    ORG $7666c

    jsr initdrawroad

label_76672:                 ; the following code is a replacement for the original code at 0x76672
    move.w    (a4)+,d3
    move.w    (a4)+,d0       ; width of the road at the current line
    move.w    (a4)+,d2       ; distance of current line from camera
    move.w    d3,d4          ; save for later (see not_the_pits)
    addi.w    #$191,d2       ; adjust distance of current line from camera for current frame (this instruction is modified by code elsewhere)
    andi.w    #$fffc,d3
    move.w    d0,d1
    add.w     d1,d1
    addi.w    #$3d8,d3       ; this absolute value gets modified elsewhere
    muls.w    d3,d1          ; this and the following two instructions derive the displayed width of this road line
    swap      d1
    neg.w     d1

    lsr.w #2,d0              ; bring the road width value into a 0-255 range
    and.w #$3fc,d0           ; bring the road width value into a 0-255 range

    andi.w #$400,d2          ; go to the start of the appropriate list of source data pointers
    beq.s line_type_2

line_type_1:
    btst #0,d4               ; is this line in the pits?
    beq.s not_the_pits_1

    add.w #$800,d2           ; use the pits variant of the road graphics

not_the_pits_1:

    add.w d2,d0              ; derive the offset of the appropriate pointer within the source data pointers

    move.l usp,a0            ; get the base address of the pointers to road graphics data (see "initdrawroad")
    move.l (a0,d0.w),a0      ; a0 now contains the pointer to the road graphics data offset for the current line
    add.l d6,a0              ; a0 now contains memory location of central source

    ext.l d1                 ; d1 is the shift value for the current line
    move.l d1,d4             ; copy to d4
    and.b #15,d4             ; convert to skew value
    asr.w d5,d1              ; shift the source data pointer to the correct start point
    and.b #$f8,d1
    sub.l d1,a0              ; d1 now contains adjusted source

    or.w #$c080,d4           ; hog mode
    move.l a0,(a3)           ; set source address
    move.l a1,(a2)           ; set destination

    move.w d5,(a5)           ; set ycount in blitter
    move.w d4,(a6)           ; start blitter for one bitplane

    move.w #$f,$ffff8a3a.w   ; second bitplane is always all 1's so no read required
    move.w d5,(a5)           ; set ycount in blitter
    move.w d4,(a6)           ; start blitter for one bitplane
    move.w #$203,$ffff8a3a.w ; restore read/write mode

    addq.l #4,a0
    move.l a0,(a3)           ; advance source address to third bitplane

    move.w d5,(a5)           ; ycount
    move.w d4,(a6)           ; start blitter for one bitplane

    move.w d5,(a5)           ; ycount
    move.w d4,(a6)           ; start blitter for one bitplane

    lea 160(a1),a1           ; advance destination to next line
    addq.w #1,d7             ; advance line counter
    cmp.w #$60,d7            ; have we drawn all the lines?
    bne label_76672
    rts

line_type_2:
    btst #0,d4               ; is this line in the pits?
    beq not_the_pits_2

    add.w #$800,d2           ; use the pits variant of the road graphics

not_the_pits_2:

    add.w d2,d0              ; derive the offset of the appropriate pointer within the source data pointers

    move.l usp,a0            ; get the base address of the pointers to road graphics data (see "initdrawroad")
    move.l (a0,d0.w),a0      ; a0 now contains the pointer to the road graphics data offset for the current line
    add.l d6,a0              ; a0 now contains memory location of central source

    ext.l d1                 ; d1 is the shift value for the current line
    move.l d1,d4             ; copy to d4
    and.b #15,d4             ; convert to skew value
    asr.w d5,d1              ; shift the source data pointer to the correct start point
    and.b #$f8,d1

    sub.l d1,a0              ; d1 now contains adjusted source

    or.w #$c080,d4           ; hog mode
    move.l a0,(a3)           ; set source address
    move.l a1,(a2)           ; set destination

    move.w d5,(a5)           ; set ycount in blitter
    move.w d4,(a6)           ; start blitter for one bitplane

    move.w d5,(a5)           ; set ycount in blitter
    move.w d4,(a6)           ; start blitter for one bitplane

    move.w #$f,$ffff8a3a.w   ; third bitplane is always all 1's so no read required
    move.w d5,(a5)           ; set ycount in blitter
    move.w d4,(a6)           ; start blitter for one bitplane
    move.w #$203,$ffff8a3a.w ; restore read/write mode

    addq.l #6,a0
    move.l a0,(a3)           ; advance source address to final bitplane

    move.w d5,(a5)           ; ycount
    move.w d4,(a6)           ; start blitter for one bitplane

    lea 160(a1),a1           ; advance destination to next line
    addq.w #1,d7             ; advance line counter
    cmp.w #$60,d7            ; have we drawn all the lines?
    bne label_76672
    rts

filename:
    dc.b "A:0x80000.LZ4"
    dc.b 0

fhandle:
    dc.w 0

init_lotus:
    ; 0x80000 - open file
	move.w	#0,-(sp)
	pea filename	 ; Pointer to Filename
	move.w	#$3d,-(sp) 
	trap	#1
	addq.l	#8,sp
	move.w	d0,fhandle

    ; read file
    move.l #$321c0,-(sp)
    move.l    #$ffff,-(sp)   ; Offset 4
    move.w    fhandle,-(sp)  ; Offset 2
    move.w    #63,-(sp)     ; Offset 0
    trap      #1            ; GEMDOS
    lea       $C(sp),sp     ; Correct stack

    ; close file
	move.w	fhandle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp

    ; decompress
    move.l #$321c0,a0
    move.l #$80000,a1
    jsr lz4_decode

    ; existing lotus code

    move.l    #$708ce,-(sp)
    move.l    #$60,-(sp)
    move.l    #$1f0001,-(sp)
    trap      #$e
    adda.w    #$c,sp
    move.b    #3,$fffffc00.w
    move.b    #$96,$fffffc00.w
    move.l    #$70448,-(sp)
    move.l    #$d0006,-(sp)
    trap      #$e
    addq.w    #8,sp
    move.l    #$70564,-(sp)
    move.l    #$190002,-(sp)
    trap      #$e
    addq.w    #8,sp

    ; load 0x80000
    jmp $70938

;input:
; a0.l = lz4 compressed data address
; a1.l = destination address

lz4_decode:
	addq.l    #7,a0
	lea       little_endian+4,a2
	moveq     #0,d2
	move.w    #$f,d4

next_block:
	move.b    (a0)+,-(a2)
	move.b    (a0)+,-(a2)
	move.b    (a0)+,-(a2)
	move.b    (a0)+,-(a2)
	move.l    (a2)+,d3
	bmi       copy_uncompressed_block
	beq       end_of_compressed_data

	lea       (a0,d3.l),a4

next_token:
	moveq     #0,d0
	move.b    (a0)+,d0

	move.w    d0,d1
	lsr.w     #4,d1
	beq.s     match_data_only

	cmp.w     d4,d1
	beq.s     additional_literal_length

	subq.w    #1,d1

short_literal_copy_loop:
	move.b    (a0)+,(a1)+

	dbra      d1,short_literal_copy_loop

	bra.s     process_match_data

additional_literal_length:
	move.b    (a0)+,d2
	add.w     d2,d1
	not.b     d2
	beq.s     additional_literal_length

	move.w    d1,d3
	lsr.w     #4,d1
	and.w     d4,d3
	add.w     d3,d3
	neg.w     d3
	jmp       literal_copy_start(pc,d3.w)

long_literal_copy_loop:
	move.b    (a0)+,(a1)+
	move.b    (a0)+,(a1)+
	move.b    (a0)+,(a1)+
	move.b    (a0)+,(a1)+
	move.b    (a0)+,(a1)+
	move.b    (a0)+,(a1)+
	move.b    (a0)+,(a1)+
	move.b    (a0)+,(a1)+
	move.b    (a0)+,(a1)+
	move.b    (a0)+,(a1)+
	move.b    (a0)+,(a1)+
	move.b    (a0)+,(a1)+
	move.b    (a0)+,(a1)+
	move.b    (a0)+,(a1)+
	move.b    (a0)+,(a1)+
	move.b    (a0)+,(a1)+
literal_copy_start:
	dbra      d1,long_literal_copy_loop

process_match_data:
	cmpa.l    a4,a0
	beq.s     next_block

match_data_only:
	moveq     #0,d3
	move.b    (a0)+,-(a2)
	move.b    (a0)+,-(a2)
	move.w    (a2)+,d3
	neg.l     d3
	lea       (a1,d3.l),a3

	and.w     d4,d0
	cmp.w     d4,d0
	beq.s     additional_match_length

	move.b    (a3)+,(a1)+
	move.b    (a3)+,(a1)+
	move.b    (a3)+,(a1)+
short_match_copy_loop:
	move.b    (a3)+,(a1)+

	dbra      d0,short_match_copy_loop

	bra.s     next_token

additional_match_length:
	move.b    (a0)+,d2
	add.w     d2,d0
	not.b     d2
	beq.s     additional_match_length

	move.w    d0,d3
	lsr.w     #4,d0
	and.w     d4,d3
	add.w     d3,d3
	neg.w     d3
	jmp       match_copy_start(pc,d3.w)

long_match_copy_loop:
	move.b    (a3)+,(a1)+
	move.b    (a3)+,(a1)+
	move.b    (a3)+,(a1)+
	move.b    (a3)+,(a1)+
	move.b    (a3)+,(a1)+
	move.b    (a3)+,(a1)+
	move.b    (a3)+,(a1)+
	move.b    (a3)+,(a1)+
	move.b    (a3)+,(a1)+
	move.b    (a3)+,(a1)+
	move.b    (a3)+,(a1)+
	move.b    (a3)+,(a1)+
	move.b    (a3)+,(a1)+
	move.b    (a3)+,(a1)+
	move.b    (a3)+,(a1)+
	move.b    (a3)+,(a1)+
match_copy_start:
	dbra      d0,long_match_copy_loop

	move.b    (a3)+,(a1)+
	move.b    (a3)+,(a1)+
	move.b    (a3)+,(a1)+
	move.b    (a3)+,(a1)+

	bra       next_token

copy_uncompressed_block:
	andi.l    #$7fffffff,d3
block_copy_loop:
	move.b    (a0)+,(a1)+

	subq.l    #1,d3
	bne.s     block_copy_loop

	bra       next_block
 
end_of_compressed_data:
	rts

little_endian:
   ds.l   1
