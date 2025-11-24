```Smalltalk
PortMidi  traceAllDevices .

mout := MIDISender new.

mout openWithDevice: 4.


p := Performance uniqueInstance .
p performer: PerformerMIDI new


#plena asRhythm midiCh:  1 to: #kick ;  index: 2. 
#downbeats asRhythm midiCh: 1 to: #kick. 
#jungleSnare asRhythm midiCh:  2  to: #snare. 
16 banda , 16 rumba midiCh: 2  to:  #snare. 
'0140' hexBeat midiCh: 4 to: #rim. 

'8888' hexBeat midiCh:   5 to: #ch. 
#upbeats asRhythm midiCh: 6 to: #oh. 
'60/16 , 62/16 , 63/16 , 65/16'  asDirtNotes midiCh: 7 to: #pad; gateTimes: 1. 
'60/64' asDirtNotes midiCh: 9 to: #vox ; index: 3 . 
'60/4 , 60/4 , 48/56' asDirtNotes midiCh:  3 to: #bass; index: '0 '.
'72, 75 , 67 , 58 , 79, ~ 81 , 36 , ~ ' asDirtNotes midiCh: 8 to: #lead. 
#rumba asRhythm index: '1 , 2 , 5 * 2, 3'; midiCh: 10 to: #perc.
'1 , ~ , 2 , 3  , ~ *2 ,  4 , 5 '  asDirtIndex midiCh:  4  to: #rim. 
('48 / 4,  36 / 4 , 72 /8' asDirtNotes  midiCh: 3  to: #bass) index: '1 , 2 , 3' . 

p solo: #bass.
p mute: #bass.
p solo: #lead.
p freq: 144 bpm.
p playFor: 128 bars.
p stop.

p muteAll.
```