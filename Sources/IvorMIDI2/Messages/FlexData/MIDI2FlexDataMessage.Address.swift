// © 2026 John Gary Pusey (see LICENSE.md)

public import IvorMIDI

extension MIDI2FlexDataMessage {

    /// The destination of a Flex Data message within its group.
    public enum Address {

        /// A MIDI channel of the group.
        case channel(MIDIChannel)

        /// The group as a whole.
        case group
    }
}

// MARK: - Equatable

extension MIDI2FlexDataMessage.Address: Equatable {
}

// MARK: - Hashable

extension MIDI2FlexDataMessage.Address: Hashable {
}

// MARK: - Sendable

extension MIDI2FlexDataMessage.Address: Sendable {
}
