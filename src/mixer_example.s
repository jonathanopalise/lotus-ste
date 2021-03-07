; ---	Lotus Esprit Turbo Challenge STE - realtime sound effects mixing example

	code

	move.l		#0,-(sp)
	move.w		#$20,-(sp)																	; supervisor mode
	trap		#1
	addq.w		#6,sp

	move.w		#$2700,sr																	; disable interrupts
	move.l		#interruptVerticalBlank,$70.w												; custom vertical blank routine
 	move.b		#%00000000,$fffffa07.w														; interrupt enable a - all off
	move.b		#%00000000,$fffffa09.w														; interrupt enable b - all off except ikdb (for joystick and keyboard input)
	move.b		#%00000000,$fffffa13.w														; interrupt mask a - all off
	move.b		#%01000000,$fffffa15.w														; interrupt mask b - all off except ikbd (for joystick and keyboard input)
	move.w		#$2300,sr																	; enable interrupts

	bclr.b		#0,$484.w																	; disable keyclick
	move.b		#$14,$fffffc02.w															; disable mouse

	include		LotusEsprit12517HzMixer-init.s

	move.b		#$ff,variableSoundEvent														; $ff if no sound event set
	move.w		#1000,variableEngineRevs													; revs are stored at $7cc3c and between 1000 ($3e8) and 7999 ($1f3f) rpm

	move.w		#0,variableEngineEffectPosition												
	move.w		#0,variableSoundEventPosition

mainloop
	move.b		variableVerticalBlankCounter,d0
.waitvbl
	cmp.b		variableVerticalBlankCounter,d0
	beq.s		.waitvbl

	move.b		$fffc02,d0																	; read keyboard scancode from ikbd
	beq			.finishedkeyboardcheck																; if it's empty then there's been no input

	cmp.b		#2,d0
	bne.s		.next1
	cmp.b		#0,variableSoundEvent
	beq			.finishedkeyboardcheck
	move.b		#0,variableSoundEvent
	move.w		#0,variableSoundEventPosition
	bra			.finishedkeyboardcheck
.next1
	cmp.b		#3,d0
	bne.s		.next2	
	cmp.b		#1,variableSoundEvent
	beq			.finishedkeyboardcheck
	move.b		#1,variableSoundEvent
	move.w		#0,variableSoundEventPosition
	bra			.finishedkeyboardcheck
.next2
	cmp.b		#4,d0
	bne.s		.next3	
	cmp.b		#2,variableSoundEvent
	beq			.finishedkeyboardcheck
	move.b		#2,variableSoundEvent
	move.w		#0,variableSoundEventPosition
	bra			.finishedkeyboardcheck
.next3
	cmp.b		#5,d0
	bne.s		.next4	
	cmp.b		#3,variableSoundEvent
	beq			.finishedkeyboardcheck
	move.b		#3,variableSoundEvent
	move.w		#0,variableSoundEventPosition
	bra			.finishedkeyboardcheck
.next4
	cmp.b		#6,d0
	bne.s		.next5	
	cmp.b		#4,variableSoundEvent
	beq			.finishedkeyboardcheck
	move.b		#4,variableSoundEvent
	move.w		#0,variableSoundEventPosition
	bra			.finishedkeyboardcheck
.next5
	cmp.b		#7,d0
	bne.s		.next6	
	cmp.b		#5,variableSoundEvent
	beq			.finishedkeyboardcheck
	move.b		#5,variableSoundEvent
	move.w		#0,variableSoundEventPosition
	bra			.finishedkeyboardcheck
.next6
	cmp.b		#8,d0
	bne.s		.next7	
	cmp.b		#6,variableSoundEvent
	beq			.finishedkeyboardcheck
	move.b		#6,variableSoundEvent
	move.w		#0,variableSoundEventPosition
	bra			.finishedkeyboardcheck
.next7
	cmp.b		#9,d0
	bne.s		.next8
	cmp.b		#7,variableSoundEvent
	beq			.finishedkeyboardcheck	
	move.b		#7,variableSoundEvent
	move.w		#0,variableSoundEventPosition
	bra			.finishedkeyboardcheck
.next8
	cmp.b		#1,d0
	bne.s		.finishedkeyboardcheck
	move.b		#$ff,variableSoundEvent
	move.w		#1000,variableEngineRevs
	subq.b		#2,d0
	move.b		d0,variableSoundEvent

.finishedkeyboardcheck

	add.w		#10,variableEngineRevs															; pretend we've got our foot on the throttle
	cmp.w		#7999,variableEngineRevs															; is engine redlining?
	blo.s		.clamprevsfalse															; if not then keep on trucking
	move.w		#7999,variableEngineRevs															; otherwise let rev limiter kick in
.clamprevsfalse

	bra			mainloop

interruptVerticalBlank
	movem.l		d0-d7/a0-a6,-(sp)

	include		LotusEsprit12517HzMixer-vbl.s

	addq.b		#1,variableVerticalBlankCounter

	movem.l		(sp)+,d0-d7/a0-a6

	rte

	data

	include		LotusEsprit12517HzMixer-data.s

	bss

variableVerticalBlankCounter		ds.b		1
variableEngineRevs					ds.w		1

	include		LotusEsprit12517HzMixer-variables.s