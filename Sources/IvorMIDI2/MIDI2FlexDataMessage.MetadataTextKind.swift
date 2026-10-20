// © 2026 John Gary Pusey (see LICENSE.md)

extension MIDI2FlexDataMessage {

    /// The kind of a metadata text message (status bank 0x01).
    public enum MetadataTextKind: UInt8 {

        /// The name of an accompanying performer.
        case accompanyingPerformerName = 0x0a

        /// The name of the arranger.
        case arrangerName = 0x07

        /// The name of the composer.
        case composerName = 0x05

        /// The name of the composition (song).
        case compositionName = 0x02

        /// A copyright notice.
        case copyrightNotice = 0x04

        /// The name of the lyricist.
        case lyricistName = 0x06

        /// The name of a MIDI clip. Its address should be the group.
        case midiClipName = 0x03

        /// The name of the primary performer.
        case primaryPerformerName = 0x09

        /// The name of the project. Its address should be the group.
        case projectName = 0x01

        /// The name of the publisher.
        case publisherName = 0x08

        /// The date, and optionally the time, of the recording or concert,
        /// in ISO 8601 format.
        case recordingDate = 0x0b

        /// The location of the recording or concert.
        case recordingLocation = 0x0c

        /// Metadata text of an unknown kind.
        case unknown = 0x00
    }
}

// MARK: - Sendable

extension MIDI2FlexDataMessage.MetadataTextKind: Sendable {
}
