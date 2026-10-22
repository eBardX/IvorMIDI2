// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI2
import Testing

struct MIDI2GrouplessPacketsConvertibleTests {
    private let values: [any MIDI2GrouplessPacketsConvertible] = [MIDI2UtilityMessage.jrClock(1),
                                                                  MIDI2UtilityMessage.noop,
                                                                  MIDI2StreamMessage.startOfClip,
                                                                  MIDI2StreamMessage.endpointNameNotification(String(repeating: "N", count: 40))]
}

// MARK: -

extension MIDI2GrouplessPacketsConvertibleTests {
    @Test
    func init_packets() throws {
        for value in values {
            let packets = try #require(value.packets())
            let decoded = try #require(type(of: value).init(packets: packets))

            #expect(decoded.packets() == packets)
        }
    }

    @Test
    func init_packets_empty() {
        for value in values {
            #expect(type(of: value).init(packets: []) == nil)
        }
    }

    @Test
    func packets_groupless() throws {
        for value in values {
            let packets = try #require(value.packets())

            #expect(packets.allSatisfy { $0.group == nil })
        }
    }
}
