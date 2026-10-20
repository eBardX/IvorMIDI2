// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI2
import Testing

struct MIDI2StreamMessageFunctionBlockInfoDirectionTests {
    private let cases: [(MIDI2StreamMessage.FunctionBlockInfo.Direction, UInt8)] = [(.bidirectional, 0x03),
                                                                                    (.input, 0x01),
                                                                                    (.output, 0x02)]
}

// MARK: -

extension MIDI2StreamMessageFunctionBlockInfoDirectionTests {
    @Test
    func init_rawValue() {
        for (value, rawValue) in cases {
            #expect(MIDI2StreamMessage.FunctionBlockInfo.Direction(rawValue: rawValue) == value)
        }
    }

    @Test
    func init_rawValue_invalid() {
        #expect(MIDI2StreamMessage.FunctionBlockInfo.Direction(rawValue: 0x00) == nil)
        #expect(MIDI2StreamMessage.FunctionBlockInfo.Direction(rawValue: 0x04) == nil)
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
