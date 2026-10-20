// © 2026 John Gary Pusey (see LICENSE.md)

public import IvorMIDI

/// A message of any kind that travels in Universal MIDI Packets.
///
/// Each case holds a message of one family, together with its group if the
/// family has one. Use ``MIDI2MessageReader`` to read the messages of a
/// stream of packets.
public enum MIDI2Message {

    /// A Flex Data message (message type 0xD) in a group.
    case flexData(MIDI2FlexDataMessage, MIDI2Group)

    /// A MIDI 1.0 channel voice message (message type 0x2) in a group.
    case midi1ChannelVoice(MIDIChannelMessage, MIDI2Group)

    /// A MIDI 2.0 channel voice message (message type 0x4) in a group.
    case midi2ChannelVoice(MIDI2ChannelMessage, MIDI2Group)

    /// A UMP stream message (message type 0xF).
    case stream(MIDI2StreamMessage)

    /// A system common, system real-time (message type 0x1), or 7-bit system
    /// exclusive (message type 0x3) message in a group.
    case system(MIDISystemMessage, MIDI2Group)

    /// A System Exclusive 8 message (message type 0x5) in a group.
    case systemExclusive8(MIDI2SystemExclusive8Message, MIDI2Group)

    /// A packet that ``MIDI2MessageReader`` could not decode: a packet of a
    /// reserved message type, a Mixed Data Set packet, a packet that does
    /// not encode a valid message, or a packet of a multi-packet message
    /// that was interrupted or never completed.
    case unrecognized(MIDI2Packet)

    /// A utility message (message type 0x0).
    case utility(MIDI2UtilityMessage)

    // MARK: Public Initializers

    /// Creates a `MIDI2Message` instance from the Universal MIDI Packets that
    /// encode it, or `nil` if the packets do not encode exactly one valid
    /// message.
    ///
    /// The first packet’s message type selects the message family. This
    /// initializer never creates an ``unrecognized(_:)`` message.
    ///
    /// - Parameter packets:    The packets, in order.
    public init?(packets: [MIDI2Packet]) {
        guard let first = packets.first
        else { return nil }

        let message: Self?
        let group = first.group

        switch first.messageType {
        case 0x0:
            message = MIDI2UtilityMessage(packets: packets).map { .utility($0) }

        case 0x1,
             0x3:
            message = group.flatMap { group in MIDISystemMessage(packets: packets).map { .system($0, group) } }

        case 0x2:
            message = group.flatMap { group in MIDIChannelMessage(packets: packets).map { .midi1ChannelVoice($0, group) } }

        case 0x4:
            message = group.flatMap { group in MIDI2ChannelMessage(packets: packets).map { .midi2ChannelVoice($0, group) } }

        case 0x5:
            message = group.flatMap { group in
                MIDI2SystemExclusive8Message(packets: packets).map { .systemExclusive8($0, group) }
            }

        case 0xd:
            message = group.flatMap { group in MIDI2FlexDataMessage(packets: packets).map { .flexData($0, group) } }

        case 0xf:
            message = MIDI2StreamMessage(packets: packets).map { .stream($0) }

        default:
            message = nil
        }

        guard let message
        else { return nil }

        self = message
    }
}

// MARK: -

extension MIDI2Message {

    // MARK: Public Instance Properties

    /// The message’s group, or `nil` if the message is groupless.
    public var group: MIDI2Group? {
        switch self {
        case let .flexData(_, group),
             let .midi1ChannelVoice(_, group),
             let .midi2ChannelVoice(_, group),
             let .system(_, group),
             let .systemExclusive8(_, group):
            group

        case .stream,
             .utility:
            nil

        case let .unrecognized(packet):
            packet.group
        }
    }

    // MARK: Public Instance Methods

    /// Returns this message as one or more Universal MIDI Packets.
    ///
    /// - Returns:  The packets, in order, or `nil` if the message cannot be
    ///             encoded.
    public func packets() -> [MIDI2Packet]? {
        switch self {
        case let .flexData(message, group):
            message.packets(group: group)

        case let .midi1ChannelVoice(message, group):
            message.packets(group: group)

        case let .midi2ChannelVoice(message, group):
            message.packets(group: group)

        case let .stream(message):
            message.packets()

        case let .system(message, group):
            message.packets(group: group)

        case let .systemExclusive8(message, group):
            message.packets(group: group)

        case let .unrecognized(packet):
            [packet]

        case let .utility(message):
            message.packets()
        }
    }
}

// MARK: - Equatable

extension MIDI2Message: Equatable {
}

// MARK: - Hashable

extension MIDI2Message: Hashable {
}

// MARK: - Sendable

extension MIDI2Message: Sendable {
}
