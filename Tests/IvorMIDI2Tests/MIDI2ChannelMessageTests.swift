// © 2026 John Gary Pusey (see LICENSE.md)

import IvorMIDI
@testable import IvorMIDI2
import Testing
import XestiTools

struct MIDI2ChannelMessageTests {
}

// MARK: -

extension MIDI2ChannelMessageTests {
    @Test
    func channel() {
        #expect(MIDI2ChannelMessage.noteOn(5, 60, 0xffff, nil).channel == 5)
        #expect(MIDI2ChannelMessage.pitchBendChange(16, 0x80000000).channel == 16)
        #expect(MIDI2ChannelMessage.registeredController(1, 7, 0).channel == 1)
    }

    @Test
    func init_packets() {
        #expect(MIDI2ChannelMessage(words: [0x40903c00, 0xffff0000]) == .noteOn(1, 60, 0xffff, nil))
        #expect(MIDI2ChannelMessage(words: [0x40813c03, 0x80007800]) == .noteOff(2, 60, 0x8000, .pitch(0x7800)))
        #expect(MIDI2ChannelMessage(words: [0x40a03c00, 0x12345678]) == .polyphonicPressure(1, 60, 0x12345678))
        #expect(MIDI2ChannelMessage(words: [0x40003c03, 0xffffffff]) == .registeredPerNoteController(1, 60, 3, 0xffffffff))
        #expect(MIDI2ChannelMessage(words: [0x401f3cff, 0x00000001]) == .assignablePerNoteController(16, 60, 0xff, 1))
        #expect(MIDI2ChannelMessage(words: [0x40200007, 0x10000000]) == .registeredController(1, 7, 0x10000000))
        #expect(MIDI2ChannelMessage(words: [0x40301234, 0x00000001]) == .assignableController(1, 2_356, 1))
        #expect(MIDI2ChannelMessage(words: [0x40400007, 0xffffffff]) == .relativeRegisteredController(1, 7, -1))
        #expect(MIDI2ChannelMessage(words: [0x40501234, 0x00000001]) == .relativeAssignableController(1, 2_356, 1))
        #expect(MIDI2ChannelMessage(words: [0x40603c00, 0x80000000]) == .perNotePitchBendChange(1, 60, 0x80000000))
        #expect(MIDI2ChannelMessage(words: [0x40b04000, 0xffffffff]) == .controlChange(1, .sustain, 0xffffffff))
        #expect(MIDI2ChannelMessage(words: [0x40c00000, 0x00000000]) == .programChange(1, 1, nil))
        #expect(MIDI2ChannelMessage(words: [0x40c20001, 0x7f000102]) == .programChange(3, 128, 130))
        #expect(MIDI2ChannelMessage(words: [0x40d00000, 0x80000000]) == .channelPressure(1, 0x80000000))
        #expect(MIDI2ChannelMessage(words: [0x40e00000, 0x80000000]) == .pitchBendChange(1, 0x80000000))
        #expect(MIDI2ChannelMessage(words: [0x40f03c03, 0x00000000]) == .perNoteManagement(1, 60, detach: true, reset: true))
        #expect(MIDI2ChannelMessage(words: [0x40f03c02, 0x00000000]) == .perNoteManagement(1, 60, detach: true, reset: false))
    }

    @Test
    func init_packets_ignoresReservedFields() {
        #expect(MIDI2ChannelMessage(words: [0x4090bc00, 0xffff0000]) == .noteOn(1, 60, 0xffff, nil))           // note’s high bit
        #expect(MIDI2ChannelMessage(words: [0x40903c00, 0xffff1234]) == .noteOn(1, 60, 0xffff, nil))           // no attribute, data
        #expect(MIDI2ChannelMessage(words: [0x40c20000, 0x7f000102]) == .programChange(3, 128, nil))           // no bank, bank fields
        #expect(MIDI2ChannelMessage(words: [0x40d0ffff, 0x80000000]) == .channelPressure(1, 0x80000000))
    }

    @Test
    func init_packets_invalid() throws {
        let packet = try #require(MIDI2Packet(words: [0x40903c00, 0xffff0000]))

        #expect(MIDI2ChannelMessage(packets: []) == nil)
        #expect(MIDI2ChannelMessage(packets: [packet, packet]) == nil)
        #expect(MIDI2ChannelMessage(words: [0x20903c7f]) == nil)                      // MIDI 1.0 channel voice
        #expect(MIDI2ChannelMessage(words: [0x40700000, 0x00000000]) == nil)          // reserved status
        #expect(MIDI2ChannelMessage(words: [0x40903c04, 0xffff0000]) == nil)          // reserved attribute type
    }

    @Test
    func packets() {
        #expect(MIDI2ChannelMessage.noteOn(1, 60, 0xffff, nil).words() == [0x40903c00, 0xffff0000])
        #expect(MIDI2ChannelMessage.noteOff(2, 60, 0x8000, .pitch(0x7800)).words() == [0x40813c03, 0x80007800])
        #expect(MIDI2ChannelMessage.noteOn(1, 60, 1, .manufacturerSpecific(0xabcd)).words() == [0x40903c01, 0x0001abcd])
        #expect(MIDI2ChannelMessage.noteOn(1, 60, 1, .profileSpecific(0xabcd)).words() == [0x40903c02, 0x0001abcd])
        #expect(MIDI2ChannelMessage.polyphonicPressure(1, 60, 0x12345678).words() == [0x40a03c00, 0x12345678])
        #expect(MIDI2ChannelMessage.registeredPerNoteController(1, 60, 3, 0xffffffff).words() == [0x40003c03, 0xffffffff])
        #expect(MIDI2ChannelMessage.assignablePerNoteController(16, 60, 0xff, 1).words() == [0x401f3cff, 0x00000001])
        #expect(MIDI2ChannelMessage.registeredController(1, 7, 0x10000000).words() == [0x40200007, 0x10000000])
        #expect(MIDI2ChannelMessage.assignableController(1, 2_356, 1).words() == [0x40301234, 0x00000001])
        #expect(MIDI2ChannelMessage.relativeRegisteredController(1, 7, -1).words() == [0x40400007, 0xffffffff])
        #expect(MIDI2ChannelMessage.relativeAssignableController(1, 2_356, 1).words() == [0x40501234, 0x00000001])
        #expect(MIDI2ChannelMessage.perNotePitchBendChange(1, 60, 0x80000000).words() == [0x40603c00, 0x80000000])
        #expect(MIDI2ChannelMessage.controlChange(1, .sustain, 0xffffffff).words() == [0x40b04000, 0xffffffff])
        #expect(MIDI2ChannelMessage.programChange(1, 1, nil).words() == [0x40c00000, 0x00000000])
        #expect(MIDI2ChannelMessage.programChange(3, 128, 130).words() == [0x40c20001, 0x7f000102])
        #expect(MIDI2ChannelMessage.channelPressure(1, 0x80000000).words() == [0x40d00000, 0x80000000])
        #expect(MIDI2ChannelMessage.pitchBendChange(1, 0x80000000).words() == [0x40e00000, 0x80000000])
        #expect(MIDI2ChannelMessage.perNoteManagement(1, 60, detach: true, reset: true).words() == [0x40f03c03, 0x00000000])
        #expect(MIDI2ChannelMessage.perNoteManagement(1, 60, detach: false, reset: true).words() == [0x40f03c01, 0x00000000])
    }

    @Test
    func packets_group() {
        #expect(MIDI2ChannelMessage.noteOn(1, 60, 0xffff, nil).words(group: 6) == [0x45903c00, 0xffff0000])
        #expect(MIDI2ChannelMessage.noteOn(1, 60, 0xffff, nil).words(group: 16) == [0x4f903c00, 0xffff0000])
    }

    @Test
    func roundTrip() throws {
        let messages: [MIDI2ChannelMessage] = [.assignableController(2, 16_383, 0xdeadbeef),
                                               .assignablePerNoteController(3, 0, 0, 0),
                                               .channelPressure(4, 0),
                                               .controlChange(5, .modulationWheelMSB, 0x7fffffff),
                                               .noteOff(6, 127, 0, .manufacturerSpecific(1)),
                                               .noteOn(7, 0, 0, nil),
                                               .noteOn(8, 69, 0x8000, .pitch(69 << 9)),
                                               .perNoteManagement(9, 64, detach: false, reset: false),
                                               .perNotePitchBendChange(10, 64, 0),
                                               .pitchBendChange(11, 0xffffffff),
                                               .polyphonicPressure(12, 64, 1),
                                               .programChange(13, 64, 0),
                                               .programChange(14, 64, 16_383),
                                               .registeredController(15, 0, 0),
                                               .registeredPerNoteController(16, 127, 255, 1),
                                               .relativeAssignableController(1, 128, .min),
                                               .relativeRegisteredController(1, 129, .max)]

        for message in messages {
            for group: MIDI2Group in [1, 16] {
                let packets = try #require(message.packets(group: group))

                #expect(MIDI2ChannelMessage(packets: packets) == message)
                #expect(packets.count == 1)
                #expect(packets[0].group == group)
            }
        }
    }
}
