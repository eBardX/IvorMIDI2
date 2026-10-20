// © 2026 John Gary Pusey (see LICENSE.md)

extension MIDI2FlexDataMessage {

    /// The kind of a performance text message (status bank 0x02).
    public enum PerformanceTextKind: UInt8 {

        /// One syllable of a lyric, sent when its sung note begins.
        case lyrics = 0x01

        /// The language of the lyrics, as a BCP 47 language tag.
        case lyricsLanguage = 0x02

        /// Ruby text: a pronunciation guide for the lyrics.
        case ruby = 0x03

        /// The language of the ruby text, as a BCP 47 language tag.
        case rubyLanguage = 0x04

        /// Performance text of an unknown kind.
        case unknown = 0x00
    }
}

// MARK: - Sendable

extension MIDI2FlexDataMessage.PerformanceTextKind: Sendable {
}
