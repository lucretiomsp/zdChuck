##Defaut channels 
This is the default MIDI channels mapping:
```smalltalk
PerformerMIDI >>> factoryChannels

	^ {
		  (#kick -> 1). (#snare -> 2). (#bass -> 3). (#rim -> 4). (#ch -> 5). (#oh -> 6). (#pad -> 7). (#lead -> 8). (#vox -> 9).
		  (#perc -> 10). (#drums -> 11). (#percLoop -> 12). (#bassLoop -> 13). (#chordLoop -> 14). (#synthLoop -> 15) } asDictionary
```

## Example Playground script
```smalltalk
PortMidi  traceAllDevices .

mout := MIDISender new.

mout openWithDevice: 4.


p := Performance uniqueInstance .
p performer: PerformerMIDI new


'8100' hexBeat midiCh: 1 to: #kick .
#downbeats asRhythm midiCh: 1 to: #kick.
'0808' hexBeat midiCh: 2 to: #snare.
'0140' hexBeat midiCh: 4 to: #rim.
#quavers asRhythm midiCh:  5 to: #ch.
#upbeats asRhythm midiCh: 6 to: #oh.
'60/32' asDirtNotes midiCh: 7 to: #pad; gateTimes: 1.
'60/16' asDirtNotes midiCh: 9 to: #vox.
'60/4 , 60/4 , 48/56' asDirtNotes midiCh:  3 to: #bass.
'45/16 , 56/ 16 , 65 /16 , 72/16' asDirtNotes midiCh: 8 to: #lead.
#rumba asRhythm index: '1 , 2 , 3'; midiCh: 10 to: #perc.
"bass is lighthouse dimension Y"

```

p solo: #vox.
p mute: #bass.
p solo: #lead.
p freq: 144 bpm.
p playFor: 16 bars.
p stop.
