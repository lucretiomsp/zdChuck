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
p := Performance forMIDIDevice: 'IAC Driver Bus 1'.

'8100' hexBeat  to: #kick .
'0808' hexBeat to: #snare.
'0140' hexBeat to: #rim.
#quavers asRhythm to: #ch.
#upbeats asRhythm to: #oh.
'60/32 , 63/32' asDirtNotes to: #pad.
'48/16' asDirtNotes to: #vox.
'60/4 , 60/4 , 48/56' asDirtNotes to: #bass.
'45 , 57 , 72' asDirtNotes  to: #lead.

```


p freq: 144 bpm.
p playFor: 16 bars.
p stop.
