; --- variables used by mixer
bufferAudioMixer					ds.b		500

    align 1
addressAudioCurrentStart			ds.l		1
addressAudioCurrentEnd				ds.l		1
addressAudioWorkingStart			ds.l		1
addressAudioWorkingEnd				ds.l		1

variableP1EngineEffectPosition		ds.w		1
;variableP2EngineEffectPosition		ds.w		1		; not required yet, but probably will be
variableP1SoundEventLatch			ds.w		1
;variableP2SoundEventLatch			ds.w		1		; not required yet, but probably will be
variableP1SoundEventPosition		ds.w		1
;variableP2SoundEventPosition		ds.w		1		; not required yet, but probably will be
