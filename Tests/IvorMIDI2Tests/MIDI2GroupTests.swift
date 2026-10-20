// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
import IvorMIDI
@testable import IvorMIDI2
import Testing
import XestiTools

struct MIDI2GroupTests {
}

// MARK: -

extension MIDI2GroupTests {
    @Test
    func bytesValue() {
        #expect(MIDI2Group(uintValue: 1)?.bytesValue == [0x00])
        #expect(MIDI2Group(uintValue: 6)?.bytesValue == [0x05])
        #expect(MIDI2Group(uintValue: 16)?.bytesValue == [0x0f])
    }

    @Test
    func codable() throws {
        let original: MIDI2Group = 6
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MIDI2Group.self,
                                               from: data)

        #expect(decoded == original)
    }

    @Test
    func codable_invalidValueThrows() {
        let data = Data("0".utf8)

        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(MIDI2Group.self,
                                     from: data)
        }
    }

    @Test
    func comparable() {
        let low: MIDI2Group = 1
        let high: MIDI2Group = 16

        #expect(low < high)
        #expect(!(high < low))
    }

    @Test
    func description() {
        let value: MIDI2Group = 6

        #expect(value.description == "6")
    }

    @Test
    func equality() {
        let value1: MIDI2Group = 6
        let value2: MIDI2Group = 6
        let value3: MIDI2Group = 7

        #expect(value1 == value2)
        #expect(value1 != value3)
    }

    @Test
    func hashable() {
        let set: Set<MIDI2Group> = [6, 6, 7]

        #expect(set.count == 2)
    }

    @Test
    func init_bytesValue() {
        #expect(MIDI2Group(bytesValue: [0x00])?.uintValue == 1)
        #expect(MIDI2Group(bytesValue: [0x05])?.uintValue == 6)
        #expect(MIDI2Group(bytesValue: [0x0f])?.uintValue == 16)
    }

    @Test
    func init_bytesValue_invalid() {
        #expect(MIDI2Group(bytesValue: []) == nil)
        #expect(MIDI2Group(bytesValue: [0x00, 0x01]) == nil)
        #expect(MIDI2Group(bytesValue: [0x10]) == nil)
    }

    @Test
    func init_clamping() {
        #expect(MIDI2Group(clamping: 0).uintValue == 1)
        #expect(MIDI2Group(clamping: 1).uintValue == 1)
        #expect(MIDI2Group(clamping: 6).uintValue == 6)
        #expect(MIDI2Group(clamping: 16).uintValue == 16)
        #expect(MIDI2Group(clamping: 17).uintValue == 16)
        #expect(MIDI2Group(clamping: Int.min).uintValue == 1)
        #expect(MIDI2Group(clamping: UInt.max).uintValue == 16)
    }

    @Test
    func init_integerLiteral() {
        let value: MIDI2Group = 6

        #expect(value.uintValue == 6)
    }

    @Test
    func init_uintValue() {
        #expect(MIDI2Group(uintValue: 1)?.uintValue == 1)
        #expect(MIDI2Group(uintValue: 16)?.uintValue == 16)
    }

    @Test
    func init_uintValue_invalid() {
        #expect(MIDI2Group(uintValue: 0) == nil)
        #expect(MIDI2Group(uintValue: 17) == nil)
    }

    @Test
    func init_universalMIDIPacket() {
        #expect(MIDI2Group(universalMIDIPacket: 0x10000000)?.uintValue == 1)       // system
        #expect(MIDI2Group(universalMIDIPacket: 0x25903c7f)?.uintValue == 6)       // MIDI 1.0 channel voice
        #expect(MIDI2Group(universalMIDIPacket: 0x3f010100)?.uintValue == 16)      // system exclusive
        #expect(MIDI2Group(universalMIDIPacket: 0x00000000) == nil)                // utility
        #expect(MIDI2Group(universalMIDIPacket: 0xf0000000) == nil)                // UMP stream
    }

    @Test
    func isValid() {
        #expect(!MIDI2Group.isValid(0))
        #expect(MIDI2Group.isValid(1))
        #expect(MIDI2Group.isValid(16))
        #expect(!MIDI2Group.isValid(17))
    }
}
