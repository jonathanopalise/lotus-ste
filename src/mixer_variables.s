; --- variables used by mixer
    align 1
addressAudioCurrentStart			ds.l		1
addressAudioWorkingStart			ds.l		1
addressAudioCurrentEnd				ds.l		1
addressAudioWorkingEnd				ds.l		1

variableEngineEffectPosition		ds.w		1
variableSoundEvent					ds.b		1
    align 1
variableSoundEventPosition			ds.w		1

bufferAudioCurrent					ds.b		250
bufferAudioWorking					ds.b		250

; remove later
variableEngineRevs                  ds.w        1
