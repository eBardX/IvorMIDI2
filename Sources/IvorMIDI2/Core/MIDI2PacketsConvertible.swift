// © 2026 John Gary Pusey (see LICENSE.md)

/// A type that can be converted to and from the Universal MIDI Packets that
/// encode it in a group.
public protocol MIDI2PacketsConvertible {

    // MARK: Public Initializers

    /// Creates an instance from the Universal MIDI Packets that encode it, or
    /// `nil` if the packets do not encode exactly one valid instance.
    ///
    /// The packets carry the group; use ``MIDI2Packet/group`` on the first
    /// packet to find it.
    ///
    /// - Parameter packets:    The packets, in order.
    init?(packets: [MIDI2Packet])

    // MARK: Public Instance Methods

    /// Returns this instance as one or more Universal MIDI Packets in the
    /// provided group.
    ///
    /// - Parameter group:  The UMP group.
    ///
    /// - Returns:  The packets, in order, or `nil` if this instance cannot be
    ///             encoded.
    func packets(group: MIDI2Group) -> [MIDI2Packet]?
}
