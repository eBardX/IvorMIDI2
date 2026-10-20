// © 2026 John Gary Pusey (see LICENSE.md)

import IvorMIDI
@testable import IvorMIDI2
import Testing
import XestiTools

struct MIDISystemMessageUMPTests {
}

// MARK: -

extension MIDISystemMessageUMPTests {
    @Test
    func init_packets_invalid() {
        #expect(MIDISystemMessage(packets: []) == nil)
        #expect(MIDISystemMessage(words: [0x20903c7f]) == nil)          // a channel voice message
        #expect(MIDISystemMessage(words: [0x10f80000, 0x10fa0000]) == nil)
        #expect(MIDISystemMessage(words: [0x10f00000]) == nil)          // F0 belongs in type 0x3
        #expect(MIDISystemMessage(words: [0x10f70000]) == nil)          // so does F7
        #expect(MIDISystemMessage(words: [0x10f40000]) == nil)          // undefined status
        #expect(MIDISystemMessage(words: [0x10f18000]) == nil)          // not a data byte
    }

    @Test
    func init_packets_invalidSysEx() {
        #expect(MIDISystemMessage(words: [0x30000000, 0x00000000]) == nil)  // no data
        #expect(MIDISystemMessage(words: [0x30070102, 0x03040506]) == nil)  // 7 bytes
        #expect(MIDISystemMessage(words: [0x30027e80, 0x00000000]) == nil)  // not a data byte
        #expect(MIDISystemMessage(words: [0x30160102, 0x03040506]) == nil)  // start, no end
        #expect(MIDISystemMessage(words: [0x30310700, 0x00000000]) == nil)  // end, no start
        #expect(MIDISystemMessage(words: [0x30010100,
                                          0x00000000,
                                          0x30010200,
                                          0x00000000]) == nil)  // two complete
        #expect(MIDISystemMessage(words: [0x30160102,
                                          0x03040506,
                                          0x31310700,
                                          0x00000000]) == nil)  // mixed groups
        #expect(MIDISystemMessage(words: [0x30160102,
                                          0x03040506,
                                          0x10f80000,
                                          0x00000000]) == nil)  // mixed types
    }

    @Test
    func packets() {
        #expect(MIDISystemMessage.timingClock.words() == [0x10f80000])
        #expect(MIDISystemMessage.start.words() == [0x10fa0000])
        #expect(MIDISystemMessage.continue.words() == [0x10fb0000])
        #expect(MIDISystemMessage.stop.words() == [0x10fc0000])
        #expect(MIDISystemMessage.activeSensing.words() == [0x10fe0000])
        #expect(MIDISystemMessage.systemReset.words() == [0x10ff0000])
        #expect(MIDISystemMessage.tuneRequest.words() == [0x10f60000])
        #expect(MIDISystemMessage.mtcQuarterFrame(0x35).words() == [0x10f13500])
        #expect(MIDISystemMessage.songPosition(8_192).words() == [0x10f20040])
        #expect(MIDISystemMessage.songSelect(5).words() == [0x10f30500])
    }

    @Test
    func packets_eox() {
        #expect(MIDISystemMessage.eox.packets() == nil)
    }

    @Test
    func packets_group() {
        #expect(MIDISystemMessage.timingClock.words(group: 6) == [0x15f80000])
        #expect(MIDISystemMessage.timingClock.words(group: 16) == [0x1ff80000])
        #expect(MIDISystemMessage.systemExclusive([0x01, 0xf7]).words(group: 16) == [0x3f010100,
                                                                                     0x00000000])
    }

    @Test
    func packets_sysExInvalid() {
        #expect(MIDISystemMessage.systemExclusive([0xf7]).packets() == nil)        // no data
        #expect(MIDISystemMessage.systemExclusive([0x7e, 0x7f]).packets() == nil)  // no EOX
        #expect(MIDISystemMessage.systemExclusive([0x7e, 0x80, 0xf7]).packets() == nil)
    }

    @Test
    func packets_sysExMultiplePackets() {
        let message = MIDISystemMessage.systemExclusive(Array(UInt8(1)...13) + [0xf7])

        #expect(message.packets()?.map(\.words) == [[0x30160102, 0x03040506],   // start, 6 bytes
                                                    [0x30260708, 0x090a0b0c],   // continue, 6 bytes
                                                    [0x30310d00, 0x00000000]])  // end, 1 byte
    }

    @Test
    func packets_sysExOnePacket() {
        #expect(MIDISystemMessage.systemExclusive([0x7e, 0x7f, 0xf7]).words() == [0x30027e7f,
                                                                                  0x00000000])
        #expect(MIDISystemMessage.systemExclusive([0x7e, 0x7f, 0x09, 0x01, 0xf7]).words() == [0x30047e7f,
                                                                                              0x09010000])
        #expect(MIDISystemMessage.systemExclusive(Array(UInt8(1)...6) + [0xf7]).words() == [0x30060102,
                                                                                            0x03040506])
    }

    @Test
    func packets_sysExTwoPackets() {
        let message = MIDISystemMessage.systemExclusive(Array(UInt8(1)...7) + [0xf7])

        #expect(message.packets()?.map(\.words) == [[0x30160102, 0x03040506],   // start, 6 bytes
                                                    [0x30310700, 0x00000000]])  // end, 1 byte
    }

    @Test
    func roundTrip() throws {
        let messages: [MIDISystemMessage] = [.activeSensing,
                                             .continue,
                                             .mtcQuarterFrame(0x35),
                                             .songPosition(8_192),
                                             .songSelect(5),
                                             .start,
                                             .stop,
                                             .systemExclusive([0x7e, 0x7f, 0xf7]),
                                             .systemExclusive(Array(repeating: 0x42, count: 20) + [0xf7]),
                                             .systemReset,
                                             .timingClock,
                                             .tuneRequest]

        for message in messages {
            for group: MIDI2Group in [1, 16] {
                let packets = try #require(message.packets(group: group))

                #expect(MIDISystemMessage(packets: packets) == message)
                #expect(packets.allSatisfy { $0.group == group })
            }
        }
    }
}
