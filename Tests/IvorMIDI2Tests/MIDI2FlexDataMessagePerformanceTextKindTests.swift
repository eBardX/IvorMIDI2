// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI2
import Testing

struct MIDI2FlexDataMessagePerformanceTextKindTests {
    private let cases: [(MIDI2FlexDataMessage.PerformanceTextKind, UInt8)] = [(.lyrics, 0x01),
                                                                              (.lyricsLanguage, 0x02),
                                                                              (.ruby, 0x03),
                                                                              (.rubyLanguage, 0x04),
                                                                              (.unknown, 0x00)]
}

// MARK: -

extension MIDI2FlexDataMessagePerformanceTextKindTests {
    @Test
    func init_rawValue() {
        for (value, rawValue) in cases {
            #expect(MIDI2FlexDataMessage.PerformanceTextKind(rawValue: rawValue) == value)
        }
    }

    @Test
    func init_rawValue_invalid() {
        #expect(MIDI2FlexDataMessage.PerformanceTextKind(rawValue: 0x05) == nil)
        #expect(MIDI2FlexDataMessage.PerformanceTextKind(rawValue: 0xff) == nil)
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
