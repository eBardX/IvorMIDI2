// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI2
import Testing

struct MIDI2FlexDataMessageChordNameTests {
}

// MARK: -

extension MIDI2FlexDataMessageChordNameTests {
    @Test
    func equality() {
        let chord1 = MIDI2FlexDataMessage.ChordName(tonic: .init(.c), chordType: .major)
        let chord2 = MIDI2FlexDataMessage.ChordName(tonic: .init(.c), chordType: .major)
        let chord3 = MIDI2FlexDataMessage.ChordName(tonic: .init(.c), chordType: .minor)

        #expect(chord1 == chord2)
        #expect(chord1 != chord3)
    }

    @Test
    func hashable() {
        let set: Set<MIDI2FlexDataMessage.ChordName> = [.init(tonic: .init(.c), chordType: .major),
                                                        .init(tonic: .init(.c), chordType: .major),
                                                        .init(tonic: nil, chordType: .noChord)]

        #expect(set.count == 2)
    }

    @Test
    func init_allProperties() {
        let chord = MIDI2FlexDataMessage.ChordName(tonic: .init(.e, accidental: -1),
                                                   chordType: .dominant,
                                                   alterations: [.add(9), .raise(11)],
                                                   bass: .init(.g),
                                                   bassChordType: .major,
                                                   bassAlterations: [.lower(5)])

        #expect(chord.tonic == .init(.e, accidental: -1))
        #expect(chord.chordType == .dominant)
        #expect(chord.alterations == [.add(9), .raise(11)])
        #expect(chord.bass == .init(.g))
        #expect(chord.bassChordType == .major)
        #expect(chord.bassAlterations == [.lower(5)])
    }

    @Test
    func init_defaults() {
        let chord = MIDI2FlexDataMessage.ChordName(tonic: .init(.a), chordType: .minor)

        #expect(chord.alterations.isEmpty)
        #expect(chord.bass == nil)
        #expect(chord.bassChordType == .noChord)
        #expect(chord.bassAlterations.isEmpty)
    }
}
