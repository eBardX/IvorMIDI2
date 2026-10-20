// © 2026 John Gary Pusey (see LICENSE.md)

public import IvorMIDI
public import XestiTools

/// A MIDI 2.0 channel voice message (message type 0x4).
///
/// MIDI 2.0 channel voice messages are two-word packets with higher
/// resolution than their MIDI 1.0 counterparts: 16-bit velocities and 32-bit
/// controller values. They add per-note controllers and per-note pitch bend,
/// and they replace MIDI 1.0’s compound sequences for registered and
/// non-registered parameters and bank selection with single messages.
///
/// A device that uses these messages in a group must not use MIDI 1.0
/// channel voice messages in the same group.
public enum MIDI2ChannelMessage {

    /// An assignable controller (NRPN) message, setting the controller to a
    /// 32-bit value.
    case assignableController(MIDIChannel, MIDINonRegisteredParameter, UInt32)

    /// An assignable per-note controller message: the note number, the
    /// controller index (0–255), and the controller’s 32-bit value.
    case assignablePerNoteController(MIDIChannel, MIDIData1Value, UInt8, UInt32)

    /// A channel pressure (aftertouch) message with a 32-bit pressure.
    case channelPressure(MIDIChannel, UInt32)

    /// A control change message with a 32-bit value.
    ///
    /// Senders should not use the bank select (0 and 32), data entry (6 and
    /// 38), or parameter number (98–101) controllers, which MIDI 2.0
    /// replaces with ``programChange(_:_:_:)``,
    /// ``registeredController(_:_:_:)``, and
    /// ``assignableController(_:_:_:)``; receivers should ignore them.
    case controlChange(MIDIChannel, MIDIController, UInt32)

    /// A note off message: the note number, the 16-bit velocity, and an
    /// optional attribute.
    case noteOff(MIDIChannel, MIDIData1Value, UInt16, MIDI2NoteAttribute?)

    /// A note on message: the note number, the 16-bit velocity, and an
    /// optional attribute.
    ///
    /// Unlike MIDI 1.0, a velocity of zero does not mean note off.
    case noteOn(MIDIChannel, MIDIData1Value, UInt16, MIDI2NoteAttribute?)

    /// A per-note management message: the note number, whether to detach
    /// per-note controllers from notes already received on that note
    /// number, and whether to reset per-note controllers to their defaults.
    case perNoteManagement(MIDIChannel, MIDIData1Value, detach: Bool, reset: Bool)

    /// A per-note pitch bend message: the note number and a 32-bit unsigned
    /// bipolar value, centered at 0x80000000.
    case perNotePitchBendChange(MIDIChannel, MIDIData1Value, UInt32)

    /// A pitch bend change message with a 32-bit unsigned bipolar value,
    /// centered at 0x80000000.
    case pitchBendChange(MIDIChannel, UInt32)

    /// A polyphonic key pressure (aftertouch) message: the note number and
    /// a 32-bit pressure.
    case polyphonicPressure(MIDIChannel, MIDIData1Value, UInt32)

    /// A program change message, optionally selecting a bank first.
    case programChange(MIDIChannel, MIDIProgram, MIDIData2Value?)

    /// A registered controller (RPN) message, setting the controller to a
    /// 32-bit value.
    case registeredController(MIDIChannel, MIDIRegisteredParameter, UInt32)

    /// A registered per-note controller message: the note number, the
    /// controller index (0–255), and the controller’s 32-bit value.
    case registeredPerNoteController(MIDIChannel, MIDIData1Value, UInt8, UInt32)

    /// A relative assignable controller (NRPN) message, changing the
    /// controller by a signed 32-bit amount.
    case relativeAssignableController(MIDIChannel, MIDINonRegisteredParameter, Int32)

    /// A relative registered controller (RPN) message, changing the
    /// controller by a signed 32-bit amount.
    case relativeRegisteredController(MIDIChannel, MIDIRegisteredParameter, Int32)
}

// MARK: -

extension MIDI2ChannelMessage {

    // MARK: Public Instance Properties

    /// The MIDI channel the message addresses.
    public var channel: MIDIChannel {
        switch self {
        case let .assignableController(channel, _, _),
             let .assignablePerNoteController(channel, _, _, _),
             let .channelPressure(channel, _),
             let .controlChange(channel, _, _),
             let .noteOff(channel, _, _, _),
             let .noteOn(channel, _, _, _),
             let .perNoteManagement(channel, _, _, _),
             let .perNotePitchBendChange(channel, _, _),
             let .pitchBendChange(channel, _),
             let .polyphonicPressure(channel, _, _),
             let .programChange(channel, _, _),
             let .registeredController(channel, _, _),
             let .registeredPerNoteController(channel, _, _, _),
             let .relativeAssignableController(channel, _, _),
             let .relativeRegisteredController(channel, _, _):
            channel
        }
    }

    // MARK: Private Type Methods

    // The bank and index of a registered or assignable controller number.
    private static func _bankAndIndex(_ number: UInt) -> UInt32 {
        (UInt32(number >> 7) << 8) | UInt32(number & 0x7f)
    }

    // Byte 2 holds a note number, controller index, or bank, and byte 3 a
    // controller index, attribute type, or option flags. Each 7-bit field’s
    // reserved high bit is ignored.
    private static func _makeMessage(_ status: UInt32,
                                     _ channel: MIDIChannel,
                                     _ byte2: UInt8,
                                     _ byte3: UInt8,
                                     _ data: UInt32) -> Self? {
        let note = MIDIData1Value(clamping: byte2 & 0x7f)
        let number = (UInt(byte2 & 0x7f) << 7) | UInt(byte3 & 0x7f)

        switch status {
        case 0x0:
            return .registeredPerNoteController(channel, note, byte3, data)

        case 0x1:
            return .assignablePerNoteController(channel, note, byte3, data)

        case 0x2:
            return MIDIRegisteredParameter(uintValue: number).map { .registeredController(channel, $0, data) }

        case 0x3:
            return MIDINonRegisteredParameter(uintValue: number).map { .assignableController(channel, $0, data) }

        case 0x4:
            return MIDIRegisteredParameter(uintValue: number).map {
                .relativeRegisteredController(channel, $0, Int32(bitPattern: data))
            }

        case 0x5:
            return MIDINonRegisteredParameter(uintValue: number).map {
                .relativeAssignableController(channel, $0, Int32(bitPattern: data))
            }

        case 0x6:
            return .perNotePitchBendChange(channel, note, data)

        case 0x8,
             0x9:
            return _makeNoteMessage(status, channel, note, byte3, data)

        case 0xa:
            return .polyphonicPressure(channel, note, data)

        case 0xb:
            return MIDIController(uintValue: UInt(byte2 & 0x7f)).map { .controlChange(channel, $0, data) }

        case 0xc:
            return _makeProgramChange(channel, byte3, data)

        case 0xd:
            return .channelPressure(channel, data)

        case 0xe:
            return .pitchBendChange(channel, data)

        case 0xf:
            return .perNoteManagement(channel, note, detach: byte3 & 0x02 != 0, reset: byte3 & 0x01 != 0)

        default:
            return nil
        }
    }

    private static func _makeNoteMessage(_ status: UInt32,
                                         _ channel: MIDIChannel,
                                         _ note: MIDIData1Value,
                                         _ attributeType: UInt8,
                                         _ data: UInt32) -> Self? {
        let velocity = UInt16(data >> 16)
        let attribute: MIDI2NoteAttribute?

        // A receiver ignores the attribute data when there is no attribute.
        if attributeType == 0x00 {
            attribute = nil
        } else {
            guard let value = MIDI2NoteAttribute(type: attributeType,
                                                 data: UInt16(truncatingIfNeeded: data))
            else { return nil }

            attribute = value
        }

        return status == 0x9
            ? .noteOn(channel, note, velocity, attribute)
            : .noteOff(channel, note, velocity, attribute)
    }

    private static func _makeProgramChange(_ channel: MIDIChannel,
                                           _ optionFlags: UInt8,
                                           _ data: UInt32) -> Self? {
        guard let program = MIDIProgram(uintValue: UInt((data >> 24) & 0x7f) + 1)
        else { return nil }

        guard optionFlags & 0x01 != 0
        else { return .programChange(channel, program, nil) }

        let bank = MIDIData2Value(msb: MIDIData1Value(clamping: (data >> 8) & 0x7f),
                                  lsb: MIDIData1Value(clamping: data & 0x7f))

        return .programChange(channel, program, bank)
    }

    // MARK: Private Instance Methods

    // The status, byte 2, byte 3, and second word of this message.
    private func _fields() -> (UInt32, UInt32, UInt32)? {
        switch self {
        case let .assignableController(_, number, value):
            (0x3, Self._bankAndIndex(number.uintValue), value)

        case let .assignablePerNoteController(_, note, index, value):
            (0x1, (UInt32(note.uintValue) << 8) | UInt32(index), value)

        case let .channelPressure(_, pressure):
            (0xd, 0, pressure)

        case let .controlChange(_, controller, value):
            (0xb, UInt32(controller.uintValue) << 8, value)

        case let .noteOff(_, note, velocity, attribute):
            (0x8,
             (UInt32(note.uintValue) << 8) | UInt32(attribute?.type ?? 0),
             (UInt32(velocity) << 16) | UInt32(attribute?.data ?? 0))

        case let .noteOn(_, note, velocity, attribute):
            (0x9,
             (UInt32(note.uintValue) << 8) | UInt32(attribute?.type ?? 0),
             (UInt32(velocity) << 16) | UInt32(attribute?.data ?? 0))

        case let .perNoteManagement(_, note, detach, reset):
            (0xf, (UInt32(note.uintValue) << 8) | (detach ? 0x02 : 0) | (reset ? 0x01 : 0), 0)

        case let .perNotePitchBendChange(_, note, value):
            (0x6, UInt32(note.uintValue) << 8, value)

        case let .pitchBendChange(_, value):
            (0xe, 0, value)

        case let .polyphonicPressure(_, note, pressure):
            (0xa, UInt32(note.uintValue) << 8, pressure)

        case let .programChange(_, program, bank):
            (0xc,
             bank == nil ? 0 : 0x01,
             (UInt32(program.uintValue - 1) << 24)
                 | (UInt32(bank?.msb.uintValue ?? 0) << 8) | UInt32(bank?.lsb.uintValue ?? 0))

        case let .registeredController(_, number, value):
            (0x2, Self._bankAndIndex(number.uintValue), value)

        case let .registeredPerNoteController(_, note, index, value):
            (0x0, (UInt32(note.uintValue) << 8) | UInt32(index), value)

        case let .relativeAssignableController(_, number, delta):
            (0x5, Self._bankAndIndex(number.uintValue), UInt32(bitPattern: delta))

        case let .relativeRegisteredController(_, number, delta):
            (0x4, Self._bankAndIndex(number.uintValue), UInt32(bitPattern: delta))
        }
    }
}

// MARK: - Equatable

extension MIDI2ChannelMessage: Equatable {
}

// MARK: - Hashable

extension MIDI2ChannelMessage: Hashable {
}

// MARK: - MIDI2PacketsConvertible

extension MIDI2ChannelMessage: MIDI2PacketsConvertible {

    // MARK: Public Initializers

    /// Creates a `MIDI2ChannelMessage` instance from a single MIDI 2.0
    /// channel voice message packet (message type 0x4), or `nil` if the
    /// packets do not encode exactly one valid channel message.
    ///
    /// Reserved fields are ignored. A note message with a reserved attribute
    /// type is not valid.
    ///
    /// - Parameter packets:    The packets. Must hold exactly one packet.
    public init?(packets: [MIDI2Packet]) {
        guard packets.count == 1,
              packets[0].messageType == 0x4,
              let channel = MIDIChannel(uintValue: UInt((packets[0].word0 >> 16) & 0xf) + 1),
              let message = Self._makeMessage((packets[0].word0 >> 20) & 0xf,
                                              channel,
                                              UInt8((packets[0].word0 >> 8) & 0xff),
                                              UInt8(packets[0].word0 & 0xff),
                                              packets[0].word1)
        else { return nil }

        self = message
    }

    // MARK: Public Instance Methods

    /// Returns this message as a single MIDI 2.0 channel voice message packet
    /// (message type 0x4).
    ///
    /// - Parameter group:  The UMP group. Defaults to group 1.
    ///
    /// - Returns:  The single packet, or `nil` if the message cannot be
    ///             encoded.
    public func packets(group: MIDI2Group = 1) -> [MIDI2Packet]? {
        guard let groupByte = group.bytesValue?.first,
              let channelByte = channel.bytesValue?.first,
              let (status, bytes23, word1) = _fields()
        else { return nil }

        let word0 = (0x4 << 28) | (UInt32(groupByte) << 24) | (status << 20) | (UInt32(channelByte) << 16) | bytes23

        return MIDI2Packet(words: [word0, word1]).map { [$0] }
    }
}

// MARK: - Sendable

extension MIDI2ChannelMessage: Sendable {
}
