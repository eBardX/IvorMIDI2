# Using IvorMIDI2

Carry MIDI 1.0 and MIDI 2.0 messages in Universal MIDI Packets, and read them
back from a stream of words.

## Overview

A Universal MIDI Packet (UMP) is one to four 32-bit words. The most
significant 4 bits of its first word are its message type, which fixes the
packet’s size and the family of message it carries:

 Message type | Family                            | Type                             | Grouped
:-----------  |:------                            |:----                             |:-------
 0x0          | Utility                           | ``MIDI2UtilityMessage``          | No
 0x1          | System common and real-time       | `MIDISystemMessage` (IvorMIDI)   | Yes
 0x2          | MIDI 1.0 channel voice            | `MIDIChannelMessage` (IvorMIDI)  | Yes
 0x3          | 7-bit system exclusive            | `MIDISystemMessage` (IvorMIDI)   | Yes
 0x4          | MIDI 2.0 channel voice            | ``MIDI2ChannelMessage``          | Yes
 0x5          | System Exclusive 8                | ``MIDI2SystemExclusive8Message`` | Yes
 0xD          | Flex Data                         | ``MIDI2FlexDataMessage``         | Yes
 0xF          | UMP stream                        | ``MIDI2StreamMessage``           | No

A grouped message travels in one of 16 groups, each with 16 channels of its
own. A groupless message addresses the UMP endpoint as a whole.
``MIDI2Message`` wraps a message of any family, together with its group, and
``MIDI2MessageReader`` turns a stream of words into them.

## Packets and groups

A ``MIDI2Packet`` holds exactly as many words as its message type requires;
``MIDI2Packet/init(words:)`` returns `nil` for any other number.
``MIDI2Packet/wordCount(forUniversalMIDIPacket:)`` reads that number from a
first word — including for the reserved message types, so a reader can skip
packets it doesn’t understand.

A ``MIDI2Group`` numbers the groups from 1 to 16, as the MIDI 2.0
specifications do; a packet stores them zero-based. Like the IvorMIDI data
values, it can be written as an integer literal.
``MIDI2Packet/group`` is `nil` for a groupless packet.

## Converting messages

Grouped message types adopt ``MIDI2PacketsConvertible``, which converts a
message to packets in a group, and back:

```swift
let noteOn  = MIDIChannelMessage.noteOn(1, 60, 100)
let packets = noteOn.packets(group: 2)

MIDIChannelMessage(packets: packets!) == noteOn     // true
packets?.first?.group                               // 2
```

The group defaults to 1. A packet carries its group, so the decoding
initializers don’t take one; read it from the first packet’s
``MIDI2Packet/group``. Groupless message types adopt
``MIDI2GrouplessPacketsConvertible`` instead, whose `packets()` takes no group.
Either way, decoding returns `nil` unless the packets encode exactly one valid
message, and encoding returns `nil` for a message that cannot be encoded.
``MIDI2Message`` converts a message of any family the same way.

A MIDI 1.0 channel voice message always fits in one packet, so
`MIDIChannelMessage` also has the single-packet `packet(group:)` and
`init?(packet:)`.

## MIDI 1.0 messages in packets

The IvorMIDI message types travel unchanged in packets, as CoreMIDI’s event
lists carry them. A channel voice message, or a system common or real-time
message, is one single-word packet. A system exclusive message is one two-word
packet for every 6 data bytes, without the 0xF0 and 0xF7 bytes that frame it
on a MIDI 1.0 byte stream:

```swift
let sysEx   = MIDISystemMessage.systemExclusive([0x7e, 0x7f, 0x09, 0x01, 0xf7])
let packets = sysEx.packets()       // words: [0x30047E7F, 0x09010000]
```

## MIDI 2.0 channel voice messages

A ``MIDI2ChannelMessage`` is a two-word packet with more resolution than its
MIDI 1.0 counterpart: 16-bit velocities, and 32-bit controller, pressure, and
pitch bend values. It adds per-note controllers, per-note pitch bend, and
per-note management, and it replaces MIDI 1.0’s control change sequences for
registered and non-registered parameters and bank selection with single
messages:

```swift
// Middle C at full velocity, tuned to 60.5 semitones by its pitch attribute.
let noteOn = MIDI2ChannelMessage.noteOn(1, 60, 0xffff, .pitch(60 << 9 | 256))

// Program 25 in bank 121:1, in one message.
let program = MIDI2ChannelMessage.programChange(1, 25, MIDIData2Value(msb: 121, lsb: 1))

// Pitch bend sensitivity of 2 semitones (in the top 7 bits), in one message.
let bendRange = MIDI2ChannelMessage.registeredController(1, .pitchBendSensitivity, 2 << 25)
```

A note on or note off may carry a ``MIDI2NoteAttribute``: a pitch, as a Q7.9
fixed-point number of semitones, or data whose meaning a manufacturer or a
MIDI-CI profile determines. Unlike MIDI 1.0, a note on with a velocity of zero
is not a note off. A device that uses MIDI 2.0 channel voice messages in a
group must not use MIDI 1.0 channel voice messages in the same group.

## Other MIDI 2.0 messages

- ``MIDI2SystemExclusive8Message`` carries system exclusive data whose bytes
  may use all 8 bits, up to 13 bytes per four-word packet. Its stream ID lets a
  sender interleave several messages. System Exclusive 8 messages cannot be
  translated to MIDI 1.0 byte streams.
- ``MIDI2FlexDataMessage`` carries tempo, time signature, metronome, key
  signature, and chord name events, and metadata and performance text such as
  a song’s name or a lyric. Each is addressed to a channel of its group, or to
  the group as a whole; text spans up to 32 packets.
- ``MIDI2StreamMessage`` discovers a UMP endpoint and its function blocks,
  selects the protocol and jitter reduction timestamps of a stream, and marks
  the start and end of a MIDI Clip File’s sequence data.
- ``MIDI2UtilityMessage`` marks time for the messages that follow it: jitter
  reduction clocks and timestamps, and the delta clockstamps of a MIDI Clip
  File.

```swift
let tempo    = MIDI2FlexDataMessage.setTempo(50_000_000)     // 120 BPM, in 10 ns units
let title    = MIDI2FlexDataMessage.metadataText(.group, .compositionName, "Cooley’s")
let discover = MIDI2StreamMessage.endpointDiscovery(umpVersionMajor: 1,
                                                    umpVersionMinor: 1,
                                                    filter: [.endpointInfo, .endpointName])
```

## Reading a stream

A ``MIDI2MessageReader`` splits a stream of words into packets, reassembles
messages that span several packets, and returns each message once its last
packet arrives. Words may arrive in any grouping: the reader keeps the words
of an incomplete packet until the rest arrive.

```swift
var reader = MIDI2MessageReader()

for words in received {
    for message in reader.read(words: words) {
        handle(message)
    }
}

for message in reader.finish() {    // the packets of any incomplete message
    handle(message)
}
```

The reader follows the UMP specification’s rules for interleaving. Within a
group, a 7-bit system exclusive or Flex Data message may be interleaved only
with system real-time messages and groupless messages such as jitter reduction
clocks; any other packet in the group interrupts it. System Exclusive 8
messages may be interleaved with anything, including each other when their
stream IDs differ. A UMP stream message that spans several packets is
interrupted by any other UMP stream message.

A message that is interrupted, or whose packets do not decode, comes back
packet by packet as ``MIDI2Message/unrecognized(_:)``, as does a packet of a
reserved message type. ``MIDI2MessageReader/finish()`` returns the packets of
any message still incomplete at the end of the stream the same way, and readies
the reader for a new stream.

## Error handling

IvorMIDI2 throws no errors. Decoding returns `nil` for packets that do not
encode exactly one valid message, encoding returns `nil` for a message that
cannot be encoded, and ``MIDI2MessageReader`` reports what it cannot decode as
``MIDI2Message/unrecognized(_:)`` messages rather than failing.

## Concurrency

IvorMIDI2 is built for Swift 6 strict concurrency. Every concrete public type
is a `Sendable` value type, so instances can be freely shared across tasks and
actor boundaries. A ``MIDI2MessageReader`` holds the state of one stream, so
give each stream a reader of its own.
