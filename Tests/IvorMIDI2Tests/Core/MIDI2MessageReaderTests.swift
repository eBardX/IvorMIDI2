// © 2026 John Gary Pusey (see LICENSE.md)

import IvorMIDI
@testable import IvorMIDI2
import Testing
import XestiTools

struct MIDI2MessageReaderTests {
}

// MARK: -

extension MIDI2MessageReaderTests {
    @Test
    func finish() throws {
        var reader = MIDI2MessageReader()
        let start = try #require(MIDI2Packet(words: [0x30160102, 0x03040506]))

        #expect(reader.read(words: [0x30160102, 0x03040506, 0x40903c00]).isEmpty)
        #expect(reader.finish() == [.unrecognized(start)])         // partial MIDI 2.0 word discarded
        #expect(reader.finish().isEmpty)
        #expect(reader.read(words: [0x25903c7f]) == [.midi1ChannelVoice(.noteOn(1, 60, 127), 6)])
    }

    @Test
    func read_continuationWithoutStart() throws {
        var reader = MIDI2MessageReader()
        let end = try #require(MIDI2Packet(words: [0x30310700, 0x00000000]))
        let flexContinue = try #require(MIDI2Packet(words: [0xd0900104, 0x41414141, 0x41414141, 0x41414141]))

        #expect(reader.read(end) == [.unrecognized(end)])
        #expect(reader.read(flexContinue) == [.unrecognized(flexContinue)])
    }

    @Test
    func read_flexDataInterleavedWithJRClock() throws {
        var reader = MIDI2MessageReader()
        let text = MIDI2Message.flexData(.performanceText(.channel(1), .lyrics, String(repeating: "la", count: 10)), 1)
        let packets = try #require(text.packets())

        #expect(packets.count == 2)
        #expect(reader.read(packets[0]).isEmpty)
        #expect(reader.read(words: [0x00100001]) == [.utility(.jrClock(1))])
        #expect(reader.read(packets[1]) == [text])
    }

    @Test
    func read_interruptedSystemExclusive() throws {
        var reader = MIDI2MessageReader()
        let start = try #require(MIDI2Packet(words: [0x30160102, 0x03040506]))
        let end = try #require(MIDI2Packet(words: [0x30310700, 0x00000000]))

        #expect(reader.read(start).isEmpty)
        #expect(reader.read(words: [0x20903c7f]) == [.unrecognized(start),
                                                     .midi1ChannelVoice(.noteOn(1, 60, 127), 1)])
        #expect(reader.read(end) == [.unrecognized(end)])
    }

    @Test
    func read_mixedStream() {
        var reader = MIDI2MessageReader()
        let words: [MIDI2Packet.Word] = [0x00101234,    // JR clock
                                         0x25903c7f,    // MIDI 1.0 note on
                                         0x45903c00,
                                         0xffff0000,    // MIDI 2.0 note on
                                         0xd5100000,
                                         0x02faf080,
                                         0x00000000,
                                         0x00000000,    // set tempo
                                         0xf0200000,
                                         0x00000000,
                                         0x00000000,
                                         0x00000000,    // start of clip
                                         0x15f80000]    // timing clock

        #expect(reader.read(words: words) == [.utility(.jrClock(0x1234)),
                                              .midi1ChannelVoice(.noteOn(1, 60, 127), 6),
                                              .midi2ChannelVoice(.noteOn(1, 60, 0xffff, nil), 6),
                                              .flexData(.setTempo(50_000_000), 6),
                                              .stream(.startOfClip),
                                              .system(.timingClock, 6)])
    }

    @Test
    func read_newStartInterruptsPendingMessage() throws {
        var reader = MIDI2MessageReader()
        let start1 = try #require(MIDI2Packet(words: [0x30160102, 0x03040506]))
        let start2 = try #require(MIDI2Packet(words: [0x30160708, 0x090a0b0c]))
        let end = try #require(MIDI2Packet(words: [0x30310d00, 0x00000000]))

        #expect(reader.read(start1).isEmpty)
        #expect(reader.read(start2) == [.unrecognized(start1)])
        #expect(reader.read(end) == [.system(.systemExclusive([7, 8, 9, 10, 11, 12, 13, 0xf7]), 1)])
    }

    @Test
    func read_partialWords() {
        var reader = MIDI2MessageReader()

        #expect(reader.read(words: [0x45903c00]).isEmpty)
        #expect(reader.read(words: [0xffff0000, 0xf0200000, 0x00000000]) == [.midi2ChannelVoice(.noteOn(1, 60, 0xffff, nil), 6)])
        #expect(reader.read(words: [0x00000000, 0x00000000]) == [.stream(.startOfClip)])
    }

    @Test
    func read_streamNameInterruptedByStreamMessage() throws {
        var reader = MIDI2MessageReader()
        let packets = try #require(MIDI2StreamMessage.endpointNameNotification(String(repeating: "N", count: 20)).packets())

        #expect(reader.read(packets[0]).isEmpty)
        #expect(reader.read(words: [0xf0210000, 0, 0, 0]) == [.unrecognized(packets[0]), .stream(.endOfClip)])
        #expect(reader.read(packets[1]) == [.unrecognized(packets[1])])
    }

    @Test
    func read_systemExclusive8StreamsInterleaved() throws {
        var reader = MIDI2MessageReader()
        let message1 = MIDI2Message.systemExclusive8(.init(streamID: 1, data: Array(0...20)), 1)
        let message2 = MIDI2Message.systemExclusive8(.init(streamID: 2, data: Array(100...130)), 1)
        let packets1 = try #require(message1.packets())
        let packets2 = try #require(message2.packets())

        #expect(reader.read(packets1[0]).isEmpty)
        #expect(reader.read(packets2[0]).isEmpty)
        #expect(reader.read(words: [0x20903c7f]) == [.midi1ChannelVoice(.noteOn(1, 60, 127), 1)])
        #expect(reader.read(packets2[1]).isEmpty)
        #expect(reader.read(packets1[1]) == [message1])
        #expect(reader.read(packets2[2]) == [message2])
    }

    @Test
    func read_systemExclusiveInterleavedWithRealTimeAndOtherGroups() throws {
        var reader = MIDI2MessageReader()
        let sysEx = MIDI2Message.system(.systemExclusive(Array(UInt8(1)...13) + [0xf7]), 1)
        let packets = try #require(sysEx.packets())

        #expect(reader.read(packets[0]).isEmpty)
        #expect(reader.read(words: [0x10f80000]) == [.system(.timingClock, 1)])               // real time
        #expect(reader.read(packets[1]).isEmpty)
        #expect(reader.read(words: [0x21903c7f]) == [.midi1ChannelVoice(.noteOn(1, 60, 127), 2)])  // other group
        #expect(reader.read(words: [0x00000000]) == [.utility(.noop)])                          // groupless
        #expect(reader.read(packets[2]) == [sysEx])
    }

    @Test
    func read_unrecognizedPackets() throws {
        var reader = MIDI2MessageReader()
        let reserved = try #require(MIDI2Packet(words: [0xe0000000, 0, 0, 0]))
        let mixedDataSet = try #require(MIDI2Packet(words: [0x50800000, 0, 0, 0]))
        let aborted = try #require(MIDI2Packet(words: [0x503f0000, 0, 0, 0]))
        let sysEx8Start = try #require(MIDI2Packet(words: [0x501e0001, 0, 0, 0]))

        #expect(reader.read(words: [0xe0000000, 0, 0, 0, 0x20903c7f]) == [.unrecognized(reserved),
                                                                          .midi1ChannelVoice(.noteOn(1, 60, 127), 1)])
        #expect(reader.read(mixedDataSet) == [.unrecognized(mixedDataSet)])
        #expect(reader.read(sysEx8Start).isEmpty)
        #expect(reader.read(aborted) == [.unrecognized(sysEx8Start), .unrecognized(aborted)])
    }
}
