// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI2
import Testing

struct MIDI2StreamMessageFunctionBlockInfoMIDI1PortTests {
    private let cases: [(MIDI2StreamMessage.FunctionBlockInfo.MIDI1Port, UInt8)] = [(.notMIDI1, 0x00),
                                                                                    (.restricted, 0x02),
                                                                                    (.unrestricted, 0x01)]
}

// MARK: -

extension MIDI2StreamMessageFunctionBlockInfoMIDI1PortTests {
    @Test
    func init_rawValue() {
        for (value, rawValue) in cases {
            #expect(MIDI2StreamMessage.FunctionBlockInfo.MIDI1Port(rawValue: rawValue) == value)
        }
    }

    @Test
    func init_rawValue_invalid() {
        #expect(MIDI2StreamMessage.FunctionBlockInfo.MIDI1Port(rawValue: 0x03) == nil)
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
