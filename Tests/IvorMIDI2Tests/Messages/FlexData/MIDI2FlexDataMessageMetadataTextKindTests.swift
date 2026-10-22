// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI2
import Testing

struct MIDI2FlexDataMessageMetadataTextKindTests {
    private let cases: [(MIDI2FlexDataMessage.MetadataTextKind, UInt8)] = [(.accompanyingPerformerName, 0x0a),
                                                                           (.arrangerName, 0x07),
                                                                           (.composerName, 0x05),
                                                                           (.compositionName, 0x02),
                                                                           (.copyrightNotice, 0x04),
                                                                           (.lyricistName, 0x06),
                                                                           (.midiClipName, 0x03),
                                                                           (.primaryPerformerName, 0x09),
                                                                           (.projectName, 0x01),
                                                                           (.publisherName, 0x08),
                                                                           (.recordingDate, 0x0b),
                                                                           (.recordingLocation, 0x0c),
                                                                           (.unknown, 0x00)]
}

// MARK: -

extension MIDI2FlexDataMessageMetadataTextKindTests {
    @Test
    func init_rawValue() {
        for (value, rawValue) in cases {
            #expect(MIDI2FlexDataMessage.MetadataTextKind(rawValue: rawValue) == value)
        }
    }

    @Test
    func init_rawValue_invalid() {
        #expect(MIDI2FlexDataMessage.MetadataTextKind(rawValue: 0x0d) == nil)
        #expect(MIDI2FlexDataMessage.MetadataTextKind(rawValue: 0xff) == nil)
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
