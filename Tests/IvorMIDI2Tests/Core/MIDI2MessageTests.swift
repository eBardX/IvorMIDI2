// © 2026 John Gary Pusey (see LICENSE.md)

import IvorMIDI
@testable import IvorMIDI2
import Testing
import XestiTools

struct MIDI2MessageTests {
}

// MARK: -

extension MIDI2MessageTests {
    @Test
    func group() throws {
        let packet = try #require(MIDI2Packet(words: [0x65000000]))

        #expect(MIDI2Message.midi1ChannelVoice(.noteOn(1, 60, 127), 6).group == 6)
        #expect(MIDI2Message.flexData(.setTempo(1), 16).group == 16)
        #expect(MIDI2Message.utility(.noop).group == nil)
        #expect(MIDI2Message.stream(.startOfClip).group == nil)
        #expect(MIDI2Message.unrecognized(packet).group == 6)
    }

    @Test
    func init_packets() {
        #expect(MIDI2Message(words: [0x00101234]) == .utility(.jrClock(0x1234)))
        #expect(MIDI2Message(words: [0x15f80000]) == .system(.timingClock, 6))
        #expect(MIDI2Message(words: [0x25903c7f]) == .midi1ChannelVoice(.noteOn(1, 60, 127), 6))
        #expect(MIDI2Message(words: [0x35027e7f, 0x00000000]) == .system(.systemExclusive([0x7e, 0x7f, 0xf7]), 6))
        #expect(MIDI2Message(words: [0x45903c00, 0xffff0000]) == .midi2ChannelVoice(.noteOn(1, 60, 0xffff, nil), 6))
        #expect(MIDI2Message(words: [0x55020043, 0, 0, 0]) == .systemExclusive8(.init(data: [0x43]), 6))
        #expect(MIDI2Message(words: [0xd5100000, 0x02faf080, 0, 0]) == .flexData(.setTempo(50_000_000), 6))
        #expect(MIDI2Message(words: [0xf0200000, 0, 0, 0]) == .stream(.startOfClip))
    }

    @Test
    func init_packets_invalid() {
        #expect(MIDI2Message(packets: []) == nil)
        #expect(MIDI2Message(words: [0x65000000]) == nil)                     // reserved message type
        #expect(MIDI2Message(words: [0x55800000, 0, 0, 0]) == nil)            // mixed data set header
        #expect(MIDI2Message(words: [0x00500000]) == nil)                     // reserved utility status
    }

    @Test
    func roundTrip() throws {
        let packet = try #require(MIDI2Packet(words: [0x65000000]))
        let messages: [MIDI2Message] = [.flexData(.metadataText(.group, .projectName, "Ivor"), 2),
                                        .midi1ChannelVoice(.controlChange(3, .sustain, 127), 3),
                                        .midi2ChannelVoice(.pitchBendChange(4, 0x80000000), 4),
                                        .stream(.endpointNameNotification("Ivor MIDI 2.0 endpoint")),
                                        .system(.songPosition(100), 5),
                                        .system(.systemExclusive(Array(repeating: 0x11, count: 20) + [0xf7]), 6),
                                        .systemExclusive8(.init(streamID: 3, data: Array(0...40)), 7),
                                        .unrecognized(packet),
                                        .utility(.deltaClockstamp(960))]

        for message in messages {
            let packets = try #require(message.packets())

            if case .unrecognized = message {
                #expect(packets == [packet])
            } else {
                #expect(MIDI2Message(packets: packets) == message)
            }
        }
    }
}
