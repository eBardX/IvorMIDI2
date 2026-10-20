// © 2026 John Gary Pusey (see LICENSE.md)

internal import IvorMIDI

/// A UMP stream message (message type 0xF), addressed to a UMP endpoint as a
/// whole.
///
/// UMP stream messages discover an endpoint and its function blocks, select
/// the protocol and jitter reduction timestamps of a stream, and mark the
/// start and end of a MIDI Clip File’s sequence data. They travel in
/// four-word groupless packets; names span several packets.
public enum MIDI2StreamMessage {

    /// A device identity notification.
    case deviceIdentityNotification(DeviceIdentity)

    /// An end of clip message: the last event of a MIDI Clip File’s
    /// sequence data.
    case endOfClip

    /// An endpoint discovery message, requesting the notifications in the
    /// filter, from a device implementing the given version of the UMP
    /// specification.
    case endpointDiscovery(umpVersionMajor: UInt8, umpVersionMinor: UInt8, filter: EndpointDiscoveryFilter)

    /// An endpoint info notification.
    case endpointInfoNotification(EndpointInfo)

    /// An endpoint name notification: the endpoint’s name, of up to 98 UTF-8
    /// bytes.
    case endpointNameNotification(String)

    /// A function block discovery message, requesting the notifications in
    /// the filter about one function block (0–31), or about all function
    /// blocks if `nil`.
    case functionBlockDiscovery(UInt8?, FunctionBlockDiscoveryFilter)

    /// A function block info notification.
    case functionBlockInfoNotification(FunctionBlockInfo)

    /// A function block name notification: the function block’s number
    /// (0–31) and its name, of up to 91 UTF-8 bytes.
    case functionBlockNameNotification(UInt8, String)

    /// A product instance ID notification: an ID that is unique for the
    /// device’s manufacturer, family, and model, such as its serial number,
    /// of up to 42 printable ASCII characters.
    case productInstanceIDNotification(String)

    /// A start of clip message: the first event of a MIDI Clip File’s
    /// sequence data.
    case startOfClip

    /// A stream configuration notification, declaring the protocol and
    /// jitter reduction timestamps the endpoint sends and receives.
    case streamConfigurationNotification(StreamConfiguration)

    /// A stream configuration request, asking the receiving endpoint to use
    /// a protocol and jitter reduction timestamps.
    case streamConfigurationRequest(StreamConfiguration)
}

// MARK: -

extension MIDI2StreamMessage {

    // MARK: Private Type Properties

    private static let bytesPerPacket = 14

    // MARK: Private Type Methods

    private static func _makeDeviceIdentity(_ payload: [UInt8]) -> DeviceIdentity {
        DeviceIdentity(manufacturerID: payload[3...5].map { $0 & 0x7f },
                       family: MIDIData2Value(msb: MIDIData1Value(clamping: payload[7] & 0x7f),
                                              lsb: MIDIData1Value(clamping: payload[6] & 0x7f)),
                       model: MIDIData2Value(msb: MIDIData1Value(clamping: payload[9] & 0x7f),
                                             lsb: MIDIData1Value(clamping: payload[8] & 0x7f)),
                       softwareRevision: payload[10...13].map { $0 & 0x7f })
    }

    private static func _makeEndpointInfo(_ payload: [UInt8]) -> EndpointInfo? {
        guard payload[2] & 0x7f <= 32
        else { return nil }

        return EndpointInfo(umpVersionMajor: payload[0],
                            umpVersionMinor: payload[1],
                            functionBlockCount: payload[2] & 0x7f,
                            hasStaticFunctionBlocks: payload[2] & 0x80 != 0,
                            supportsMIDI1Protocol: payload[4] & 0x01 != 0,
                            supportsMIDI2Protocol: payload[4] & 0x02 != 0,
                            receivesJRTimestamps: payload[5] & 0x02 != 0,
                            transmitsJRTimestamps: payload[5] & 0x01 != 0)
    }

    private static func _makeFunctionBlockInfo(_ payload: [UInt8]) -> FunctionBlockInfo? {
        guard payload[0] & 0x7f <= 31,
              let direction = FunctionBlockInfo.Direction(rawValue: payload[1] & 0x3),
              let midi1Port = FunctionBlockInfo.MIDI1Port(rawValue: (payload[1] >> 2) & 0x3),
              let uiHint = FunctionBlockInfo.UIHint(rawValue: (payload[1] >> 4) & 0x3),
              let firstGroup = MIDI2Group(bytesValue: [payload[2]]),
              (1...16).contains(payload[3])
        else { return nil }

        return FunctionBlockInfo(number: payload[0] & 0x7f,
                                 isActive: payload[0] & 0x80 != 0,
                                 direction: direction,
                                 uiHint: uiHint,
                                 midi1Port: midi1Port,
                                 firstGroup: firstGroup,
                                 groupCount: payload[3],
                                 midiCIVersion: payload[4],
                                 maxSysEx8Streams: payload[5])
    }

    // Makes a message from the 14 payload bytes of a single packet.
    private static func _makeMessage(_ status: UInt16,
                                     _ payload: [UInt8]) -> Self? {
        switch status {
        case 0x000:
            .endpointDiscovery(umpVersionMajor: payload[0],
                               umpVersionMinor: payload[1],
                               filter: EndpointDiscoveryFilter(rawValue: payload[5]))

        case 0x001:
            _makeEndpointInfo(payload).map { .endpointInfoNotification($0) }

        case 0x002:
            .deviceIdentityNotification(_makeDeviceIdentity(payload))

        case 0x005:
            _makeStreamConfiguration(payload).map { .streamConfigurationRequest($0) }

        case 0x006:
            _makeStreamConfiguration(payload).map { .streamConfigurationNotification($0) }

        case 0x010:
            switch payload[0] {
            case 0x00...0x1f:
                .functionBlockDiscovery(payload[0], FunctionBlockDiscoveryFilter(rawValue: payload[1]))

            case 0xff:
                .functionBlockDiscovery(nil, FunctionBlockDiscoveryFilter(rawValue: payload[1]))

            default:
                nil
            }

        case 0x011:
            _makeFunctionBlockInfo(payload).map { .functionBlockInfoNotification($0) }

        case 0x020:
            .startOfClip

        case 0x021:
            .endOfClip

        default:
            nil
        }
    }

    private static func _makePacket(_ status: UInt16,
                                    _ format: UInt8,
                                    _ payload: [UInt8]) -> MIDI2Packet? {
        guard payload.count <= bytesPerPacket
        else { return nil }

        let header = [0xf0 | (format << 2) | UInt8(status >> 8), UInt8(truncatingIfNeeded: status)]
        let padding = [UInt8](repeating: 0,
                              count: bytesPerPacket - payload.count)

        return MIDI2Packet(bytes: header + payload + padding)
    }

    private static func _makeStreamConfiguration(_ payload: [UInt8]) -> StreamConfiguration? {
        MIDIProtocol(rawValue: payload[0]).map {
            StreamConfiguration(midiProtocol: $0,
                                receivesJRTimestamps: payload[1] & 0x02 != 0,
                                transmitsJRTimestamps: payload[1] & 0x01 != 0)
        }
    }

    // Makes the packets of a name, each starting with the prefix bytes.
    private static func _makeTextPackets(_ status: UInt16,
                                         _ prefix: [UInt8],
                                         _ text: String,
                                         maxByteCount: Int) -> [MIDI2Packet]? {
        guard let bytes = MIDI2Packet.textBytes(of: text),
              bytes.count <= maxByteCount
        else { return nil }

        let chunks = MIDI2Packet.chunks(of: bytes,
                                        size: bytesPerPacket - prefix.count)
        var packets: [MIDI2Packet] = []

        for (index, chunk) in chunks.enumerated() {
            guard let packet = _makePacket(status,
                                           MIDI2Packet.format(ofPacketAt: index,
                                                              count: chunks.count),
                                           prefix + chunk)
            else { return nil }

            packets.append(packet)
        }

        return packets
    }

    private static func _status(of packet: MIDI2Packet) -> UInt16 {
        UInt16((packet.word0 >> 16) & 0x3ff)
    }

    // MARK: Private Instance Methods

    private func _deviceIdentityPayload(_ identity: DeviceIdentity) -> [UInt8]? {
        let bytes = identity.manufacturerID + identity.softwareRevision

        guard identity.manufacturerID.count == 3,
              identity.softwareRevision.count == 4,
              bytes.allSatisfy({ $0 <= 0x7f })
        else { return nil }

        return [0x00, 0x00, 0x00]
            + identity.manufacturerID
            + [identity.family.lsb, identity.family.msb, identity.model.lsb, identity.model.msb].map {
                UInt8(truncatingIfNeeded: $0.uintValue)
            }
            + identity.softwareRevision
    }

    private func _endpointInfoPayload(_ info: EndpointInfo) -> [UInt8]? {
        guard info.functionBlockCount <= 32
        else { return nil }

        return [info.umpVersionMajor,
                info.umpVersionMinor,
                (info.hasStaticFunctionBlocks ? 0x80 : 0) | info.functionBlockCount,
                0x00,
                (info.supportsMIDI2Protocol ? 0x02 : 0) | (info.supportsMIDI1Protocol ? 0x01 : 0),
                (info.receivesJRTimestamps ? 0x02 : 0) | (info.transmitsJRTimestamps ? 0x01 : 0)]
    }

    private func _functionBlockInfoPayload(_ info: FunctionBlockInfo) -> [UInt8]? {
        guard info.number <= 31,
              (1...16).contains(info.groupCount),
              let firstGroupByte = info.firstGroup.bytesValue?.first
        else { return nil }

        return [(info.isActive ? 0x80 : 0) | info.number,
                (info.uiHint.rawValue << 4) | (info.midi1Port.rawValue << 2) | info.direction.rawValue,
                firstGroupByte,
                info.groupCount,
                info.midiCIVersion,
                info.maxSysEx8Streams]
    }

    // The status and payload of this message’s single packet, or `nil` if it
    // cannot be encoded.
    private func _singlePacketFields() -> (UInt16, [UInt8])? {
        switch self {
        case let .deviceIdentityNotification(identity):
            _deviceIdentityPayload(identity).map { (0x002, $0) }

        case .endOfClip:
            (0x021, [])

        case let .endpointDiscovery(major, minor, filter):
            (0x000, [major, minor, 0x00, 0x00, 0x00, filter.rawValue])

        case let .endpointInfoNotification(info):
            _endpointInfoPayload(info).map { (0x001, $0) }

        case .endpointNameNotification,
             .functionBlockNameNotification,
             .productInstanceIDNotification:
            nil

        case let .functionBlockDiscovery(number, filter):
            (number ?? 0) <= 31 ? (0x010, [number ?? 0xff, filter.rawValue]) : nil

        case let .functionBlockInfoNotification(info):
            _functionBlockInfoPayload(info).map { (0x011, $0) }

        case .startOfClip:
            (0x020, [])

        case let .streamConfigurationNotification(configuration):
            (0x006, _streamConfigurationPayload(configuration))

        case let .streamConfigurationRequest(configuration):
            (0x005, _streamConfigurationPayload(configuration))
        }
    }

    private func _streamConfigurationPayload(_ configuration: StreamConfiguration) -> [UInt8] {
        [configuration.midiProtocol.rawValue,
         (configuration.receivesJRTimestamps ? 0x02 : 0) | (configuration.transmitsJRTimestamps ? 0x01 : 0)]
    }
}

// MARK: - Equatable

extension MIDI2StreamMessage: Equatable {
}

// MARK: - Hashable

extension MIDI2StreamMessage: Hashable {
}

// MARK: - MIDI2GrouplessPacketsConvertible

extension MIDI2StreamMessage: MIDI2GrouplessPacketsConvertible {

    // MARK: Public Initializers

    /// Creates a `MIDI2StreamMessage` instance from the UMP stream message
    /// packets (message type 0xF) that encode it, or `nil` if the packets do
    /// not encode exactly one valid message.
    ///
    /// Every packet of a name must have the same status (and function block
    /// number), and the packets must be contiguous. Reserved fields are
    /// ignored.
    ///
    /// - Parameter packets:    The packets, in order: a single packet, or up
    ///                         to 7 for an endpoint or function block name
    ///                         and up to 3 for a product instance ID.
    public init?(packets: [MIDI2Packet]) {
        guard let first = packets.first,
              packets.allSatisfy({ $0.messageType == 0xf && Self._status(of: $0) == Self._status(of: first) }),
              MIDI2Packet.isValidFormatSequence(packets.map { UInt8(($0.word0 >> 26) & 0x3) })
        else { return nil }

        let message: Self?

        switch Self._status(of: first) {
        case 0x003:
            message = packets.count <= 7
                ? MIDI2Packet.text(from: packets.flatMap { $0.bytes.dropFirst(2) }).map { .endpointNameNotification($0) }
                : nil

        case 0x004:
            message = packets.count <= 3
                ? MIDI2Packet.text(from: packets.flatMap { $0.bytes.dropFirst(2) }).flatMap {
                    $0.utf8.allSatisfy { (32...126).contains($0) } ? .productInstanceIDNotification($0) : nil
                }
                : nil

        case 0x012:
            let number = first.bytes[2]

            message = packets.count <= 7 && number <= 31 && packets.allSatisfy { $0.bytes[2] == number }
                ? MIDI2Packet.text(from: packets.flatMap { $0.bytes.dropFirst(3) }).map {
                    .functionBlockNameNotification(number, $0)
                }
                : nil

        case let status:
            message = packets.count == 1 ? Self._makeMessage(status, Array(first.bytes.dropFirst(2))) : nil
        }

        guard let message
        else { return nil }

        self = message
    }

    // MARK: Public Instance Methods

    /// Returns this message as one or more UMP stream message packets
    /// (message type 0xF).
    ///
    /// - Returns:  The packets, in order, or `nil` if the message cannot be
    ///             encoded: a value is out of range, a name is too long or
    ///             holds a null character, or a product instance ID holds a
    ///             character that is not printable ASCII.
    public func packets() -> [MIDI2Packet]? {
        switch self {
        case let .endpointNameNotification(name):
            return Self._makeTextPackets(0x003,
                                         [],
                                         name,
                                         maxByteCount: 98)

        case let .functionBlockNameNotification(number, name):
            guard number <= 31
            else { return nil }

            return Self._makeTextPackets(0x012,
                                         [number],
                                         name,
                                         maxByteCount: 91)

        case let .productInstanceIDNotification(id):
            guard id.utf8.allSatisfy({ (32...126).contains($0) })
            else { return nil }

            return Self._makeTextPackets(0x004,
                                         [],
                                         id,
                                         maxByteCount: 42)

        default:
            guard let (status, payload) = _singlePacketFields()
            else { return nil }

            return Self._makePacket(status, 0, payload).map { [$0] }
        }
    }
}

// MARK: - Sendable

extension MIDI2StreamMessage: Sendable {
}
