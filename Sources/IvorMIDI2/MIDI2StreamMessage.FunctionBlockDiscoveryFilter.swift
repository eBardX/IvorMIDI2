// © 2026 John Gary Pusey (see LICENSE.md)

extension MIDI2StreamMessage {

    /// The notifications a function block discovery message requests, each
    /// sent as a separate reply.
    public struct FunctionBlockDiscoveryFilter {

        // MARK: Public Initializers

        /// Creates a `FunctionBlockDiscoveryFilter` instance from its bitmap.
        ///
        /// - Parameter rawValue:   The bitmap. Reserved bits are ignored.
        public init(rawValue: UInt8) {
            self.rawValue = rawValue & 0x03
        }

        // MARK: Public Instance Properties

        /// The bitmap.
        public let rawValue: UInt8
    }
}

// MARK: -

extension MIDI2StreamMessage.FunctionBlockDiscoveryFilter {

    // MARK: Public Type Properties

    /// The option requesting a function block info notification.
    public static let info = Self(rawValue: 0x01)

    /// The option requesting a function block name notification.
    public static let name = Self(rawValue: 0x02)
}

// MARK: - Hashable

extension MIDI2StreamMessage.FunctionBlockDiscoveryFilter: Hashable {
}

// MARK: - OptionSet

extension MIDI2StreamMessage.FunctionBlockDiscoveryFilter: OptionSet {
}

// MARK: - Sendable

extension MIDI2StreamMessage.FunctionBlockDiscoveryFilter: Sendable {
}
