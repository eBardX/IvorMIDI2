// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI2
import Testing

struct MIDI2FlexDataMessageChordNameNoteTests {
}

// MARK: -

extension MIDI2FlexDataMessageChordNameNoteTests {
    @Test
    func equality() {
        #expect(MIDI2FlexDataMessage.ChordName.Note(.c) == .init(.c, accidental: 0))
        #expect(MIDI2FlexDataMessage.ChordName.Note(.c) != .init(.c, accidental: 1))
        #expect(MIDI2FlexDataMessage.ChordName.Note(.c) != .init(.d))
    }

    @Test
    func hashable() {
        let set: Set<MIDI2FlexDataMessage.ChordName.Note> = [.init(.f, accidental: 1),
                                                             .init(.f, accidental: 1),
                                                             .init(.g, accidental: -1)]

        #expect(set.count == 2)
    }

    @Test
    func init_defaultAccidental() {
        #expect(MIDI2FlexDataMessage.ChordName.Note(.b).accidental == 0)
    }

    @Test
    func init_letterAndAccidental() {
        let note = MIDI2FlexDataMessage.ChordName.Note(.b, accidental: -2)

        #expect(note.letter == .b)
        #expect(note.accidental == -2)
    }
}
