// © 2026 John Gary Pusey (see LICENSE.md)

extension MIDI2FlexDataMessage.ChordName {

    /// An alteration to a chord: what to do to which degree (1–15) of the
    /// chord, where 1 is the root, 3 the third, and so on.
    public enum Alteration {

        /// An alteration that adds the degree.
        case add(UInt8)

        /// An alteration that lowers the degree, adding it if needed.
        case lower(UInt8)

        /// An alteration that raises the degree, adding it if needed.
        case raise(UInt8)

        /// An alteration that removes the degree.
        case subtract(UInt8)

        // MARK: Internal Initializers

        // Creates an alteration from its 4-bit type and degree, or returns
        // `nil` if the type is reserved. Callers handle type 0 (no
        // alteration) themselves.
        internal init?(type: UInt8,
                       degree: UInt8) {
            switch type {
            case 1:
                self = .add(degree)

            case 2:
                self = .subtract(degree)

            case 3:
                self = .raise(degree)

            case 4:
                self = .lower(degree)

            default:
                return nil
            }
        }
    }
}

// MARK: -

extension MIDI2FlexDataMessage.ChordName.Alteration {

    // MARK: Internal Instance Properties

    // The alteration as a byte: its type, then its degree, or `nil` if
    // the degree does not fit in 4 bits.
    internal var byte: UInt8? {
        let (type, degree): (UInt8, UInt8) = switch self {
        case let .add(degree):
            (1, degree)

        case let .lower(degree):
            (4, degree)

        case let .raise(degree):
            (3, degree)

        case let .subtract(degree):
            (2, degree)
        }

        guard degree <= 0xf
        else { return nil }

        return (type << 4) | degree
    }
}

// MARK: - Equatable

extension MIDI2FlexDataMessage.ChordName.Alteration: Equatable {
}

// MARK: - Hashable

extension MIDI2FlexDataMessage.ChordName.Alteration: Hashable {
}

// MARK: - Sendable

extension MIDI2FlexDataMessage.ChordName.Alteration: Sendable {
}
