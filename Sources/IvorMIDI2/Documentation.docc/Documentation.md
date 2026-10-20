# ``IvorMIDI2``

@Metadata {
    @PageColor(blue)
}

Universal MIDI Packet (UMP) group and message encoding types.

## Overview

The IvorMIDI2 framework provides [Universal MIDI Packet][ump] support written in
Swift, building on the message and data value types of ``IvorMIDI``. A UMP
group number addresses one of the 16 groups of a packet stream, and a UMP
packet holds the one to four 32-bit words that its message type requires. The
channel and system messages of IvorMIDI can be converted to and from MIDI 1.0
Universal MIDI Packets, as CoreMIDI’s event lists carry them: channel voice
messages as single-word packets of message type 0x2, system common and
real-time messages as single-word packets of message type 0x1, and system
exclusive messages as two-word packets of message type 0x3. The MIDI 2.0
message families have types of their own: utility messages, MIDI 2.0 channel
voice messages, System Exclusive 8 messages, Flex Data messages, and UMP stream
messages. A message reader turns a stream of 32-bit words into messages of
every family, reassembling those that span several packets.

```swift
import IvorMIDI
import IvorMIDI2

// Middle C, velocity 127, on channel 1 of group 6.
let noteOn = MIDIChannelMessage.noteOn(1, 60, 127)
let packet = noteOn.packet(group: 6)               // words: [0x25903C7F]

// Decode the message and its group from a packet.
if let received = MIDI2Packet(words: [0x25903c7f]) {
    MIDIChannelMessage(packet: received) == noteOn // true
    received.group                                 // 6
}

// Read the messages of a stream of words, in any grouping.
var reader = MIDI2MessageReader()

reader.read(words: [0x45903c00])                   // []: half a packet
reader.read(words: [0xffff0000])                   // [.midi2ChannelVoice(.noteOn(1, 60, 65535, nil), 6)]
```

Every concrete public type is a `Sendable` value type, so instances can be
freely shared across tasks and actor boundaries.

[ump]: https://midi.org/universal-midi-packet-ump-and-midi-2-0-protocol-specification

## Topics

### Data values

- ``MIDI2Group``

### Reading messages

- ``MIDI2Message``
- ``MIDI2MessageReader``

### Packets

- ``MIDI2Packet``
- ``MIDI2PacketsConvertible``
- ``MIDI2GrouplessPacketsConvertible``

### Utility messages

- ``MIDI2UtilityMessage``

### MIDI 2.0 channel voice messages

- ``MIDI2ChannelMessage``
- ``MIDI2NoteAttribute``

### System Exclusive 8 messages

- ``MIDI2SystemExclusive8Message``

### Flex Data messages

- ``MIDI2FlexDataMessage``

### UMP stream messages

- ``MIDI2StreamMessage``
