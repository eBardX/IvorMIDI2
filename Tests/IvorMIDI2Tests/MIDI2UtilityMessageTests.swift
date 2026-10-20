// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI2
import Testing

struct MIDI2UtilityMessageTests {
}

// MARK: -

extension MIDI2UtilityMessageTests {
    @Test
    func init_packets() {
        #expect(MIDI2UtilityMessage(words: [0x00000000]) == .noop)
        #expect(MIDI2UtilityMessage(words: [0x00101234]) == .jrClock(0x1234))
        #expect(MIDI2UtilityMessage(words: [0x0020ffff]) == .jrTimestamp(0xffff))
        #expect(MIDI2UtilityMessage(words: [0x003001e0]) == .deltaClockstampTicksPerQuarterNote(480))
        #expect(MIDI2UtilityMessage(words: [0x004fffff]) == .deltaClockstamp(0xfffff))
        #expect(MIDI2UtilityMessage(words: [0x0f101234]) == .jrClock(0x1234))      // reserved bits ignored
    }

    @Test
    func init_packets_invalid() {
        #expect(MIDI2UtilityMessage(packets: []) == nil)
        #expect(MIDI2UtilityMessage(words: [0x00000000, 0x00000000]) == nil)      // two packets
        #expect(MIDI2UtilityMessage(words: [0x00500000]) == nil)                  // reserved status
        #expect(MIDI2UtilityMessage(words: [0x00300000]) == nil)                  // zero ticks per quarter note
        #expect(MIDI2UtilityMessage(words: [0x10f80000]) == nil)                  // a system message
    }

    @Test
    func packets() {
        #expect(MIDI2UtilityMessage.noop.words() == [0x00000000])
        #expect(MIDI2UtilityMessage.jrClock(0x1234).words() == [0x00101234])
        #expect(MIDI2UtilityMessage.jrTimestamp(0xffff).words() == [0x0020ffff])
        #expect(MIDI2UtilityMessage.deltaClockstampTicksPerQuarterNote(480).words() == [0x003001e0])
        #expect(MIDI2UtilityMessage.deltaClockstamp(0xfffff).words() == [0x004fffff])
    }

    @Test
    func packets_groupless() throws {
        let packets = try #require(MIDI2UtilityMessage.jrClock(1).packets())

        #expect(packets[0].group == nil)
    }

    @Test
    func packets_invalid() {
        #expect(MIDI2UtilityMessage.deltaClockstamp(0x100000).packets() == nil)
        #expect(MIDI2UtilityMessage.deltaClockstampTicksPerQuarterNote(0).packets() == nil)
    }

    @Test
    func roundTrip() throws {
        let messages: [MIDI2UtilityMessage] = [.deltaClockstamp(0),
                                               .deltaClockstamp(1_048_575),
                                               .deltaClockstampTicksPerQuarterNote(1),
                                               .deltaClockstampTicksPerQuarterNote(65_535),
                                               .jrClock(0),
                                               .jrTimestamp(31_250),
                                               .noop]

        for message in messages {
            let packets = try #require(message.packets())

            #expect(MIDI2UtilityMessage(packets: packets) == message)
        }
    }
}
