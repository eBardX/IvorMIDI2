// © 2026 John Gary Pusey (see LICENSE.md)

extension MIDI2StreamMessage {

    /// The information a function block info notification declares about a
    /// function block.
    public struct FunctionBlockInfo {

        // MARK: Public Initializers

        /// Creates a `FunctionBlockInfo` instance.
        ///
        /// - Parameter number:             The function block’s number
        ///                                 (0–31).
        /// - Parameter isActive:           Whether the function block is
        ///                                 active. Defaults to `true`.
        /// - Parameter direction:          The function block’s direction.
        /// - Parameter uiHint:             The function block’s primary role,
        ///                                 as a hint for user interfaces.
        ///                                 Defaults to unknown.
        /// - Parameter midi1Port:          Whether the function block
        ///                                 represents a MIDI 1.0 port.
        ///                                 Defaults to not.
        /// - Parameter firstGroup:         The lowest-numbered group of the
        ///                                 function block.
        /// - Parameter groupCount:         The number of groups the function
        ///                                 block spans (1–16), which must be
        ///                                 1 for a MIDI 1.0 port.
        /// - Parameter midiCIVersion:      The MIDI-CI message version and
        ///                                 format the function block
        ///                                 supports, or 0 for none or
        ///                                 unknown. Defaults to 0.
        /// - Parameter maxSysEx8Streams:   The number of simultaneous System
        ///                                 Exclusive 8 streams the function
        ///                                 block supports, or 0 for none.
        ///                                 Defaults to 0.
        public init(number: UInt8,
                    isActive: Bool = true,
                    direction: Direction,
                    uiHint: UIHint = .unknown,
                    midi1Port: MIDI1Port = .notMIDI1,
                    firstGroup: MIDI2Group,
                    groupCount: UInt8,
                    midiCIVersion: UInt8 = 0,
                    maxSysEx8Streams: UInt8 = 0) {
            self.direction = direction
            self.firstGroup = firstGroup
            self.groupCount = groupCount
            self.isActive = isActive
            self.maxSysEx8Streams = maxSysEx8Streams
            self.midi1Port = midi1Port
            self.midiCIVersion = midiCIVersion
            self.number = number
            self.uiHint = uiHint
        }

        // MARK: Public Instance Properties

        /// The function block’s direction.
        public let direction: Direction

        /// The lowest-numbered group of the function block.
        public let firstGroup: MIDI2Group

        /// The number of groups the function block spans (1–16).
        public let groupCount: UInt8

        /// A Boolean value indicating whether the function block is active.
        public let isActive: Bool

        /// The number of simultaneous System Exclusive 8 streams the function
        /// block supports, or 0 for none.
        public let maxSysEx8Streams: UInt8

        /// Whether the function block represents a MIDI 1.0 port.
        public let midi1Port: MIDI1Port

        /// The MIDI-CI message version and format the function block
        /// supports, or 0 for none or unknown.
        public let midiCIVersion: UInt8

        /// The function block’s number (0–31).
        public let number: UInt8

        /// The function block’s primary role, as a hint for user interfaces.
        public let uiHint: UIHint
    }
}

// MARK: - Equatable

extension MIDI2StreamMessage.FunctionBlockInfo: Equatable {
}

// MARK: - Hashable

extension MIDI2StreamMessage.FunctionBlockInfo: Hashable {
}

// MARK: - Sendable

extension MIDI2StreamMessage.FunctionBlockInfo: Sendable {
}
