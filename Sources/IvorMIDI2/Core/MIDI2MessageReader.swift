// © 2026 John Gary Pusey (see LICENSE.md)

/// A reader of the messages in a stream of Universal MIDI Packets.
///
/// A reader splits 32-bit words into packets, reassembles messages that span
/// several packets, and emits each message once its last packet arrives:
///
/// ```swift
/// var reader = MIDI2MessageReader()
///
/// for words in received {
///     for message in reader.read(words: words) {
///         handle(message)
///     }
/// }
/// ```
///
/// Words may arrive in any grouping; a reader keeps the words of an
/// incomplete packet until the rest arrive. A reader follows the UMP
/// specification’s rules for interleaving:
///
/// - Within a group, a 7-bit system exclusive or Flex Data message may be
///   interleaved only with system real-time messages, and with groupless
///   messages such as JR clocks. Any other packet in the group interrupts it.
/// - System Exclusive 8 messages may be interleaved with anything, including
///   each other when their stream IDs differ.
/// - A UMP stream message spanning several packets is interrupted by any
///   other UMP stream message.
///
/// A message that is interrupted, or whose packets do not decode, is emitted
/// packet by packet as ``MIDI2Message/unrecognized(_:)`` messages.
public struct MIDI2MessageReader {

    // MARK: Public Initializers

    /// Creates a `MIDI2MessageReader` instance with no pending packets or
    /// words.
    public init() {
    }

    // MARK: Private Instance Properties

    // The packets of the 7-bit system exclusive or Flex Data message pending
    // in each group.
    private var exclusivePackets: [MIDI2Group: [MIDI2Packet]] = [:]

    // The words of an incomplete packet.
    private var partialWords: [MIDI2Packet.Word] = []

    // The packets of the pending UMP stream message.
    private var streamPackets: [MIDI2Packet]?

    // The packets of the System Exclusive 8 message pending in each group and
    // stream, keyed by the zero-based group number and the stream ID.
    private var sysEx8Packets: [UInt16: [MIDI2Packet]] = [:]
}

// MARK: -

extension MIDI2MessageReader {

    // MARK: Public Instance Methods

    /// Ends the stream, returning the packets of any incomplete messages as
    /// ``MIDI2Message/unrecognized(_:)`` messages and discarding the words of
    /// any incomplete packet.
    ///
    /// The reader is then ready to read a new stream.
    ///
    /// - Returns:  The pending packets, as unrecognized messages.
    public mutating func finish() -> [MIDI2Message] {
        let pending = exclusivePackets.keys.sorted().flatMap { exclusivePackets[$0] ?? [] }
            + sysEx8Packets.keys.sorted().flatMap { sysEx8Packets[$0] ?? [] }
            + (streamPackets ?? [])

        exclusivePackets = [:]
        partialWords = []
        streamPackets = nil
        sysEx8Packets = [:]

        return pending.map { .unrecognized($0) }
    }

    /// Reads a packet, returning the messages it completes.
    ///
    /// - Parameter packet: The packet.
    ///
    /// - Returns:  The messages the packet completes, in order: none if the
    ///             packet starts or continues a message, otherwise the
    ///             packet’s own message, preceded by any message it
    ///             interrupts.
    public mutating func read(_ packet: MIDI2Packet) -> [MIDI2Message] {
        var messages: [MIDI2Message] = []

        if let group = packet.group,
           let pending = exclusivePackets[group],
           !Self._isContinuation(packet, of: pending),
           !Self._isSystemRealTime(packet) {
            messages += Self._interrupt(&exclusivePackets[group])
        }

        switch packet.messageType {
        case 0x3,
             0xd:
            guard let group = packet.group
            else { return messages }

            messages += Self._read(packet,
                                   into: &exclusivePackets[group])

        case 0x5 where (packet.word0 >> 20) & 0xf <= 0x3:
            let key = (UInt16(packet.bytes[0] & 0xf) << 8) | UInt16(packet.bytes[2])

            messages += Self._read(packet,
                                   into: &sysEx8Packets[key])

        case 0xf:
            messages += Self._read(packet,
                                   into: &streamPackets)

        default:
            messages += Self._decode([packet])
        }

        return messages
    }

    /// Reads 32-bit words, returning the messages they complete.
    ///
    /// The words need not hold whole packets: the reader keeps the words of
    /// an incomplete packet until the next call.
    ///
    /// - Parameter words:  The words.
    ///
    /// - Returns:  The messages the words complete, in order.
    public mutating func read(words: some Sequence<MIDI2Packet.Word>) -> [MIDI2Message] {
        partialWords += words

        var messages: [MIDI2Message] = []
        var index = 0

        while index < partialWords.count {
            let end = index + MIDI2Packet.wordCount(forUniversalMIDIPacket: partialWords[index])

            guard end <= partialWords.count,
                  let packet = MIDI2Packet(words: partialWords[index..<end])
            else { break }

            messages += read(packet)

            index = end
        }

        partialWords.removeFirst(index)

        return messages
    }

    // MARK: Private Type Methods

    private static func _decode(_ packets: [MIDI2Packet]) -> [MIDI2Message] {
        guard let message = MIDI2Message(packets: packets)
        else { return packets.map { .unrecognized($0) } }

        return [message]
    }

    // The format of a packet of a message type whose messages may span
    // several packets: complete (0x0), start (0x1), continue (0x2), or end
    // (0x3), or a reserved value.
    private static func _format(of packet: MIDI2Packet) -> UInt32 {
        switch packet.messageType {
        case 0xd:
            (packet.word0 >> 22) & 0x3

        case 0xf:
            (packet.word0 >> 26) & 0x3

        default:
            (packet.word0 >> 20) & 0xf
        }
    }

    // Returns the pending packets as unrecognized messages, ending the
    // pending message.
    private static func _interrupt(_ pending: inout [MIDI2Packet]?) -> [MIDI2Message] {
        defer { pending = nil }

        return (pending ?? []).map { .unrecognized($0) }
    }

    private static func _isContinuation(_ packet: MIDI2Packet,
                                        of pending: [MIDI2Packet]) -> Bool {
        packet.messageType == pending.first?.messageType && [0x2, 0x3].contains(_format(of: packet))
    }

    private static func _isSystemRealTime(_ packet: MIDI2Packet) -> Bool {
        packet.messageType == 0x1 && (packet.word0 >> 16) & 0xff >= 0xf8
    }

    // Reads a packet of a message that may span several packets, given the
    // packets of the message pending in its place.
    private static func _read(_ packet: MIDI2Packet,
                              into pending: inout [MIDI2Packet]?) -> [MIDI2Message] {
        switch _format(of: packet) {
        case 0x0:
            return _interrupt(&pending) + _decode([packet])

        case 0x1:
            defer { pending = [packet] }

            return _interrupt(&pending)

        case 0x2:
            guard pending != nil
            else { return [.unrecognized(packet)] }

            pending?.append(packet)

            return []

        case 0x3:
            guard let packets = pending
            else { return [.unrecognized(packet)] }

            pending = nil

            return _decode(packets + [packet])

        default:
            return [.unrecognized(packet)]
        }
    }
}

// MARK: - Sendable

extension MIDI2MessageReader: Sendable {
}
