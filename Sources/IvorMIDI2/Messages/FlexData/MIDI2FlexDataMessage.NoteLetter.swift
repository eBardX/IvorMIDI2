// © 2026 John Gary Pusey (see LICENSE.md)

extension MIDI2FlexDataMessage {

    /// The letter name of a note in a key signature or chord name.
    public enum NoteLetter: UInt8 {

        /// The note A.
        case a = 0x1

        /// The note B.
        case b = 0x2

        /// The note C.
        case c = 0x3

        /// The note D.
        case d = 0x4

        /// The note E.
        case e = 0x5

        /// The note F.
        case f = 0x6

        /// The note G.
        case g = 0x7
    }
}

// MARK: - Sendable

extension MIDI2FlexDataMessage.NoteLetter: Sendable {
}
