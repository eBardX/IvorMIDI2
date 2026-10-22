// © 2026 John Gary Pusey (see LICENSE.md)

public import IvorMIDI
public import XestiTools

// System common and real-time messages travel in Universal MIDI Packets of
// message type 0x1 (one 32-bit word each). System exclusive messages travel
// in packets of message type 0x3 (7-bit system exclusive data, two words
// each), which carry up to 6 data bytes apiece, without the 0xF0 and 0xF7
// bytes that frame the message on a MIDI 1.0 byte stream.
extension MIDISystemMessage {

    // MARK: Private Type Properties

    private static let sysExBytesPerPacket = 6

    // MARK: Private Type Methods

    // The bytes of a two-word system exclusive packet, padded to 6.
    private static func _dataBytes(of packet: MIDI2Packet) -> [UInt8] {
        [UInt8((packet.word0 >> 8) & 0xff),
         UInt8(packet.word0 & 0xff),
         UInt8(packet.word1 >> 24),
         UInt8((packet.word1 >> 16) & 0xff),
         UInt8((packet.word1 >> 8) & 0xff),
         UInt8(packet.word1 & 0xff)]
    }

    private static func _makeDataPackets(_ dataBytes: [UInt8],
                                         groupField: MIDI2Packet.Word) -> [MIDI2Packet]? {
        guard dataBytes.last == 0xf7
        else { return nil }

        let payload = Array(dataBytes.dropLast())

        guard !payload.isEmpty,
              payload.allSatisfy({ MIDIData1Value.isValid(UInt($0)) })
        else { return nil }

        let chunks = stride(from: 0,
                            to: payload.count,
                            by: sysExBytesPerPacket).map {
            Array(payload[$0..<min($0 + sysExBytesPerPacket, payload.count)])
        }

        var packets: [MIDI2Packet] = []

        for (index, chunk) in chunks.enumerated() {
            let bytes = (chunk + Array(repeating: 0,
                                       count: sysExBytesPerPacket - chunk.count)).map(MIDI2Packet.Word.init)
            let status = UInt32(MIDI2Packet.format(ofPacketAt: index,
                                                   count: chunks.count))

            guard let packet = MIDI2Packet(words: [(0x3 << 28) | groupField | (status << 20)
                                                   | (MIDI2Packet.Word(chunk.count) << 16) | (bytes[0] << 8) | bytes[1],
                                                   (bytes[2] << 24) | (bytes[3] << 16) | (bytes[4] << 8) | bytes[5]])
            else { return nil }

            packets.append(packet)
        }

        return packets
    }

    private static func _makeMessage(fromDataPackets packets: [MIDI2Packet]) -> Self? {
        let group = packets.first?.group
        var payload: [UInt8] = []

        for (index, packet) in packets.enumerated() {
            let byteCount = Int((packet.word0 >> 16) & 0xf)

            guard packet.messageType == 0x3,
                  packet.group == group,
                  (packet.word0 >> 20) & 0xf == UInt32(MIDI2Packet.format(ofPacketAt: index,
                                                                          count: packets.count)),
                  byteCount <= sysExBytesPerPacket
            else { return nil }

            payload += _dataBytes(of: packet).prefix(byteCount)
        }

        return Self(statusByte: 0xf0,
                    dataBytes: payload + [0xf7])
    }

    private static func _makeMessage(fromSystemPacket packet: MIDI2Packet) -> Self? {
        let statusByte = UInt8((packet.word0 >> 16) & 0xff)
        let dataBytes = [UInt8((packet.word0 >> 8) & 0xff),
                         UInt8(packet.word0 & 0xff)]

        // An EOX (0xF7) never has a packet of its own, since system exclusive
        // packets mark where a message ends.
        guard statusByte != 0xf7,
              let edbCount = Self.expectedDataByteCount(for: statusByte)
        else { return nil }

        return Self(statusByte: statusByte,
                    dataBytes: Array(dataBytes.prefix(edbCount)))
    }
}

// MARK: - MIDI2PacketsConvertible

extension MIDISystemMessage: MIDI2PacketsConvertible {

    // MARK: Public Initializers

    /// Creates a `MIDISystemMessage` instance from the Universal MIDI Packets
    /// that encode it, or `nil` if the packets do not encode exactly one
    /// valid system message.
    ///
    /// Every packet must be in the same group; use ``MIDI2Packet/group`` on
    /// the first packet to find which. A system exclusive message’s packets
    /// must be contiguous, so any packets interleaved with them on a stream
    /// must be removed first.
    ///
    /// - Parameter packets:    The packets: one single-word packet for a
    ///                         system common or real-time message, or one
    ///                         two-word packet per 6 data bytes for a system
    ///                         exclusive message.
    public init?(packets: [MIDI2Packet]) {
        guard let first = packets.first
        else { return nil }

        switch first.messageType {
        case 0x1:
            guard packets.count == 1,
                  let message = Self._makeMessage(fromSystemPacket: first)
            else { return nil }

            self = message

        case 0x3:
            guard let message = Self._makeMessage(fromDataPackets: packets)
            else { return nil }

            self = message

        default:
            return nil
        }
    }

    // MARK: Public Instance Methods

    /// Returns this message as one or more Universal MIDI Packets, as
    /// CoreMIDI’s `MIDIEventList` carries them.
    ///
    /// A system common or real-time message becomes one single-word packet
    /// (message type 0x1). A system exclusive message becomes one or
    /// more two-word packets (message type 0x3) of up to 6 data bytes each.
    /// An `eox` message has no encoding of its own, since system exclusive
    /// packets mark where a message ends.
    ///
    /// - Parameter group:  The UMP group. Defaults to group 1.
    ///
    /// - Returns:  The packets, in order, or `nil` if the message cannot be
    ///             encoded.
    public func packets(group: MIDI2Group = 1) -> [MIDI2Packet]? {
        guard let groupByte = group.bytesValue?.first
        else { return nil }

        let groupField = MIDI2Packet.Word(groupByte) << 24

        switch self {
        case .eox:
            return nil

        case let .systemExclusive(dataBytes):
            return Self._makeDataPackets(dataBytes,
                                         groupField: groupField)

        default:
            guard let statusByte,
                  let dataBytes
            else { return nil }

            let data1 = dataBytes.first.map(MIDI2Packet.Word.init) ?? 0
            let data2 = dataBytes.dropFirst().first.map(MIDI2Packet.Word.init) ?? 0

            return MIDI2Packet(words: [(0x1 << 28) | groupField | (MIDI2Packet.Word(statusByte) << 16)
                                       | (data1 << 8) | data2]).map { [$0] }
        }
    }
}
