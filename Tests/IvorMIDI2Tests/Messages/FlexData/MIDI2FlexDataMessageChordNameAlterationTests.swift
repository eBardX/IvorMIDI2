// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI2
import Testing

struct MIDI2FlexDataMessageChordNameAlterationTests {
}

// MARK: -

extension MIDI2FlexDataMessageChordNameAlterationTests {
    @Test
    func byte() {
        #expect(MIDI2FlexDataMessage.ChordName.Alteration.add(9).byte == 0x19)
        #expect(MIDI2FlexDataMessage.ChordName.Alteration.subtract(5).byte == 0x25)
        #expect(MIDI2FlexDataMessage.ChordName.Alteration.raise(11).byte == 0x3b)
        #expect(MIDI2FlexDataMessage.ChordName.Alteration.lower(15).byte == 0x4f)
    }

    @Test
    func byte_degreeOutOfRange() {
        #expect(MIDI2FlexDataMessage.ChordName.Alteration.add(16).byte == nil)
        #expect(MIDI2FlexDataMessage.ChordName.Alteration.lower(255).byte == nil)
    }

    @Test
    func equality() {
        #expect(MIDI2FlexDataMessage.ChordName.Alteration.add(9) == .add(9))
        #expect(MIDI2FlexDataMessage.ChordName.Alteration.add(9) != .add(11))
        #expect(MIDI2FlexDataMessage.ChordName.Alteration.add(9) != .raise(9))
    }

    @Test
    func hashable() {
        let set: Set<MIDI2FlexDataMessage.ChordName.Alteration> = [.add(9), .add(9), .subtract(9)]

        #expect(set.count == 2)
    }

    @Test
    func init_type() {
        #expect(MIDI2FlexDataMessage.ChordName.Alteration(type: 1, degree: 9) == .add(9))
        #expect(MIDI2FlexDataMessage.ChordName.Alteration(type: 2, degree: 5) == .subtract(5))
        #expect(MIDI2FlexDataMessage.ChordName.Alteration(type: 3, degree: 11) == .raise(11))
        #expect(MIDI2FlexDataMessage.ChordName.Alteration(type: 4, degree: 13) == .lower(13))
    }

    @Test
    func init_type_reserved() {
        #expect(MIDI2FlexDataMessage.ChordName.Alteration(type: 0, degree: 9) == nil)
        #expect(MIDI2FlexDataMessage.ChordName.Alteration(type: 5, degree: 9) == nil)
        #expect(MIDI2FlexDataMessage.ChordName.Alteration(type: 15, degree: 9) == nil)
    }
}
