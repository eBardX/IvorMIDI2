// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI2
import Testing

struct MIDI2PacketTests {
}

// MARK: -

extension MIDI2PacketTests {
    @Test
    func equality() {
        let packet1 = MIDI2Packet(words: [0x25903c7f])
        let packet2 = MIDI2Packet(words: [0x25903c7f])
        let packet3 = MIDI2Packet(words: [0x25903c7e])

        #expect(packet1 == packet2)
        #expect(packet1 != packet3)
    }

    @Test
    func group() {
        #expect(MIDI2Packet(words: [0x25903c7f])?.group?.uintValue == 6)
        #expect(MIDI2Packet(words: [0x3f010100, 0x00000000])?.group?.uintValue == 16)
        #expect(MIDI2Packet(words: [0x00000000])?.group == nil)                         // utility
        #expect(MIDI2Packet(words: [0xf0000000, 0, 0, 0])?.group == nil)                // UMP stream
    }

    @Test
    func hashable() {
        let set = Set([MIDI2Packet(words: [0x25903c7f]),
                       MIDI2Packet(words: [0x25903c7f]),
                       MIDI2Packet(words: [0x25903c7e])].compactMap(\.self))

        #expect(set.count == 2)
    }

    @Test
    func init_words() {
        let packet1 = MIDI2Packet(words: [0x25903c7f])
        let packet2 = MIDI2Packet(words: [0x40903c00, 0xffff0000])
        let packet3 = MIDI2Packet(words: [0xb0000000, 0x11111111, 0x22222222])
        let packet4 = MIDI2Packet(words: [0xd0100001, 0x11111111, 0x22222222, 0x33333333])

        #expect(packet1?.words == [0x25903c7f])
        #expect(packet2?.words == [0x40903c00, 0xffff0000])
        #expect(packet3?.words == [0xb0000000, 0x11111111, 0x22222222])
        #expect(packet4?.words == [0xd0100001, 0x11111111, 0x22222222, 0x33333333])
    }

    @Test
    func init_words_arraySlice() {
        let stream: [MIDI2Packet.Word] = [0x25903c7f, 0x40903c00, 0xffff0000]

        #expect(MIDI2Packet(words: stream[1...])?.words == [0x40903c00, 0xffff0000])
    }

    @Test
    func init_words_invalid() {
        #expect(MIDI2Packet(words: []) == nil)
        #expect(MIDI2Packet(words: [0x25903c7f, 0x00000000]) == nil)        // too many
        #expect(MIDI2Packet(words: [0x40903c00]) == nil)                    // too few
        #expect(MIDI2Packet(words: [0xd0100001, 0, 0]) == nil)
        #expect(MIDI2Packet(words: [0xf0000000, 0, 0, 0, 0]) == nil)
    }

    @Test
    func messageType() {
        #expect(MIDI2Packet(words: [0x00000000])?.messageType == 0x0)
        #expect(MIDI2Packet(words: [0x25903c7f])?.messageType == 0x2)
        #expect(MIDI2Packet(words: [0x40903c00, 0xffff0000])?.messageType == 0x4)
        #expect(MIDI2Packet(words: [0xf0000000, 0, 0, 0])?.messageType == 0xf)
    }

    @Test
    func unusedWordsAreZero() {
        let packet = MIDI2Packet(words: [0x25903c7f])

        #expect(packet?.word0 == 0x25903c7f)
        #expect(packet?.word1 == 0)
        #expect(packet?.word2 == 0)
        #expect(packet?.word3 == 0)
    }

    @Test
    func wordCount() {
        #expect(MIDI2Packet(words: [0x25903c7f])?.wordCount == 1)
        #expect(MIDI2Packet(words: [0x40903c00, 0xffff0000])?.wordCount == 2)
        #expect(MIDI2Packet(words: [0xb0000000, 0, 0])?.wordCount == 3)
        #expect(MIDI2Packet(words: [0xd0100001, 0, 0, 0])?.wordCount == 4)
    }

    @Test
    func wordCount_forUniversalMIDIPacket() {
        let expected = [1, 1, 1, 2, 2, 4, 1, 1, 2, 2, 2, 3, 3, 4, 4, 4]

        for (messageType, wordCount) in expected.enumerated() {
            let word = MIDI2Packet.Word(messageType) << 28

            #expect(MIDI2Packet.wordCount(forUniversalMIDIPacket: word) == wordCount)
        }
    }
}
