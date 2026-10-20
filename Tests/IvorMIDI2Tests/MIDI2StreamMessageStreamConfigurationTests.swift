// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI2
import Testing

struct MIDI2StreamMessageStreamConfigurationTests {
}

// MARK: -

extension MIDI2StreamMessageStreamConfigurationTests {
    @Test
    func equality() {
        #expect(MIDI2StreamMessage.StreamConfiguration(midiProtocol: .midi2) == .init(midiProtocol: .midi2))
        #expect(MIDI2StreamMessage.StreamConfiguration(midiProtocol: .midi2) != .init(midiProtocol: .midi1))
        #expect(MIDI2StreamMessage.StreamConfiguration(midiProtocol: .midi2)
                    != .init(midiProtocol: .midi2, receivesJRTimestamps: true))
    }

    @Test
    func init_allProperties() {
        let configuration = MIDI2StreamMessage.StreamConfiguration(midiProtocol: .midi1,
                                                                   receivesJRTimestamps: true,
                                                                   transmitsJRTimestamps: true)

        #expect(configuration.midiProtocol == .midi1)
        #expect(configuration.receivesJRTimestamps)
        #expect(configuration.transmitsJRTimestamps)
    }

    @Test
    func init_defaults() {
        let configuration = MIDI2StreamMessage.StreamConfiguration(midiProtocol: .midi2)

        #expect(!configuration.receivesJRTimestamps)
        #expect(!configuration.transmitsJRTimestamps)
    }
}
