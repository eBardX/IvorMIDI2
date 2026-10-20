// © 2026 John Gary Pusey (see LICENSE.md)

extension MIDI2FlexDataMessage.ChordName {

    /// The type of a chord.
    public enum ChordType: UInt8 {

        /// An augmented chord.
        case augmented = 0x11

        /// An augmented seventh chord.
        case augmentedSeventh = 0x12

        /// A diminished chord.
        case diminished = 0x13

        /// A diminished seventh chord.
        case diminishedSeventh = 0x14

        /// A dominant (seventh) chord.
        case dominant = 0x0d

        /// A dominant eleventh chord.
        case dominantEleventh = 0x0f

        /// A dominant ninth chord.
        case dominantNinth = 0x0e

        /// A dominant thirteenth chord.
        case dominantThirteenth = 0x10

        /// A half-diminished chord: a diminished triad with a minor seventh.
        case halfDiminished = 0x15

        /// A major chord.
        case major = 0x01

        /// A major eleventh chord.
        case majorEleventh = 0x05

        /// A major ninth chord.
        case majorNinth = 0x04

        /// A major seventh chord.
        case majorSeventh = 0x03

        /// A major sixth chord.
        case majorSixth = 0x02

        /// A major thirteenth chord.
        case majorThirteenth = 0x06

        /// A minor chord.
        case minor = 0x07

        /// A minor eleventh chord.
        case minorEleventh = 0x0b

        /// A minor-major chord: a minor triad with a major seventh.
        case minorMajor = 0x16

        /// A minor ninth chord.
        case minorNinth = 0x0a

        /// A minor seventh chord.
        case minorSeventh = 0x09

        /// A minor sixth chord.
        case minorSixth = 0x08

        /// A minor thirteenth chord.
        case minorThirteenth = 0x0c

        /// No chord, which clears the chord.
        case noChord = 0x00

        /// A pedal chord: the root and its octave.
        case pedal = 0x17

        /// A power chord: the root and fifth.
        case power = 0x18

        /// A seventh suspended fourth chord.
        case seventhSuspendedFourth = 0x1b

        /// A suspended fourth chord.
        case suspendedFourth = 0x1a

        /// A suspended second chord.
        case suspendedSecond = 0x19
    }
}

// MARK: - Sendable

extension MIDI2FlexDataMessage.ChordName.ChordType: Sendable {
}
