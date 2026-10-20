// © 2026 John Gary Pusey (see LICENSE.md)

// Helpers shared by the message families whose messages span one or more
// packets, each marked by a 2-bit or 4-bit format field: complete in one
// packet (0x0), start (0x1), continue (0x2), or end (0x3).
extension MIDI2Packet {

    // MARK: Internal Type Methods

    // Splits bytes into chunks of at most `size` bytes. No bytes make one
    // empty chunk, since every message needs at least one packet.
    internal static func chunks(of bytes: [UInt8],
                                size: Int) -> [[UInt8]] {
        guard !bytes.isEmpty
        else { return [[]] }

        return stride(from: 0,
                      to: bytes.count,
                      by: size).map {
            Array(bytes[$0..<min($0 + size, bytes.count)])
        }
    }

    // The format of packet `index` of `count`.
    internal static func format(ofPacketAt index: Int,
                                count: Int) -> UInt8 {
        if count == 1 {
            0x0
        } else if index == 0 {
            0x1
        } else if index == count - 1 {
            0x3
        } else {
            0x2
        }
    }

    // Returns whether the formats run complete, or start, continue…, end.
    internal static func isValidFormatSequence(_ formats: [UInt8]) -> Bool {
        guard !formats.isEmpty
        else { return false }

        return formats.enumerated().allSatisfy {
            $0.element == format(ofPacketAt: $0.offset,
                                 count: formats.count)
        }
    }

    // Returns text bytes ending at the first zero byte, which marks the end
    // of the text in the last packet, or `nil` if a zero byte comes before
    // a non-zero byte or the bytes are not valid UTF-8.
    internal static func text(from bytes: [UInt8]) -> String? {
        let textBytes = Array(bytes.prefix { $0 != 0 })

        guard bytes[textBytes.count...].allSatisfy({ $0 == 0 })
        else { return nil }

        return String(validating: textBytes,
                      as: UTF8.self)
    }

    // Returns the UTF-8 bytes of text, or `nil` if the text holds a null
    // character, which would read as its end.
    internal static func textBytes(of text: String) -> [UInt8]? {
        let bytes = Array(text.utf8)

        guard !bytes.contains(0)
        else { return nil }

        return bytes
    }

    // MARK: Internal Initializers

    // Creates a packet from its bytes, most significant first, or returns
    // `nil` if their number does not match the size of its message type.
    internal init?(bytes: [UInt8]) {
        guard bytes.count.isMultiple(of: 4)
        else { return nil }

        let words = stride(from: 0,
                           to: bytes.count,
                           by: 4).map {
            bytes[$0..<$0 + 4].reduce(UInt32(0)) { ($0 << 8) | UInt32($1) }
        }

        self.init(words: words)
    }

    // MARK: Internal Instance Properties

    // The packet’s bytes, most significant first.
    internal var bytes: [UInt8] {
        words.flatMap { word in
            [24, 16, 8, 0].map { UInt8(truncatingIfNeeded: word >> $0) }
        }
    }
}
