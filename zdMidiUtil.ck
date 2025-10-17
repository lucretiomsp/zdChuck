// Domenico Cipriani 2025
// Basic utility class to parse MIDI messages

public class ZdMidiMsg extends MidiMsg {

 fun int isCC () {
    if (data1 >= 175 && data1 <= 191 )
    { return 1; } else { return 0;}
 }

}