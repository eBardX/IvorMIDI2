// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI2
import Testing

struct MIDI2StreamMessageEndpointInfoTests {
}

// MARK: -

extension MIDI2StreamMessageEndpointInfoTests {
    @Test
    func equality() {
        let info1 = MIDI2StreamMessage.EndpointInfo(functionBlockCount: 1,
                                                    hasStaticFunctionBlocks: true,
                                                    supportsMIDI1Protocol: true,
                                                    supportsMIDI2Protocol: true)
        let info2 = MIDI2StreamMessage.EndpointInfo(functionBlockCount: 1,
                                                    hasStaticFunctionBlocks: true,
                                                    supportsMIDI1Protocol: true,
                                                    supportsMIDI2Protocol: true)
        let info3 = MIDI2StreamMessage.EndpointInfo(functionBlockCount: 1,
                                                    hasStaticFunctionBlocks: true,
                                                    supportsMIDI1Protocol: true,
                                                    supportsMIDI2Protocol: false)

        #expect(info1 == info2)
        #expect(info1 != info3)
    }

    @Test
    func init_allProperties() {
        let info = MIDI2StreamMessage.EndpointInfo(umpVersionMajor: 2,
                                                   umpVersionMinor: 3,
                                                   functionBlockCount: 32,
                                                   hasStaticFunctionBlocks: false,
                                                   supportsMIDI1Protocol: false,
                                                   supportsMIDI2Protocol: true,
                                                   receivesJRTimestamps: true,
                                                   transmitsJRTimestamps: true)

        #expect(info.umpVersionMajor == 2)
        #expect(info.umpVersionMinor == 3)
        #expect(info.functionBlockCount == 32)
        #expect(!info.hasStaticFunctionBlocks)
        #expect(!info.supportsMIDI1Protocol)
        #expect(info.supportsMIDI2Protocol)
        #expect(info.receivesJRTimestamps)
        #expect(info.transmitsJRTimestamps)
    }

    @Test
    func init_defaults() {
        let info = MIDI2StreamMessage.EndpointInfo(functionBlockCount: 0,
                                                   hasStaticFunctionBlocks: true,
                                                   supportsMIDI1Protocol: true,
                                                   supportsMIDI2Protocol: false)

        #expect(info.umpVersionMajor == 1)
        #expect(info.umpVersionMinor == 1)
        #expect(!info.receivesJRTimestamps)
        #expect(!info.transmitsJRTimestamps)
    }
}
