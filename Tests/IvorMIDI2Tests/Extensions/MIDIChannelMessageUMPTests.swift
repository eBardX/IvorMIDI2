// © 2026 John Gary Pusey (see LICENSE.md)

import IvorMIDI
@testable import IvorMIDI2
import Testing
import XestiTools

struct MIDIChannelMessageUMPTests {
}

// MARK: -

extension MIDIChannelMessageUMPTests {
    @Test
    func init_packet() {
        #expect(MIDIChannelMessage(word: 0x20903c7f) == .noteOn(1, 60, 127))
        #expect(MIDIChannelMessage(word: 0x20813c00) == .noteOff(2, 60, 0))
        #expect(MIDIChannelMessage(word: 0x20bf4040) == .controlChange(16, .sustain, 64))
        #expect(MIDIChannelMessage(word: 0x20c20400) == .programChange(3, 5))
        #expect(MIDIChannelMessage(word: 0x20d00900) == .channelPressure(1, 9))
        #expect(MIDIChannelMessage(word: 0x20e07f7f) == .pitchBendChange(1, 8_191))
        #expect(MIDIChannelMessage(word: 0x2fa03c40) == .polyphonicPressure(1, 60, 64))     // group 16
        #expect(MIDIChannelMessage(word: 0x20c204ff) == .programChange(3, 5))               // unused byte ignored
    }

    @Test
    func init_packet_invalid() {
        #expect(MIDIChannelMessage(word: 0x10903c7f) == nil)    // system message type
        #expect(MIDIChannelMessage(word: 0x20f80000) == nil)    // system status
        #expect(MIDIChannelMessage(word: 0x20403c7f) == nil)    // not a status byte
        #expect(MIDIChannelMessage(word: 0x2090803c) == nil)    // not a data byte
    }

    @Test
    func init_packet_midi2ChannelVoice() throws {
        let packet = try #require(MIDI2Packet(words: [0x40903c00, 0xffff0000]))

        #expect(MIDIChannelMessage(packet: packet) == nil)
    }

    @Test
    func init_packets() throws {
        let packet = try #require(MIDI2Packet(words: [0x20903c7f]))

        #expect(MIDIChannelMessage(packets: [packet]) == .noteOn(1, 60, 127))
    }

    @Test
    func init_packets_invalid() throws {
        let packet = try #require(MIDI2Packet(words: [0x20903c7f]))

        #expect(MIDIChannelMessage(packets: []) == nil)
        #expect(MIDIChannelMessage(packets: [packet, packet]) == nil)
    }

    @Test
    func packet() {
        #expect(MIDIChannelMessage.noteOn(1, 60, 127).packet()?.words == [0x20903c7f])
        #expect(MIDIChannelMessage.noteOff(2, 60, 0).packet()?.words == [0x20813c00])
        #expect(MIDIChannelMessage.controlChange(16, .sustain, 64).packet()?.words == [0x20bf4040])
        #expect(MIDIChannelMessage.programChange(3, 5).packet()?.words == [0x20c20400])
        #expect(MIDIChannelMessage.channelPressure(1, 9).packet()?.words == [0x20d00900])
        #expect(MIDIChannelMessage.pitchBendChange(1, 8_191).packet()?.words == [0x20e07f7f])
    }

    @Test
    func packet_group() {
        let msg = MIDIChannelMessage.noteOn(1, 60, 127)

        #expect(msg.packet()?.words == [0x20903c7f])
        #expect(msg.packet(group: 1)?.words == [0x20903c7f])
        #expect(msg.packet(group: 6)?.words == [0x25903c7f])
        #expect(msg.packet(group: 16)?.words == [0x2f903c7f])
    }

    @Test
    func packets() {
        let msg = MIDIChannelMessage.noteOn(1, 60, 127)

        #expect(msg.packets()?.map(\.words) == [[0x20903c7f]])
        #expect(msg.packets(group: 6)?.map(\.words) == [[0x25903c7f]])
    }

    @Test
    func roundTrip() throws {
        let messages: [MIDIChannelMessage] = [.channelPressure(2, 64),
                                              .controlChange(3, .sustain, 127),
                                              .noteOff(4, 60, 64),
                                              .noteOn(5, 60, 100),
                                              .pitchBendChange(6, -1_234),
                                              .polyphonicPressure(7, 60, 32),
                                              .programChange(8, 128)]

        for message in messages {
            for group: MIDI2Group in [1, 16] {
                let packet = try #require(message.packet(group: group))

                #expect(MIDIChannelMessage(packet: packet) == message)
                #expect(packet.group == group)
            }
        }
    }
}
