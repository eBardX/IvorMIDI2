// © 2026 John Gary Pusey (see LICENSE.md)

extension MIDI2StreamMessage {

    /// A MIDI protocol of a UMP stream.
    public enum MIDIProtocol: UInt8 {

        /// The MIDI 1.0 Protocol.
        case midi1 = 0x01

        /// The MIDI 2.0 Protocol.
        case midi2 = 0x02
    }
}

// MARK: - Sendable

extension MIDI2StreamMessage.MIDIProtocol: Sendable {
}
