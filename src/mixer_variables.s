; --- variables used by mixer
bufferAudioMixer					ds.b		500

    align 1
addressAudioCurrentStart			ds.l		1
addressAudioCurrentEnd				ds.l		1
addressAudioWorkingStart			ds.l		1
addressAudioWorkingEnd				ds.l		1

variableP1EngineEffectPosition		ds.w		1
variableP1SoundEventLatch			ds.w		1
variableP1SoundEventAddress			ds.l		1
variableP1SoundEventLength			ds.w		1
variableP1SoundEventRetrigPeriod	ds.w		1
variableP1SoundEventPosition		ds.w		1
