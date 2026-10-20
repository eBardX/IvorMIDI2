// © 2026 John Gary Pusey (see LICENSE.md)

import IvorMIDI
@testable import IvorMIDI2
import Testing
import XestiTools

struct MIDI2FlexDataMessageTests {
}

// MARK: -

extension MIDI2FlexDataMessageTests {
    @Test
    func address() {
        #expect(MIDI2FlexDataMessage.setTempo(1).address == .group)
        #expect(MIDI2FlexDataMessage.performanceText(.channel(3), .lyrics, "la").address == .channel(3))
    }

    @Test
    func init_packets_chordName() {
        // The examples of the UMP specification (Figure 76), addressed to the group.
        #expect(MIDI2FlexDataMessage(words: [0xd0100006, 0xf2070000, 0x00000000, 0x80000000])
                    == .setChordName(.group, .init(tonic: .init(.b, accidental: -1),
                                                   chordType: .minor)))
        #expect(MIDI2FlexDataMessage(words: [0xd0100006, 0x04010000, 0x00000000, 0x16000000])
                    == .setChordName(.group, .init(tonic: .init(.d),
                                                   chordType: .major,
                                                   bass: .init(.f, accidental: 1))))
        #expect(MIDI2FlexDataMessage(words: [0xd0100006, 0x03033b00, 0x00000000, 0x80000000])
                    == .setChordName(.group, .init(tonic: .init(.c),
                                                   chordType: .majorSeventh,
                                                   alterations: [.raise(11)])))
    }

    @Test
    func init_packets_events() {
        #expect(MIDI2FlexDataMessage(words: [0xd0100000, 0x02faf080, 0x00000000, 0x00000000]) == .setTempo(50_000_000))
        #expect(MIDI2FlexDataMessage(words: [0xd0100001, 0x04020800, 0x00000000, 0x00000000])
                    == .setTimeSignature(numerator: 4, denominator: 2, thirtySecondNotes: 8))
        #expect(MIDI2FlexDataMessage(words: [0xd0100002, 0x24020000, 0x03000000, 0x00000000])
                    == .setMetronome(.init(clocksPerPrimaryClick: 36, barAccent1: 2, subdivisionClicks1: 3)))
        #expect(MIDI2FlexDataMessage(words: [0xd0020005, 0x17000000, 0x00000000, 0x00000000])
                    == .setKeySignature(.channel(3), .init(sharpsOrFlats: 1, tonic: .g)))
        #expect(MIDI2FlexDataMessage(words: [0xd0100005, 0xc4000000, 0x00000000, 0x00000000])
                    == .setKeySignature(.group, .init(sharpsOrFlats: -4, tonic: .d)))
        #expect(MIDI2FlexDataMessage(words: [0xd0100005, 0x80000000, 0x00000000, 0x00000000])
                    == .setKeySignature(.group, .init(sharpsOrFlats: -8, tonic: nil)))
    }

    @Test
    func init_packets_invalid() {
        #expect(MIDI2FlexDataMessage(packets: []) == nil)
        #expect(MIDI2FlexDataMessage(words: [0xd0000000, 0x02faf080, 0, 0]) == nil)          // tempo addressed to a channel
        #expect(MIDI2FlexDataMessage(words: [0xd0200005, 0x17000000, 0, 0]) == nil)          // reserved address
        #expect(MIDI2FlexDataMessage(words: [0xd0100300, 0x00000000, 0, 0]) == nil)          // reserved status bank
        #expect(MIDI2FlexDataMessage(words: [0xd0100003, 0x00000000, 0, 0]) == nil)          // reserved status
        #expect(MIDI2FlexDataMessage(words: [0xd010010d, 0x41000000, 0, 0]) == nil)          // reserved metadata text status
        #expect(MIDI2FlexDataMessage(words: [0xd0100006, 0x031c0000, 0, 0x80000000]) == nil) // reserved chord type
        #expect(MIDI2FlexDataMessage(words: [0xd0100006, 0x03035b00, 0, 0x80000000]) == nil) // reserved alteration type
        #expect(MIDI2FlexDataMessage(words: [0xd0100006, 0x33010000, 0, 0x80000000]) == nil) // reserved tonic accidental
        #expect(MIDI2FlexDataMessage(words: [0xd0100005, 0x08000000, 0, 0]) == nil)          // reserved tonic note
        #expect(MIDI2FlexDataMessage(words: [0xd0100104, 0x41004200, 0, 0]) == nil)          // text after its end
        #expect(MIDI2FlexDataMessage(words: [0xd0100104, 0xff000000, 0, 0]) == nil)          // not UTF-8
        #expect(MIDI2FlexDataMessage(words: [0xd0500104, 0x41414141, 0, 0]) == nil)          // start, no end
        #expect(MIDI2FlexDataMessage(words: [0xd0500104,
                                             0x41414141,
                                             0x41414141,
                                             0x41414141,
                                             0xd0d00105,
                                             0x41000000,
                                             0,
                                             0]) == nil)          // mixed statuses
        #expect(MIDI2FlexDataMessage(words: [0xd0500104,
                                             0x41414141,
                                             0x41414141,
                                             0x41414141,
                                             0xd1d00104,
                                             0x41000000,
                                             0,
                                             0]) == nil)          // mixed groups
        #expect(MIDI2FlexDataMessage(words: [0xd0500000,
                                             0x02faf080,
                                             0,
                                             0,
                                             0xd0d00000,
                                             0x00000000,
                                             0,
                                             0]) == nil)          // tempo in two packets
        #expect(MIDI2FlexDataMessage(words: [0x50010000, 0, 0, 0]) == nil)                   // System Exclusive 8
    }

    @Test
    func init_packets_text() {
        // The first example of the UMP specification (Figure 78), addressed to the group.
        #expect(MIDI2FlexDataMessage(words: [0xd0100104, 0xc2a93230, 0x32322041, 0x4d454900])
                    == .metadataText(.group, .copyrightNotice, "©2022 AMEI"))
        #expect(MIDI2FlexDataMessage(words: [0xd0000201, 0x6c610000, 0x00000000, 0x00000000])
                    == .performanceText(.channel(1), .lyrics, "la"))
        #expect(MIDI2FlexDataMessage(words: [0xd0100101, 0x00000000, 0x00000000, 0x00000000])
                    == .metadataText(.group, .projectName, ""))
    }

    @Test
    func packets_events() {
        #expect(MIDI2FlexDataMessage.setTempo(50_000_000).words() == [0xd0100000, 0x02faf080, 0x00000000, 0x00000000])
        #expect(MIDI2FlexDataMessage.setTimeSignature(numerator: 4, denominator: 2, thirtySecondNotes: 8).words()
                    == [0xd0100001, 0x04020800, 0x00000000, 0x00000000])
        #expect(MIDI2FlexDataMessage.setMetronome(.init(clocksPerPrimaryClick: 24, barAccent1: 4)).words()
                    == [0xd0100002, 0x18040000, 0x00000000, 0x00000000])
        #expect(MIDI2FlexDataMessage.setMetronome(.init(clocksPerPrimaryClick: 24,
                                                        barAccent1: 3,
                                                        barAccent2: 2,
                                                        subdivisionClicks1: 2)).words()
                    == [0xd0100002, 0x18030200, 0x02000000, 0x00000000])
        #expect(MIDI2FlexDataMessage.setKeySignature(.channel(3), .init(sharpsOrFlats: 1, tonic: .g)).words()
                    == [0xd0020005, 0x17000000, 0x00000000, 0x00000000])
        #expect(MIDI2FlexDataMessage.setKeySignature(.group, .init(sharpsOrFlats: -8, tonic: nil)).words()
                    == [0xd0100005, 0x80000000, 0x00000000, 0x00000000])
        #expect(MIDI2FlexDataMessage.setChordName(.group, .init(tonic: .init(.d),
                                                                chordType: .major,
                                                                bass: .init(.f, accidental: 1))).words()
                    == [0xd0100006, 0x04010000, 0x00000000, 0x16000000])
        #expect(MIDI2FlexDataMessage.setChordName(.channel(16), .init(tonic: nil, chordType: .noChord)).words()
                    == [0xd00f0006, 0x00000000, 0x00000000, 0x80000000])
    }

    @Test
    func packets_group() {
        #expect(MIDI2FlexDataMessage.setTempo(1).words(group: 16) == [0xdf100000, 0x00000001, 0x00000000, 0x00000000])
    }

    @Test
    func packets_invalid() {
        let tonic = MIDI2FlexDataMessage.ChordName.Note(.c)

        #expect(MIDI2FlexDataMessage.setKeySignature(.group, .init(sharpsOrFlats: 8, tonic: .c)).packets() == nil)
        #expect(MIDI2FlexDataMessage.setChordName(.group, .init(tonic: tonic,
                                                                chordType: .major,
                                                                alterations: Array(repeating: .add(9),
                                                                                   count: 5))).packets() == nil)
        #expect(MIDI2FlexDataMessage.setChordName(.group, .init(tonic: tonic,
                                                                chordType: .major,
                                                                bassAlterations: Array(repeating: .add(9),
                                                                                       count: 3))).packets() == nil)
        #expect(MIDI2FlexDataMessage.setChordName(.group, .init(tonic: tonic,
                                                                chordType: .major,
                                                                alterations: [.add(16)])).packets() == nil)
        #expect(MIDI2FlexDataMessage.setChordName(.group, .init(tonic: .init(.c, accidental: 3),
                                                                chordType: .major)).packets() == nil)
        #expect(MIDI2FlexDataMessage.metadataText(.group, .composerName, "A\u{0}B").packets() == nil)
        #expect(MIDI2FlexDataMessage.metadataText(.group,
                                                  .composerName,
                                                  String(repeating: "A", count: 385)).packets() == nil)
    }

    @Test
    func packets_text() throws {
        // The second example of the UMP specification (Figure 78), addressed to the group.
        let message = MIDI2FlexDataMessage.metadataText(.group,
                                                        .copyrightNotice,
                                                        "Copyright 2022 MIDI Association Publishing")
        let packets = try #require(message.packets())

        #expect(packets.map(\.word0) == [0xd0500104, 0xd0900104, 0xd0900104, 0xd0d00104])
        #expect(packets[3].words == [0xd0d00104, 0x69736869, 0x6e670000, 0x00000000])     // "ishing"
        #expect(MIDI2FlexDataMessage.metadataText(.group,
                                                  .composerName,
                                                  String(repeating: "A", count: 384)).packets()?.count == 32)
    }

    @Test
    func roundTrip() throws {
        let messages: [MIDI2FlexDataMessage] = [.metadataText(.channel(2), .recordingDate, "2026-10-20T15:00"),
                                                .metadataText(.group, .accompanyingPerformerName, String(repeating: "é", count: 100)),
                                                .performanceText(.channel(16), .rubyLanguage, "ja"),
                                                .setChordName(.channel(1), .init(tonic: .init(.e, accidental: -2),
                                                                                 chordType: .seventhSuspendedFourth,
                                                                                 alterations: [.add(9), .subtract(5), .raise(11), .lower(13)],
                                                                                 bass: .init(.a, accidental: 2),
                                                                                 bassChordType: .power,
                                                                                 bassAlterations: [.add(2), .lower(15)])),
                                                .setKeySignature(.group, .init(sharpsOrFlats: 7, tonic: .c)),
                                                .setKeySignature(.channel(9), .init(sharpsOrFlats: -7, tonic: .a)),
                                                .setMetronome(.init(clocksPerPrimaryClick: 255,
                                                                    barAccent1: 1,
                                                                    barAccent2: 2,
                                                                    barAccent3: 3,
                                                                    subdivisionClicks1: 4,
                                                                    subdivisionClicks2: 5)),
                                                .setTempo(.max),
                                                .setTimeSignature(numerator: 255, denominator: 0, thirtySecondNotes: 8)]

        for message in messages {
            for group: MIDI2Group in [1, 16] {
                let packets = try #require(message.packets(group: group))

                #expect(MIDI2FlexDataMessage(packets: packets) == message)
                #expect(packets.allSatisfy { $0.group == group })
            }
        }
    }
}
