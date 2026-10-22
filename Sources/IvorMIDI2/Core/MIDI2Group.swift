// © 2026 John Gary Pusey (see LICENSE.md)

public import IvorMIDI
public import XestiTools

/// A Universal MIDI Packet (UMP) group number (1–16).
///
/// Group numbers are 1-based, as the MIDI 2.0 specifications number them; a
/// Universal MIDI Packet encodes them as a zero-based 4-bit field (0–15).
public struct MIDI2Group {

    // MARK: Public Initializers

    /// Creates a `MIDI2Group` instance with the provided group number, clamped
    /// to the valid range.
    ///
    /// - Parameter value:  The group number. A value below 1 becomes 1; a
    ///                     value above 16 becomes 16.
    public init(clamping value: some BinaryInteger) {
        self.uintValue = UInt(Swift.min(Swift.max(Int(clamping: value), 1), 16))
    }

    /// Creates a `MIDI2Group` instance from the group field of a Universal
    /// MIDI Packet, or `nil` if the packet’s message type has no group
    /// (utility messages, type 0x0, and UMP stream messages, type 0xF).
    ///
    /// - Parameter packet: The packet.
    public init?(packet: MIDI2Packet) {
        switch packet.messageType {
        case 0x0,
             0xf:
            return nil

        default:
            self.uintValue = UInt((packet.word0 >> 24) & 0xf) + 1
        }
    }

    /// Creates a `MIDI2Group` instance with the provided group number, or
    /// `nil` if the value is not a valid group number.
    ///
    /// - Parameter uintValue:  The group number. Must be in the range 1–16.
    public init?(uintValue: UInt) {
        guard Self.isValid(uintValue)
        else { return nil }

        self.uintValue = uintValue
    }

    // MARK: Public Instance Properties

    /// The group number.
    public let uintValue: UInt
}

// MARK: -

extension MIDI2Group {

    // MARK: Public Type Methods

    /// Returns a Boolean value indicating whether the provided value is a
    /// valid UMP group number.
    ///
    /// - Parameter uintValue:  The value to validate.
    ///
    /// - Returns:  `true` if the value is in the range 1–16; otherwise,
    ///             `false`.
    public static func isValid(_ uintValue: UInt) -> Bool {
        (1...16).contains(uintValue)
    }
}

// MARK: - MIDIBytesConvertible

extension MIDI2Group: MIDIBytesConvertible {

    // MARK: Public Initializers

    /// Creates a `MIDI2Group` instance from its UMP encoding, or `nil` if the
    /// bytes do not encode a valid group number.
    ///
    /// - Parameter bytesValue: A single byte holding the zero-based group
    ///                         number (0–15).
    public init?(bytesValue: [UInt8]) {
        guard bytesValue.count == 1
        else { return nil }

        self.init(uintValue: UInt(bytesValue[0]) + 1)
    }

    // MARK: Public Instance Properties

    /// The UMP encoding of this group number: a single byte holding the
    /// zero-based group number (0–15).
    public var bytesValue: [UInt8]? {
        guard let byte0Value = UInt8(exactly: uintValue - 1)
        else { return nil }

        return [byte0Value]
    }
}

// MARK: - UIntRepresentable

extension MIDI2Group: UIntRepresentable {
}
