// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI2
import Testing
import XestiTools

struct MIDI2SystemExclusive8MessageTests {
}

// MARK: -

extension MIDI2SystemExclusive8MessageTests {
    @Test
    func init_packets() {
        #expect(MIDI2SystemExclusive8Message(words: [0x50040043, 0x10ff0000, 0x00000000, 0x00000000])
                    == MIDI2SystemExclusive8Message(data: [0x43, 0x10, 0xff]))
        #expect(MIDI2SystemExclusive8Message(words: [0x5f012a00, 0x00000000, 0x00000000, 0x00000000])
                    == MIDI2SystemExclusive8Message(streamID: 0x2a, data: []))
    }

    @Test
    func init_packets_invalid() {
        #expect(MIDI2SystemExclusive8Message(packets: []) == nil)
        #expect(MIDI2SystemExclusive8Message(words: [0x50000000, 0, 0, 0]) == nil)                     // no stream ID
        #expect(MIDI2SystemExclusive8Message(words: [0x500f0000, 0, 0, 0]) == nil)                     // 15 bytes
        #expect(MIDI2SystemExclusive8Message(words: [0x50800000, 0, 0, 0]) == nil)                     // mixed data set header
        #expect(MIDI2SystemExclusive8Message(words: [0x501e0001, 0, 0, 0]) == nil)                     // start, no end
        #expect(MIDI2SystemExclusive8Message(words: [0x501e0001, 0, 0, 0, 0x503f0000, 0, 0, 0]) == nil)  // aborted
        #expect(MIDI2SystemExclusive8Message(words: [0x501e0001, 0, 0, 0, 0x51310000, 0, 0, 0]) == nil)  // mixed groups
        #expect(MIDI2SystemExclusive8Message(words: [0x501e0001, 0, 0, 0, 0x50310100, 0, 0, 0]) == nil)  // mixed stream IDs
        #expect(MIDI2SystemExclusive8Message(words: [0x40903c00, 0xffff0000]) == nil)                  // MIDI 2.0 channel voice
    }

    @Test
    func packets() {
        #expect(MIDI2SystemExclusive8Message(data: [0x00, 0x43, 0x10, 0xff]).words()
                    == [0x50050000, 0x4310ff00, 0x00000000, 0x00000000])
        #expect(MIDI2SystemExclusive8Message(streamID: 7, data: []).words()
                    == [0x50010700, 0x00000000, 0x00000000, 0x00000000])
    }

    @Test
    func packets_group() {
        #expect(MIDI2SystemExclusive8Message(data: [0xff]).words(group: 16)
                    == [0x5f0200ff, 0x00000000, 0x00000000, 0x00000000])
    }

    @Test
    func packets_multiplePackets() {
        let message = MIDI2SystemExclusive8Message(streamID: 1,
                                                   data: Array(UInt8(1)...27))

        #expect(message.words() == [0x501e0101,
                                    0x02030405,
                                    0x06070809,
                                    0x0a0b0c0d,     // start, 13 bytes
                                    0x502e010e,
                                    0x0f101112,
                                    0x13141516,
                                    0x1718191a,     // continue, 13 bytes
                                    0x5032011b,
                                    0x00000000,
                                    0x00000000,
                                    0x00000000])    // end, 1 byte
    }

    @Test
    func roundTrip() throws {
        let messages = [MIDI2SystemExclusive8Message(data: []),
                        MIDI2SystemExclusive8Message(data: Array(0...12)),
                        MIDI2SystemExclusive8Message(data: Array(0...13)),
                        MIDI2SystemExclusive8Message(streamID: 255, data: Array(0...255))]

        for message in messages {
            for group: MIDI2Group in [1, 16] {
                let packets = try #require(message.packets(group: group))

                #expect(MIDI2SystemExclusive8Message(packets: packets) == message)
                #expect(packets.allSatisfy { $0.group == group })
            }
        }
    }
}
