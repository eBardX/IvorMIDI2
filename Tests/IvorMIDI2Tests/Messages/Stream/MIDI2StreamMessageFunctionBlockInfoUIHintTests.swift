// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI2
import Testing

struct MIDI2StreamMessageFunctionBlockInfoUIHintTests {
    private let cases: [(MIDI2StreamMessage.FunctionBlockInfo.UIHint, UInt8)] = [(.receiver, 0x01),
                                                                                 (.sender, 0x02),
                                                                                 (.senderAndReceiver, 0x03),
                                                                                 (.unknown, 0x00)]
}

// MARK: -

extension MIDI2StreamMessageFunctionBlockInfoUIHintTests {
    @Test
    func init_rawValue() {
        for (value, rawValue) in cases {
            #expect(MIDI2StreamMessage.FunctionBlockInfo.UIHint(rawValue: rawValue) == value)
        }
    }

    @Test
    func init_rawValue_invalid() {
        #expect(MIDI2StreamMessage.FunctionBlockInfo.UIHint(rawValue: 0x04) == nil)
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
