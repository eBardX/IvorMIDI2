# IvorMIDI2

Universal MIDI Packet (UMP) group and message encoding types.

[![Swift 6.3](https://img.shields.io/badge/Swift-6.3-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20macOS-lightgrey.svg)](https://developer.apple.com)
[![SwiftPM](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/eBardX/IvorMIDI2/blob/main/LICENSE.md)

* [Overview](#overview)
* [Requirements](#requirements)
* [Installation](#installation)
    * [Swift Package Manager](#spm_installation)
* [Quick Start](#quick_start)
* [Reference Documentation](#reference_documentation)
* [Credits](#credits)
* [License](#license)

## <a name="overview">Overview</a>

The IvorMIDI2 framework provides [Universal MIDI Packet][ump] support written in
Swift, building on the message and data value types of [IvorMIDI][ivormidi]. A
UMP group number addresses one of the 16 groups of a packet stream, and a UMP
packet holds the one to four 32-bit words that its message type requires. The
channel and system messages of IvorMIDI can be converted to and from MIDI 1.0
Universal MIDI Packets, as CoreMIDI's event lists carry them: channel voice
messages as single-word packets of message type 0x2, system common and
real-time messages as single-word packets of message type 0x1, and system
exclusive messages as two-word packets of message type 0x3. The MIDI 2.0
message families have types of their own: utility messages, MIDI 2.0 channel
voice messages, System Exclusive 8 messages, Flex Data messages, and UMP stream
messages. A message reader turns a stream of 32-bit words into messages of
every family, reassembling those that span several packets.

## <a name="requirements">Requirements</a>

* iOS 18.0+ / macOS 15.0+
* Swift 6.3 toolchain
* Swift 6 language mode

## <a name="installation">Installation</a>

### <a name="spm_installation">Swift Package Manager</a>

IvorMIDI2 is distributed exclusively through the [Swift Package Manager][spm].

To add IvorMIDI2 to a Swift package, add it to the `dependencies` in your
`Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/eBardX/IvorMIDI2.git",
             .upToNextMinor(from: "0.1.0"))
]
```

Then add `IvorMIDI2` to the dependencies of any target that uses it:

```swift
.target(name: "MyTarget",
        dependencies: [.product(name: "IvorMIDI2",
                                package: "IvorMIDI2")])
```

To add IvorMIDI2 to an Xcode project, choose **File ▸ Add Package
Dependencies…** and enter the repository URL:

```
https://github.com/eBardX/IvorMIDI2.git
```

IvorMIDI2 depends on [IvorMIDI][ivormidi] and [XestiTools][xestitools];
the Swift Package Manager resolves them automatically.

## <a name="quick_start">Quick Start</a>

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

// A system exclusive message spans one two-word packet per 6 data bytes.
let sysEx = MIDISystemMessage.systemExclusive([0x7e, 0x7f, 0x09, 0x01, 0xf7])
let packets = sysEx.packets()                      // words: [0x30047E7F, 0x09010000]

// Read the messages of a stream of words, in any grouping.
var reader = MIDI2MessageReader()

reader.read(words: [0x45903c00])                   // []: half a packet
reader.read(words: [0xffff0000])                   // [.midi2ChannelVoice(.noteOn(1, 60, 65535, nil), 6)]
```

## <a name="reference_documentation">Reference Documentation</a>

Full [reference documentation][refdoc] is available courtesy of [DocC][docc].

## <a name="credits">Credits</a>

John Gary Pusey (ebardx@gmail.com)

## <a name="license">License</a>

IvorMIDI2 is available under [the MIT license][license].

[docc]:         https://www.swift.org/documentation/docc/
[ivormidi]:     https://github.com/eBardX/IvorMIDI
[license]:      https://github.com/eBardX/IvorMIDI2/blob/main/LICENSE.md
[refdoc]:       https://eBardX.github.io/ivor-packages-docs/documentation/ivormidi2
[spm]:          https://swift.org/package-manager/
[ump]:          https://midi.org/universal-midi-packet-ump-and-midi-2-0-protocol-specification
[xestitools]:   https://github.com/eBardX/XestiTools
