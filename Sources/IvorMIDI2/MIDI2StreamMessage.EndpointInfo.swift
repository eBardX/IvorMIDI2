// © 2026 John Gary Pusey (see LICENSE.md)

extension MIDI2StreamMessage {

    /// The information an endpoint info notification declares about a UMP
    /// endpoint.
    public struct EndpointInfo {

        // MARK: Public Initializers

        /// Creates an `EndpointInfo` instance.
        ///
        /// - Parameter umpVersionMajor:            The major version of the UMP
        ///                                         specification the endpoint
        ///                                         implements. Defaults to 1.
        /// - Parameter umpVersionMinor:            The minor version of the UMP
        ///                                         specification the endpoint
        ///                                         implements. Defaults to 1.
        /// - Parameter functionBlockCount:         The number of function
        ///                                         blocks (0–32).
        /// - Parameter hasStaticFunctionBlocks:    Whether the endpoint never
        ///                                         changes its function blocks’
        ///                                         properties after discovery.
        /// - Parameter supportsMIDI1Protocol:      Whether the endpoint
        ///                                         supports the MIDI 1.0
        ///                                         Protocol.
        /// - Parameter supportsMIDI2Protocol:      Whether the endpoint
        ///                                         supports the MIDI 2.0
        ///                                         Protocol.
        /// - Parameter receivesJRTimestamps:       Whether the endpoint
        ///                                         supports receiving jitter
        ///                                         reduction timestamps.
        ///                                         Defaults to `false`.
        /// - Parameter transmitsJRTimestamps:      Whether the endpoint
        ///                                         supports sending jitter
        ///                                         reduction timestamps.
        ///                                         Defaults to `false`.
        public init(umpVersionMajor: UInt8 = 1,
                    umpVersionMinor: UInt8 = 1,
                    functionBlockCount: UInt8,
                    hasStaticFunctionBlocks: Bool,
                    supportsMIDI1Protocol: Bool,
                    supportsMIDI2Protocol: Bool,
                    receivesJRTimestamps: Bool = false,
                    transmitsJRTimestamps: Bool = false) {
            self.functionBlockCount = functionBlockCount
            self.hasStaticFunctionBlocks = hasStaticFunctionBlocks
            self.receivesJRTimestamps = receivesJRTimestamps
            self.supportsMIDI1Protocol = supportsMIDI1Protocol
            self.supportsMIDI2Protocol = supportsMIDI2Protocol
            self.transmitsJRTimestamps = transmitsJRTimestamps
            self.umpVersionMajor = umpVersionMajor
            self.umpVersionMinor = umpVersionMinor
        }

        // MARK: Public Instance Properties

        /// The number of function blocks (0–32).
        public let functionBlockCount: UInt8

        /// A Boolean value indicating whether the endpoint never changes its
        /// function blocks’ properties after discovery.
        public let hasStaticFunctionBlocks: Bool

        /// A Boolean value indicating whether the endpoint supports receiving
        /// jitter reduction timestamps.
        public let receivesJRTimestamps: Bool

        /// A Boolean value indicating whether the endpoint supports the
        /// MIDI 1.0 Protocol.
        public let supportsMIDI1Protocol: Bool

        /// A Boolean value indicating whether the endpoint supports the
        /// MIDI 2.0 Protocol.
        public let supportsMIDI2Protocol: Bool

        /// A Boolean value indicating whether the endpoint supports sending
        /// jitter reduction timestamps.
        public let transmitsJRTimestamps: Bool

        /// The major version of the UMP specification the endpoint
        /// implements.
        public let umpVersionMajor: UInt8

        /// The minor version of the UMP specification the endpoint
        /// implements.
        public let umpVersionMinor: UInt8
    }
}

// MARK: - Equatable

extension MIDI2StreamMessage.EndpointInfo: Equatable {
}

// MARK: - Hashable

extension MIDI2StreamMessage.EndpointInfo: Hashable {
}

// MARK: - Sendable

extension MIDI2StreamMessage.EndpointInfo: Sendable {
}
