; Lotus loader

; Loades cars.rel to $70400 and executes

; Shw/D-Bug 2021

	opt	x-,o+

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp	; we will never return so no save

	move.l	#$80000,a7	; set stack

	move.w	#0,-(sp)	; Open
	pea	filename(pc)
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp	; Handle in d0

	move.l	#$70400,-(sp)	; Load address
	move.l	#61800,-(sp)	; Length
	move.w	d0,-(sp)
	move.w	#$3f,-(sp)	; Read
	trap	#1
	add.l	#12,sp

	jmp	$70400	; Do it!

filename	dc.b	"cars.rel",0

