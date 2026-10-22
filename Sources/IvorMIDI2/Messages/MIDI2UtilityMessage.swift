// © 2026 John Gary Pusey (see LICENSE.md)

/// A Universal MIDI Packet utility message (message type 0x0).
///
/// Utility messages are groupless single-word packets that carry no MIDI
/// data of their own: they mark time for the messages that follow them.
public enum MIDI2UtilityMessage {

    /// A delta clockstamp: the number of ticks (0–1,048,575) since the last
    /// event, in units set by the most recent
    /// ``deltaClockstampTicksPerQuarterNote(_:)`` message.
    ///
    /// Delta clockstamps time the events of a MIDI Clip File; most receivers
    /// ignore them on a UMP transport.
    case deltaClockstamp(UInt32)

    /// The number of delta clockstamp ticks per quarter note (1–65,535).
    case deltaClockstampTicksPerQuarterNote(UInt16)

    /// A jitter reduction clock: the sender’s current time, in ticks of
    /// 1/31,250 of a second (32 µs), wrapping about every 2.1 seconds.
    case jrClock(UInt16)

    /// A jitter reduction timestamp: the sender’s time for the messages that
    /// follow, in ticks of 1/31,250 of a second (32 µs).
    case jrTimestamp(UInt16)

    /// A message that does nothing.
    case noop
}

// MARK: - Equatable

extension MIDI2UtilityMessage: Equatable {
}

// MARK: - Hashable

extension MIDI2UtilityMessage: Hashable {
}

// MARK: - MIDI2GrouplessPacketsConvertible

extension MIDI2UtilityMessage: MIDI2GrouplessPacketsConvertible {

    // MARK: Public Initializers

    /// Creates a `MIDI2UtilityMessage` instance from a single utility message
    /// packet (message type 0x0), or `nil` if the packets do not encode
    /// exactly one valid utility message.
    ///
    /// - Parameter packets:    The packets. Must hold exactly one packet.
    public init?(packets: [MIDI2Packet]) {
        guard packets.count == 1,
              packets[0].messageType == 0x0
        else { return nil }

        let word = packets[0].word0
        let data = word & 0xfffff

        switch (word >> 20) & 0xf {
        case 0x0:
            self = .noop

        case 0x1:
            self = .jrClock(UInt16(truncatingIfNeeded: data))

        case 0x2:
            self = .jrTimestamp(UInt16(truncatingIfNeeded: data))

        case 0x3:
            guard data & 0xffff != 0
            else { return nil }

            self = .deltaClockstampTicksPerQuarterNote(UInt16(truncatingIfNeeded: data))

        case 0x4:
            self = .deltaClockstamp(data)

        default:
            return nil
        }
    }

    // MARK: Public Instance Methods

    /// Returns this message as a single utility message packet (message type
    /// 0x0).
    ///
    /// - Returns:  The single packet, or `nil` if a value is out of range.
    public func packets() -> [MIDI2Packet]? {
        let word: MIDI2Packet.Word

        switch self {
        case let .deltaClockstamp(ticks):
            guard ticks <= 0xfffff
            else { return nil }

            word = (0x4 << 20) | ticks

        case let .deltaClockstampTicksPerQuarterNote(ticks):
            guard ticks > 0
            else { return nil }

            word = (0x3 << 20) | MIDI2Packet.Word(ticks)

        case let .jrClock(time):
            word = (0x1 << 20) | MIDI2Packet.Word(time)

        case let .jrTimestamp(time):
            word = (0x2 << 20) | MIDI2Packet.Word(time)

        case .noop:
            word = 0
        }

        return MIDI2Packet(words: [word]).map { [$0] }
    }
}

// MARK: - Sendable

extension MIDI2UtilityMessage: Sendable {
}
