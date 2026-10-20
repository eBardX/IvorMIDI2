// © 2026 John Gary Pusey (see LICENSE.md)

import IvorMIDI
@testable import IvorMIDI2
import Testing
import XestiTools

struct MIDI2PacketsConvertibleTests {
    private let values: [any MIDI2PacketsConvertible] = [MIDIChannelMessage.noteOn(1, 60, 127),
                                                         MIDISystemMessage.systemExclusive(Array(1...20) + [0xf7]),
                                                         MIDI2ChannelMessage.pitchBendChange(2, 0x80000000),
                                                         MIDI2SystemExclusive8Message(data: Array(0...30)),
                                                         MIDI2FlexDataMessage.setTempo(50_000_000)]
}

// MARK: -

extension MIDI2PacketsConvertibleTests {
    @Test
    func init_packets() throws {
        for value in values {
            let packets = try #require(value.packets(group: 16))
            let decoded = try #require(type(of: value).init(packets: packets))

            #expect(decoded.packets(group: 16) == packets)
        }
    }

    @Test
    func init_packets_empty() {
        for value in values {
            #expect(type(of: value).init(packets: []) == nil)
        }
    }

    @Test
    func packets_group() throws {
        for value in values {
            for group: MIDI2Group in [1, 6, 16] {
                let packets = try #require(value.packets(group: group))

                #expect(packets.allSatisfy { $0.group == group })
            }
        }
    }
}
