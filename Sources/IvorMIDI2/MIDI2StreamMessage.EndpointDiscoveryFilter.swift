// © 2026 John Gary Pusey (see LICENSE.md)

extension MIDI2StreamMessage {

    /// The notifications an endpoint discovery message requests, each sent
    /// as a separate reply.
    public struct EndpointDiscoveryFilter {

        // MARK: Public Initializers

        /// Creates an `EndpointDiscoveryFilter` instance from its bitmap.
        ///
        /// - Parameter rawValue:   The bitmap. Reserved bits are ignored.
        public init(rawValue: UInt8) {
            self.rawValue = rawValue & 0x1f
        }

        // MARK: Public Instance Properties

        /// The bitmap.
        public let rawValue: UInt8
    }
}

// MARK: -

extension MIDI2StreamMessage.EndpointDiscoveryFilter {

    // MARK: Public Type Properties

    /// The option requesting a device identity notification.
    public static let deviceIdentity = Self(rawValue: 0x02)

    /// The option requesting an endpoint info notification.
    public static let endpointInfo = Self(rawValue: 0x01)

    /// The option requesting an endpoint name notification.
    public static let endpointName = Self(rawValue: 0x04)

    /// The option requesting a product instance ID notification.
    public static let productInstanceID = Self(rawValue: 0x08)

    /// The option requesting a stream configuration notification.
    public static let streamConfiguration = Self(rawValue: 0x10)
}

// MARK: - Hashable

extension MIDI2StreamMessage.EndpointDiscoveryFilter: Hashable {
}

// MARK: - OptionSet

extension MIDI2StreamMessage.EndpointDiscoveryFilter: OptionSet {
}

// MARK: - Sendable

extension MIDI2StreamMessage.EndpointDiscoveryFilter: Sendable {
}
