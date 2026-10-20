// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

/// A System Exclusive 8 message (message type 0x5): system exclusive data
/// whose bytes may use all 8 bits.
///
/// The message travels in one or more four-word packets of up to 13 data
/// bytes each. Its data begins as a MIDI 1.0 system exclusive message’s does,
/// with a manufacturer ID, device ID, and sub-IDs, except that the
/// manufacturer ID is encoded in 16 bits. System Exclusive 8 messages cannot
/// be translated to MIDI 1.0 byte streams.
public struct MIDI2SystemExclusive8Message {

    // MARK: Public Initializers

    /// Creates a `MIDI2SystemExclusive8Message` instance.
    ///
    /// - Parameter streamID:   The stream ID, which lets a sender interleave
    ///                         several messages. Defaults to 0, the only
    ///                         stream ID a device supporting one stream uses.
    /// - Parameter data:       The data bytes.
    public init(streamID: UInt8 = 0,
                data: [UInt8]) {
        self.data = data
        self.streamID = streamID
    }

    // MARK: Public Instance Properties

    /// The data bytes.
    public let data: [UInt8]

    /// The stream ID.
    public let streamID: UInt8
}

// MARK: -

extension MIDI2SystemExclusive8Message {

    // MARK: Private Type Properties

    private static let bytesPerPacket = 13
}

// MARK: - Equatable

extension MIDI2SystemExclusive8Message: Equatable {
}

// MARK: - Hashable

extension MIDI2SystemExclusive8Message: Hashable {
}

// MARK: - MIDI2PacketsConvertible

extension MIDI2SystemExclusive8Message: MIDI2PacketsConvertible {

    // MARK: Public Initializers

    /// Creates a `MIDI2SystemExclusive8Message` instance from the System
    /// Exclusive 8 packets (message type 0x5) that encode it, or `nil` if the
    /// packets do not encode exactly one valid message.
    ///
    /// Every packet must have the same group and stream ID, and the packets
    /// must be contiguous. A message whose sender aborted it (an end packet
    /// whose byte count is 0xF) is not valid.
    ///
    /// - Parameter packets:    The packets, in order.
    public init?(packets: [MIDI2Packet]) {
        guard let first = packets.first,
              MIDI2Packet.isValidFormatSequence(packets.map { UInt8(($0.word0 >> 20) & 0xf) })
        else { return nil }

        let streamID = UInt8((first.word0 >> 8) & 0xff)
        var data: [UInt8] = []

        for packet in packets {
            let byteCount = Int((packet.word0 >> 16) & 0xf)

            guard packet.messageType == 0x5,
                  packet.group == first.group,
                  UInt8((packet.word0 >> 8) & 0xff) == streamID,
                  (1...Self.bytesPerPacket + 1).contains(byteCount)
            else { return nil }

            data += packet.bytes[3..<2 + byteCount]
        }

        self.init(streamID: streamID,
                  data: data)
    }

    // MARK: Public Instance Methods

    /// Returns this message as one or more System Exclusive 8 packets
    /// (message type 0x5) of up to 13 data bytes each.
    ///
    /// - Parameter group:  The UMP group. Defaults to group 1.
    ///
    /// - Returns:  The packets, in order, or `nil` if the message cannot be
    ///             encoded.
    public func packets(group: MIDI2Group = 1) -> [MIDI2Packet]? {
        guard let groupByte = group.bytesValue?.first
        else { return nil }

        let chunks = MIDI2Packet.chunks(of: data,
                                        size: Self.bytesPerPacket)
        var packets: [MIDI2Packet] = []

        for (index, chunk) in chunks.enumerated() {
            let format = MIDI2Packet.format(ofPacketAt: index,
                                            count: chunks.count)
            let header = [0x50 | groupByte, (format << 4) | UInt8(chunk.count + 1), streamID]
            let padding = [UInt8](repeating: 0,
                                  count: Self.bytesPerPacket - chunk.count)

            guard let packet = MIDI2Packet(bytes: header + chunk + padding)
            else { return nil }

            packets.append(packet)
        }

        return packets
    }
}

// MARK: - Sendable

extension MIDI2SystemExclusive8Message: Sendable {
}
