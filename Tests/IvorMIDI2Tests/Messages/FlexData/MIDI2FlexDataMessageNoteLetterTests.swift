// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI2
import Testing

struct MIDI2FlexDataMessageNoteLetterTests {
    private let cases: [(MIDI2FlexDataMessage.NoteLetter, UInt8)] = [(.a, 0x01),
                                                                     (.b, 0x02),
                                                                     (.c, 0x03),
                                                                     (.d, 0x04),
                                                                     (.e, 0x05),
                                                                     (.f, 0x06),
                                                                     (.g, 0x07)]
}

// MARK: -

extension MIDI2FlexDataMessageNoteLetterTests {
    @Test
    func init_rawValue() {
        for (value, rawValue) in cases {
            #expect(MIDI2FlexDataMessage.NoteLetter(rawValue: rawValue) == value)
        }
    }

    @Test
    func init_rawValue_invalid() {
        #expect(MIDI2FlexDataMessage.NoteLetter(rawValue: 0x00) == nil)
        #expect(MIDI2FlexDataMessage.NoteLetter(rawValue: 0x08) == nil)
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
