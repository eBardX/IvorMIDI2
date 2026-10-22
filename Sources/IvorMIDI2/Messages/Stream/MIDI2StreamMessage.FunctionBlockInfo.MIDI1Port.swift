// © 2026 John Gary Pusey (see LICENSE.md)

extension MIDI2StreamMessage.FunctionBlockInfo {

    /// Whether a function block represents a MIDI 1.0 port, and how.
    public enum MIDI1Port: UInt8 {

        /// The function block does not represent a MIDI 1.0 port.
        case notMIDI1 = 0b00

        /// The function block represents a MIDI 1.0 port whose bandwidth is
        /// restricted to 31.25 kbps.
        case restricted = 0b10

        /// The function block represents a MIDI 1.0 port whose bandwidth is
        /// not restricted.
        case unrestricted = 0b01
    }
}

// MARK: - Sendable

extension MIDI2StreamMessage.FunctionBlockInfo.MIDI1Port: Sendable {
}
