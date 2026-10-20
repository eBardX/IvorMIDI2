// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI2
import Testing

struct MIDI2PacketInternalTests {
}

// MARK: -

extension MIDI2PacketInternalTests {
    @Test
    func bytes() throws {
        let packet1 = try #require(MIDI2Packet(words: [0x25903c7f]))
        let packet2 = try #require(MIDI2Packet(words: [0x40903c00, 0xffff1234]))

        #expect(packet1.bytes == [0x25, 0x90, 0x3c, 0x7f])
        #expect(packet2.bytes == [0x40, 0x90, 0x3c, 0x00, 0xff, 0xff, 0x12, 0x34])
    }

    @Test
    func chunks() {
        #expect(MIDI2Packet.chunks(of: [1, 2, 3, 4, 5], size: 2) == [[1, 2], [3, 4], [5]])
        #expect(MIDI2Packet.chunks(of: [1, 2, 3, 4], size: 2) == [[1, 2], [3, 4]])
        #expect(MIDI2Packet.chunks(of: [1], size: 14) == [[1]])
    }

    @Test
    func chunks_empty() {
        #expect(MIDI2Packet.chunks(of: [], size: 12) == [[]])
    }

    @Test
    func format() {
        #expect(MIDI2Packet.format(ofPacketAt: 0, count: 1) == 0x0)
        #expect(MIDI2Packet.format(ofPacketAt: 0, count: 3) == 0x1)
        #expect(MIDI2Packet.format(ofPacketAt: 1, count: 3) == 0x2)
        #expect(MIDI2Packet.format(ofPacketAt: 2, count: 3) == 0x3)
    }

    @Test
    func init_bytes() {
        #expect(MIDI2Packet(bytes: [0x25, 0x90, 0x3c, 0x7f])?.words == [0x25903c7f])
        #expect(MIDI2Packet(bytes: [0x40, 0x90, 0x3c, 0x00, 0xff, 0xff, 0x00, 0x00])?.words == [0x40903c00, 0xffff0000])
    }

    @Test
    func init_bytes_invalid() {
        #expect(MIDI2Packet(bytes: []) == nil)
        #expect(MIDI2Packet(bytes: [0x25, 0x90, 0x3c]) == nil)                     // not whole words
        #expect(MIDI2Packet(bytes: [0x40, 0x90, 0x3c, 0x00]) == nil)               // too few for its type
    }

    @Test
    func isValidFormatSequence() {
        #expect(MIDI2Packet.isValidFormatSequence([0x0]))
        #expect(MIDI2Packet.isValidFormatSequence([0x1, 0x3]))
        #expect(MIDI2Packet.isValidFormatSequence([0x1, 0x2, 0x2, 0x3]))
    }

    @Test
    func isValidFormatSequence_invalid() {
        #expect(!MIDI2Packet.isValidFormatSequence([]))
        #expect(!MIDI2Packet.isValidFormatSequence([0x1]))
        #expect(!MIDI2Packet.isValidFormatSequence([0x0, 0x0]))
        #expect(!MIDI2Packet.isValidFormatSequence([0x2, 0x3]))
        #expect(!MIDI2Packet.isValidFormatSequence([0x1, 0x3, 0x3]))
        #expect(!MIDI2Packet.isValidFormatSequence([0x4]))
    }

    @Test
    func text() {
        #expect(MIDI2Packet.text(from: [0x68, 0x69, 0x00, 0x00]) == "hi")
        #expect(MIDI2Packet.text(from: [0xc3, 0xa9]) == "é")
        #expect(MIDI2Packet.text(from: [0x00, 0x00])?.isEmpty == true)
        #expect(MIDI2Packet.text(from: [])?.isEmpty == true)
    }

    @Test
    func text_invalid() {
        #expect(MIDI2Packet.text(from: [0x68, 0x00, 0x69]) == nil)                // text after its end
        #expect(MIDI2Packet.text(from: [0xff]) == nil)                            // not UTF-8
    }

    @Test
    func textBytes() {
        #expect(MIDI2Packet.textBytes(of: "hi") == [0x68, 0x69])
        #expect(MIDI2Packet.textBytes(of: "é") == [0xc3, 0xa9])
        #expect(MIDI2Packet.textBytes(of: "")?.isEmpty == true)
    }

    @Test
    func textBytes_nullCharacter() {
        #expect(MIDI2Packet.textBytes(of: "a\u{0}b") == nil)
    }
}
