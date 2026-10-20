// © 2026 John Gary Pusey (see LICENSE.md)

/// An attribute of a MIDI 2.0 note on or note off message: an attribute type
/// with 16 bits of attribute data.
public enum MIDI2NoteAttribute {

    /// Attribute data whose meaning the manufacturer determines (attribute
    /// type 0x01).
    case manufacturerSpecific(UInt16)

    /// The note’s pitch, as an unsigned Q7.9 fixed-point number of semitones
    /// (attribute type 0x03): the integer part is a MIDI note number in
    /// 12-tone equal temperament with A440 as note 69, and the fractional
    /// part is in units of 1/512 of a semitone.
    ///
    /// The note number of the message then serves only as a note index.
    case pitch(UInt16)

    /// Attribute data whose meaning the MIDI-CI profile in use determines
    /// (attribute type 0x02).
    case profileSpecific(UInt16)

    // MARK: Internal Initializers

    // Creates an attribute from its type and data, or returns `nil` if the
    // type is reserved. Callers handle type 0x00 (no attribute) themselves.
    internal init?(type: UInt8,
                   data: UInt16) {
        switch type {
        case 0x01:
            self = .manufacturerSpecific(data)

        case 0x02:
            self = .profileSpecific(data)

        case 0x03:
            self = .pitch(data)

        default:
            return nil
        }
    }
}

// MARK: -

extension MIDI2NoteAttribute {

    // MARK: Internal Instance Properties

    internal var data: UInt16 {
        switch self {
        case let .manufacturerSpecific(data),
             let .pitch(data),
             let .profileSpecific(data):
            data
        }
    }

    internal var type: UInt8 {
        switch self {
        case .manufacturerSpecific:
            0x01

        case .pitch:
            0x03

        case .profileSpecific:
            0x02
        }
    }
}

// MARK: - Equatable

extension MIDI2NoteAttribute: Equatable {
}

// MARK: - Hashable

extension MIDI2NoteAttribute: Hashable {
}

// MARK: - Sendable

extension MIDI2NoteAttribute: Sendable {
}
