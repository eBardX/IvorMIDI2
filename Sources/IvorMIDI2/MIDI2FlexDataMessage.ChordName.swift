// © 2026 John Gary Pusey (see LICENSE.md)

extension MIDI2FlexDataMessage {

    /// The name of a chord: its tonic, chord type, and alterations, with an
    /// optional alternate bass note and bass chord.
    public struct ChordName {

        // MARK: Public Initializers

        /// Creates a `ChordName` instance.
        ///
        /// - Parameter tonic:              The chord’s tonic note, or `nil`
        ///                                 if unknown, as for no chord.
        /// - Parameter chordType:          The chord type.
        /// - Parameter alterations:        Up to 4 alterations to the chord.
        ///                                 Defaults to none.
        /// - Parameter bass:               The bass note, or `nil` if it is
        ///                                 the chord’s tonic. Defaults to
        ///                                 `nil`.
        /// - Parameter bassChordType:      The bass chord type. Defaults to
        ///                                 no bass chord.
        /// - Parameter bassAlterations:    Up to 2 alterations to the bass
        ///                                 chord. Defaults to none.
        public init(tonic: Note?,
                    chordType: ChordType,
                    alterations: [Alteration] = [],
                    bass: Note? = nil,
                    bassChordType: ChordType = .noChord,
                    bassAlterations: [Alteration] = []) {
            self.alterations = alterations
            self.bass = bass
            self.bassAlterations = bassAlterations
            self.bassChordType = bassChordType
            self.chordType = chordType
            self.tonic = tonic
        }

        // MARK: Public Instance Properties

        /// The alterations to the chord (up to 4).
        public let alterations: [Alteration]

        /// The bass note, or `nil` if it is the chord’s tonic.
        public let bass: Note?

        /// The alterations to the bass chord (up to 2).
        public let bassAlterations: [Alteration]

        /// The bass chord type.
        public let bassChordType: ChordType

        /// The chord type.
        public let chordType: ChordType

        /// The chord’s tonic note, or `nil` if unknown.
        public let tonic: Note?
    }
}

// MARK: - Equatable

extension MIDI2FlexDataMessage.ChordName: Equatable {
}

// MARK: - Hashable

extension MIDI2FlexDataMessage.ChordName: Hashable {
}

// MARK: - Sendable

extension MIDI2FlexDataMessage.ChordName: Sendable {
}
