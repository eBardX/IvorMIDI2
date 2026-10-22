// © 2026 John Gary Pusey (see LICENSE.md)

extension MIDI2StreamMessage.FunctionBlockInfo {

    /// The primary role of a function block, as a hint for user interfaces
    /// presenting sources and destinations of MIDI messages.
    public enum UIHint: UInt8 {

        /// The function block is primarily a receiver of MIDI messages.
        case receiver = 0b01

        /// The function block is primarily a sender of MIDI messages.
        case sender = 0b10

        /// The function block is both a sender and a receiver of MIDI
        /// messages.
        case senderAndReceiver = 0b11

        /// The role is unknown or undeclared.
        case unknown = 0b00
    }
}

// MARK: - Sendable

extension MIDI2StreamMessage.FunctionBlockInfo.UIHint: Sendable {
}
