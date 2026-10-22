// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI2
import Testing

struct MIDI2StreamMessageMIDIProtocolTests {
    private let cases: [(MIDI2StreamMessage.MIDIProtocol, UInt8)] = [(.midi1, 0x01),
                                                                     (.midi2, 0x02)]
}

// MARK: -

extension MIDI2StreamMessageMIDIProtocolTests {
    @Test
    func init_rawValue() {
        for (value, rawValue) in cases {
            #expect(MIDI2StreamMessage.MIDIProtocol(rawValue: rawValue) == value)
        }
    }

    @Test
    func init_rawValue_invalid() {
        #expect(MIDI2StreamMessage.MIDIProtocol(rawValue: 0x00) == nil)
        #expect(MIDI2StreamMessage.MIDIProtocol(rawValue: 0x03) == nil)
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
