// © 2026 John Gary Pusey (see LICENSE.md)

/// A Universal MIDI Packet (UMP): one, two, three, or four 32-bit words.
///
/// The message type in the most significant 4 bits of the first word
/// determines the packet’s size, so a packet always holds exactly as many
/// words as its message type requires. Unused words are zero.
public struct MIDI2Packet {

    // MARK: Public Type Aliases

    /// A 32-bit word of a Universal MIDI Packet.
    public typealias Word = UInt32

    // MARK: Public Initializers

    /// Creates a `MIDI2Packet` instance from the provided words, or `nil` if
    /// their number does not match the size of the message type in the first
    /// word.
    ///
    /// - Parameter words:  The packet’s 32-bit words, in order.
    public init?(words: some Collection<Word>) {
        guard let first = words.first,
              words.count == Self.wordCount(forUniversalMIDIPacket: first)
        else { return nil }

        let padded = Array(words) + Array(repeating: 0,
                                          count: 4 - words.count)

        self.word0 = padded[0]
        self.word1 = padded[1]
        self.word2 = padded[2]
        self.word3 = padded[3]
    }

    // MARK: Public Instance Properties

    /// The packet’s first word.
    public let word0: Word

    /// The packet’s second word, or zero if the packet has one word.
    public let word1: Word

    /// The packet’s third word, or zero if the packet has fewer than three
    /// words.
    public let word2: Word

    /// The packet’s fourth word, or zero if the packet has fewer than four
    /// words.
    public let word3: Word
}

// MARK: -

extension MIDI2Packet {

    // MARK: Public Type Methods

    /// Returns the number of words in a Universal MIDI Packet, as its message
    /// type determines.
    ///
    /// Reserved message types have predefined sizes too, so a reader can skip
    /// packets it does not understand.
    ///
    /// - Parameter word:   The first 32-bit word of the packet.
    ///
    /// - Returns:  The number of words in the packet (1–4).
    public static func wordCount(forUniversalMIDIPacket word: Word) -> Int {
        switch word >> 28 {
        case 0x0,
             0x1,
             0x2,
             0x6,
             0x7:
            1

        case 0x3,
             0x4,
             0x8,
             0x9,
             0xa:
            2

        case 0xb,
             0xc:
            3

        default:    // 0x5, 0xD, 0xE, 0xF
            4
        }
    }

    // MARK: Public Instance Properties

    /// The packet’s group, or `nil` if its message type has no group
    /// (utility messages, type 0x0, and UMP stream messages, type 0xF).
    public var group: MIDI2Group? {
        MIDI2Group(packet: self)
    }

    /// The packet’s message type (0x0–0xF).
    public var messageType: UInt8 {
        UInt8(word0 >> 28)
    }

    /// The number of words in the packet (1–4).
    public var wordCount: Int {
        Self.wordCount(forUniversalMIDIPacket: word0)
    }

    /// The packet’s 32-bit words, in order.
    public var words: [Word] {
        Array([word0, word1, word2, word3].prefix(wordCount))
    }
}

// MARK: - Hashable

extension MIDI2Packet: Hashable {
}

// MARK: - Sendable

extension MIDI2Packet: Sendable {
}
