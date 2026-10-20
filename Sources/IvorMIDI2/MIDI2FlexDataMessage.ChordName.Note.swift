// © 2026 John Gary Pusey (see LICENSE.md)

extension MIDI2FlexDataMessage.ChordName {

    /// A note of a chord name: a letter with an accidental.
    public struct Note {

        // MARK: Public Initializers

        /// Creates a `Note` instance.
        ///
        /// - Parameter letter:     The note’s letter.
        /// - Parameter accidental: The number of sharps (1–2) or flats (−1 to
        ///                         −2) applied to the letter, or 0 for a
        ///                         natural. Defaults to 0.
        public init(_ letter: MIDI2FlexDataMessage.NoteLetter,
                    accidental: Int8 = 0) {
            self.accidental = accidental
            self.letter = letter
        }

        // MARK: Public Instance Properties

        /// The number of sharps (positive) or flats (negative) applied to the
        /// letter.
        public let accidental: Int8

        /// The note’s letter.
        public let letter: MIDI2FlexDataMessage.NoteLetter
    }
}

// MARK: - Equatable

extension MIDI2FlexDataMessage.ChordName.Note: Equatable {
}

// MARK: - Hashable

extension MIDI2FlexDataMessage.ChordName.Note: Hashable {
}

// MARK: - Sendable

extension MIDI2FlexDataMessage.ChordName.Note: Sendable {
}
