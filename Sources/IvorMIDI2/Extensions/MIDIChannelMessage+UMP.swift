// © 2026 John Gary Pusey (see LICENSE.md)

public import IvorMIDI
public import XestiTools

// MIDI 1.0 channel voice messages travel in Universal MIDI Packets of message
// type 0x2 (one 32-bit word each), with the status and data bytes unchanged.
extension MIDIChannelMessage {

    // MARK: Public Initializers

    /// Creates a `MIDIChannelMessage` instance from a MIDI 1.0 Channel Voice
    /// Message packet (message type 0x2), or `nil` if the packet does not
    /// encode a valid channel message.
    ///
    /// Use ``MIDI2Packet/group`` to find the packet’s group.
    ///
    /// - Parameter packet: The packet. Unused data bytes are ignored.
    public init?(packet: MIDI2Packet) {
        let statusByte = UInt8((packet.word0 >> 16) & 0xff)

        guard packet.messageType == 0x2,
              let edbCount = Self.expectedDataByteCount(for: statusByte)
        else { return nil }

        let dataBytes = [UInt8((packet.word0 >> 8) & 0xff),
                         UInt8(packet.word0 & 0xff)]

        self.init(statusByte: statusByte,
                  dataBytes: Array(dataBytes.prefix(edbCount)))
    }

    // MARK: Public Instance Methods

    /// Returns this message as a MIDI 1.0 Channel Voice Message packet
    /// (message type 0x2), as CoreMIDI’s `MIDIEventList` carries it for
    /// MIDI 1.0.
    ///
    /// - Parameter group:  The UMP group. Defaults to group 1.
    ///
    /// - Returns:  The single-word packet, or `nil` if the message cannot be
    ///             encoded.
    public func packet(group: MIDI2Group = 1) -> MIDI2Packet? {
        guard let groupByte = group.bytesValue?.first,
              let statusByte,
              let dataBytes
        else { return nil }

        let data1 = dataBytes.first.map(MIDI2Packet.Word.init) ?? 0
        let data2 = dataBytes.dropFirst().first.map(MIDI2Packet.Word.init) ?? 0

        return MIDI2Packet(words: [(0x2 << 28) | (MIDI2Packet.Word(groupByte) << 24) | (MIDI2Packet.Word(statusByte) << 16)
                                   | (data1 << 8) | data2])
    }
}

// MARK: - MIDI2PacketsConvertible

extension MIDIChannelMessage: MIDI2PacketsConvertible {

    // MARK: Public Initializers

    /// Creates a `MIDIChannelMessage` instance from a single MIDI 1.0 Channel
    /// Voice Message packet (message type 0x2), or `nil` if the packets do
    /// not encode exactly one valid channel message.
    ///
    /// - Parameter packets:    The packets. Must hold exactly one packet.
    public init?(packets: [MIDI2Packet]) {
        guard packets.count == 1
        else { return nil }

        self.init(packet: packets[0])
    }

    // MARK: Public Instance Methods

    /// Returns this message as a single MIDI 1.0 Channel Voice Message packet
    /// (message type 0x2).
    ///
    /// - Parameter group:  The UMP group. Defaults to group 1.
    ///
    /// - Returns:  The single packet, or `nil` if the message cannot be
    ///             encoded.
    public func packets(group: MIDI2Group = 1) -> [MIDI2Packet]? {
        packet(group: group).map { [$0] }
    }
}
