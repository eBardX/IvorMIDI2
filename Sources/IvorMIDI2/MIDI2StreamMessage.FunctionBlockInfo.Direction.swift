// © 2026 John Gary Pusey (see LICENSE.md)

extension MIDI2StreamMessage.FunctionBlockInfo {

    /// The connectivity of a function block within its UMP endpoint.
    public enum Direction: UInt8 {

        /// The function block both receives and sends MIDI messages: every
        /// input group has a matching output group.
        case bidirectional = 0b11

        /// The function block only receives MIDI messages.
        case input = 0b01

        /// The function block only sends MIDI messages.
        case output = 0b10
    }
}

// MARK: - Sendable

extension MIDI2StreamMessage.FunctionBlockInfo.Direction: Sendable {
}
