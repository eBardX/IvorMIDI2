// © 2026 John Gary Pusey (see LICENSE.md)

extension MIDI2StreamMessage {

    /// The protocol and jitter reduction timestamps of a UMP stream.
    public struct StreamConfiguration {

        // MARK: Public Initializers

        /// Creates a `StreamConfiguration` instance.
        ///
        /// - Parameter midiProtocol:           The protocol of the messages
        ///                                     the endpoint sends and expects
        ///                                     to receive.
        /// - Parameter receivesJRTimestamps:   Whether the endpoint receives
        ///                                     jitter reduction timestamps.
        ///                                     Defaults to `false`.
        /// - Parameter transmitsJRTimestamps:  Whether the endpoint sends
        ///                                     jitter reduction timestamps.
        ///                                     Defaults to `false`.
        public init(midiProtocol: MIDIProtocol,
                    receivesJRTimestamps: Bool = false,
                    transmitsJRTimestamps: Bool = false) {
            self.midiProtocol = midiProtocol
            self.receivesJRTimestamps = receivesJRTimestamps
            self.transmitsJRTimestamps = transmitsJRTimestamps
        }

        // MARK: Public Instance Properties

        /// The protocol of the messages the endpoint sends and expects to
        /// receive.
        public let midiProtocol: MIDIProtocol

        /// A Boolean value indicating whether the endpoint receives jitter
        /// reduction timestamps.
        public let receivesJRTimestamps: Bool

        /// A Boolean value indicating whether the endpoint sends jitter
        /// reduction timestamps.
        public let transmitsJRTimestamps: Bool
    }
}

// MARK: - Equatable

extension MIDI2StreamMessage.StreamConfiguration: Equatable {
}

// MARK: - Hashable

extension MIDI2StreamMessage.StreamConfiguration: Hashable {
}

// MARK: - Sendable

extension MIDI2StreamMessage.StreamConfiguration: Sendable {
}
