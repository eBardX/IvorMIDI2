// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI2
import Testing

struct MIDI2FlexDataMessageChordNameChordTypeTests {
    private let cases: [(MIDI2FlexDataMessage.ChordName.ChordType, UInt8)] = [(.augmented, 0x11),
                                                                              (.augmentedSeventh, 0x12),
                                                                              (.diminished, 0x13),
                                                                              (.diminishedSeventh, 0x14),
                                                                              (.dominant, 0x0d),
                                                                              (.dominantEleventh, 0x0f),
                                                                              (.dominantNinth, 0x0e),
                                                                              (.dominantThirteenth, 0x10),
                                                                              (.halfDiminished, 0x15),
                                                                              (.major, 0x01),
                                                                              (.majorEleventh, 0x05),
                                                                              (.majorNinth, 0x04),
                                                                              (.majorSeventh, 0x03),
                                                                              (.majorSixth, 0x02),
                                                                              (.majorThirteenth, 0x06),
                                                                              (.minor, 0x07),
                                                                              (.minorEleventh, 0x0b),
                                                                              (.minorMajor, 0x16),
                                                                              (.minorNinth, 0x0a),
                                                                              (.minorSeventh, 0x09),
                                                                              (.minorSixth, 0x08),
                                                                              (.minorThirteenth, 0x0c),
                                                                              (.noChord, 0x00),
                                                                              (.pedal, 0x17),
                                                                              (.power, 0x18),
                                                                              (.seventhSuspendedFourth, 0x1b),
                                                                              (.suspendedFourth, 0x1a),
                                                                              (.suspendedSecond, 0x19)]
}

// MARK: -

extension MIDI2FlexDataMessageChordNameChordTypeTests {
    @Test
    func init_rawValue() {
        for (value, rawValue) in cases {
            #expect(MIDI2FlexDataMessage.ChordName.ChordType(rawValue: rawValue) == value)
        }
    }

    @Test
    func init_rawValue_invalid() {
        #expect(MIDI2FlexDataMessage.ChordName.ChordType(rawValue: 0x1c) == nil)
        #expect(MIDI2FlexDataMessage.ChordName.ChordType(rawValue: 0xff) == nil)
    }

    @Test
    func rawValue() {
        for (value, rawValue) in cases {
            #expect(value.rawValue == rawValue)
        }
    }

    @Test
    func rawValue_distinct() {
        #expect(Set(cases.map(\.1)).count == cases.count)
    }
}
