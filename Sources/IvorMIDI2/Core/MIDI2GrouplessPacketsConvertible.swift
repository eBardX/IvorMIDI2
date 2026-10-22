// © 2026 John Gary Pusey (see LICENSE.md)

/// A type that can be converted to and from the Universal MIDI Packets that
/// encode it without a group.
///
/// Utility messages (message type 0x0) and UMP stream messages (message type
/// 0xF) are groupless: they address the UMP endpoint as a whole.
public protocol MIDI2GrouplessPacketsConvertible {

    // MARK: Public Initializers

    /// Creates an instance from the Universal MIDI Packets that encode it, or
    /// `nil` if the packets do not encode exactly one valid instance.
    ///
    /// - Parameter packets:    The packets, in order.
    init?(packets: [MIDI2Packet])

    // MARK: Public Instance Methods

    /// Returns this instance as one or more Universal MIDI Packets.
    ///
    /// - Returns:  The packets, in order, or `nil` if this instance cannot be
    ///             encoded.
    func packets() -> [MIDI2Packet]?
}
