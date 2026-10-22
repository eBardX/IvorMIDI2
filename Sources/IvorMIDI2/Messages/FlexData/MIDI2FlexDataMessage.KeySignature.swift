// © 2026 John Gary Pusey (see LICENSE.md)

extension MIDI2FlexDataMessage {

    /// A key signature: its sharps or flats and its tonic note.
    public struct KeySignature {

        // MARK: Public Initializers

        /// Creates a `KeySignature` instance.
        ///
        /// - Parameter sharpsOrFlats:  The number of sharps (1–7) or flats
        ///                             (−1 to −7), 0 for none, or −8 for an
        ///                             unknown or non-standard key signature.
        /// - Parameter tonic:          The letter of the tonic note, which
        ///                             the key signature makes natural,
        ///                             sharp, or flat, or `nil` if unknown.
        public init(sharpsOrFlats: Int8,
                    tonic: NoteLetter?) {
            self.sharpsOrFlats = sharpsOrFlats
            self.tonic = tonic
        }

        // MARK: Public Instance Properties

        /// The number of sharps (positive) or flats (negative), or −8 for an
        /// unknown or non-standard key signature.
        public let sharpsOrFlats: Int8

        /// The letter of the tonic note, or `nil` if unknown.
        public let tonic: NoteLetter?
    }
}

// MARK: - Equatable

extension MIDI2FlexDataMessage.KeySignature: Equatable {
}

// MARK: - Hashable

extension MIDI2FlexDataMessage.KeySignature: Hashable {
}

// MARK: - Sendable

extension MIDI2FlexDataMessage.KeySignature: Sendable {
}
