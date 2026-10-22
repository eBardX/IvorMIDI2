// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI2
import Testing
import XestiTools

struct MIDI2StreamMessageFunctionBlockInfoTests {
}

// MARK: -

extension MIDI2StreamMessageFunctionBlockInfoTests {
    @Test
    func equality() {
        let info1 = MIDI2StreamMessage.FunctionBlockInfo(number: 0, direction: .input, firstGroup: 1, groupCount: 1)
        let info2 = MIDI2StreamMessage.FunctionBlockInfo(number: 0, direction: .input, firstGroup: 1, groupCount: 1)
        let info3 = MIDI2StreamMessage.FunctionBlockInfo(number: 0, direction: .output, firstGroup: 1, groupCount: 1)

        #expect(info1 == info2)
        #expect(info1 != info3)
    }

    @Test
    func init_allProperties() {
        let info = MIDI2StreamMessage.FunctionBlockInfo(number: 31,
                                                        isActive: false,
                                                        direction: .bidirectional,
                                                        uiHint: .senderAndReceiver,
                                                        midi1Port: .restricted,
                                                        firstGroup: 5,
                                                        groupCount: 1,
                                                        midiCIVersion: 2,
                                                        maxSysEx8Streams: 4)

        #expect(info.number == 31)
        #expect(!info.isActive)
        #expect(info.direction == .bidirectional)
        #expect(info.uiHint == .senderAndReceiver)
        #expect(info.midi1Port == .restricted)
        #expect(info.firstGroup == 5)
        #expect(info.groupCount == 1)
        #expect(info.midiCIVersion == 2)
        #expect(info.maxSysEx8Streams == 4)
    }

    @Test
    func init_defaults() {
        let info = MIDI2StreamMessage.FunctionBlockInfo(number: 0, direction: .input, firstGroup: 1, groupCount: 16)

        #expect(info.isActive)
        #expect(info.uiHint == .unknown)
        #expect(info.midi1Port == .notMIDI1)
        #expect(info.midiCIVersion == 0)
        #expect(info.maxSysEx8Streams == 0)
    }
}
