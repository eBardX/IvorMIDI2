// © 2026 John Gary Pusey (see LICENSE.md)

import IvorMIDI
@testable import IvorMIDI2
import XestiTools

extension MIDI2GrouplessPacketsConvertible {

    // Creates an instance from contiguous words, or returns `nil` if the
    // words do not split into packets or do not encode a valid instance.
    init?(words: [MIDI2Packet.Word]) {
        guard let packets = MIDI2Packet.packets(fromWords: words)
        else { return nil }

        self.init(packets: packets)
    }

    // The words of this instance’s packets, in order.
    func words() -> [MIDI2Packet.Word]? {
        packets()?.flatMap(\.words)
    }
}

// MARK: -

extension MIDI2Message {

    // Creates a message from contiguous words, or returns `nil` if the words
    // do not split into packets or do not encode a valid message.
    init?(words: [MIDI2Packet.Word]) {
        guard let packets = MIDI2Packet.packets(fromWords: words)
        else { return nil }

        self.init(packets: packets)
    }
}

// MARK: -

extension MIDI2Packet {

    // Splits contiguous words into packets, or returns `nil` if the last
    // packet is incomplete.
    static func packets(fromWords words: [MIDI2Packet.Word]) -> [MIDI2Packet]? {
        var packets: [MIDI2Packet] = []
        var index = 0

        while index < words.count {
            let end = index + wordCount(forUniversalMIDIPacket: words[index])

            guard end <= words.count,
                  let packet = MIDI2Packet(words: words[index..<end])
            else { return nil }

            packets.append(packet)

            index = end
        }

        return packets
    }
}

// MARK: -

extension MIDI2PacketsConvertible {

    // Creates an instance from contiguous words, or returns `nil` if the
    // words do not split into packets or do not encode a valid instance.
    init?(words: [MIDI2Packet.Word]) {
        guard let packets = MIDI2Packet.packets(fromWords: words)
        else { return nil }

        self.init(packets: packets)
    }

    // The words of this instance’s packets in the provided group, in order.
    func words(group: MIDI2Group = 1) -> [MIDI2Packet.Word]? {
        packets(group: group)?.flatMap(\.words)
    }
}

// MARK: -

extension MIDIChannelMessage {

    // Creates a message from a single-word packet with `init?(packet:)`, or
    // returns `nil` if the word does not encode a valid channel message.
    init?(word: MIDI2Packet.Word) {
        guard let packet = MIDI2Packet(words: [word])
        else { return nil }

        self.init(packet: packet)
    }
}
