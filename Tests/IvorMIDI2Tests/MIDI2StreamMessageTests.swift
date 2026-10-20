// © 2026 John Gary Pusey (see LICENSE.md)

import IvorMIDI
@testable import IvorMIDI2
import Testing
import XestiTools

struct MIDI2StreamMessageTests {
    private let deviceIdentity = MIDI2StreamMessage.DeviceIdentity(manufacturerID: [0x00, 0x21, 0x09],
                                                                   family: 257,
                                                                   model: 515,
                                                                   softwareRevision: [1, 2, 3, 4])
    private let endpointInfo = MIDI2StreamMessage.EndpointInfo(functionBlockCount: 2,
                                                               hasStaticFunctionBlocks: true,
                                                               supportsMIDI1Protocol: true,
                                                               supportsMIDI2Protocol: true,
                                                               transmitsJRTimestamps: true)
    private let functionBlockInfo = MIDI2StreamMessage.FunctionBlockInfo(number: 1,
                                                                         direction: .bidirectional,
                                                                         uiHint: .senderAndReceiver,
                                                                         firstGroup: 1,
                                                                         groupCount: 4,
                                                                         midiCIVersion: 2,
                                                                         maxSysEx8Streams: 1)
}

// MARK: -

extension MIDI2StreamMessageTests {
    @Test
    func init_packets() {
        #expect(MIDI2StreamMessage(words: [0xf0000101, 0x00000005, 0, 0])
                    == .endpointDiscovery(umpVersionMajor: 1, umpVersionMinor: 1, filter: [.endpointInfo, .endpointName]))
        #expect(MIDI2StreamMessage(words: [0xf0010101, 0x82000301, 0, 0]) == .endpointInfoNotification(endpointInfo))
        #expect(MIDI2StreamMessage(words: [0xf0020000, 0x00002109, 0x01020304, 0x01020304]) == .deviceIdentityNotification(deviceIdentity))
        #expect(MIDI2StreamMessage(words: [0xf0034976, 0x6f720000, 0, 0]) == .endpointNameNotification("Ivor"))
        #expect(MIDI2StreamMessage(words: [0xf004534e, 0x2d303031, 0, 0]) == .productInstanceIDNotification("SN-001"))
        #expect(MIDI2StreamMessage(words: [0xf0050202, 0, 0, 0])
                    == .streamConfigurationRequest(.init(midiProtocol: .midi2, receivesJRTimestamps: true)))
        #expect(MIDI2StreamMessage(words: [0xf0060100, 0, 0, 0]) == .streamConfigurationNotification(.init(midiProtocol: .midi1)))
        #expect(MIDI2StreamMessage(words: [0xf010ff03, 0, 0, 0]) == .functionBlockDiscovery(nil, [.info, .name]))
        #expect(MIDI2StreamMessage(words: [0xf0100201, 0, 0, 0]) == .functionBlockDiscovery(2, .info))
        #expect(MIDI2StreamMessage(words: [0xf0118133, 0x00040201, 0, 0]) == .functionBlockInfoNotification(functionBlockInfo))
        #expect(MIDI2StreamMessage(words: [0xf0120153, 0x796e7468, 0, 0]) == .functionBlockNameNotification(1, "Synth"))
        #expect(MIDI2StreamMessage(words: [0xf0200000, 0, 0, 0]) == .startOfClip)
        #expect(MIDI2StreamMessage(words: [0xf0210000, 0, 0, 0]) == .endOfClip)
    }

    @Test
    func init_packets_ignoresReservedFields() {
        #expect(MIDI2StreamMessage(words: [0xf0000101, 0xffffffe1, 0, 0])
                    == .endpointDiscovery(umpVersionMajor: 1, umpVersionMinor: 1, filter: .endpointInfo))
        #expect(MIDI2StreamMessage(words: [0xf0020000, 0xff80a189, 0x81828384, 0x81828384])
                    == .deviceIdentityNotification(deviceIdentity))
        #expect(MIDI2StreamMessage(words: [0xf0200000, 0xffffffff, 0xffffffff, 0xffffffff]) == .startOfClip)
    }

    @Test
    func init_packets_invalid() {
        #expect(MIDI2StreamMessage(packets: []) == nil)
        #expect(MIDI2StreamMessage(words: [0xf0010101, 0x21000000, 0, 0]) == nil)          // 33 function blocks
        #expect(MIDI2StreamMessage(words: [0xf0050300, 0, 0, 0]) == nil)                   // reserved protocol
        #expect(MIDI2StreamMessage(words: [0xf0102001, 0, 0, 0]) == nil)                   // function block 32
        #expect(MIDI2StreamMessage(words: [0xf0118130, 0x00040201, 0, 0]) == nil)          // reserved direction
        #expect(MIDI2StreamMessage(words: [0xf011813f, 0x00040201, 0, 0]) == nil)          // reserved MIDI 1.0 port
        #expect(MIDI2StreamMessage(words: [0xf0118133, 0x10040201, 0, 0]) == nil)          // first group 17
        #expect(MIDI2StreamMessage(words: [0xf0118133, 0x00000201, 0, 0]) == nil)          // no groups
        #expect(MIDI2StreamMessage(words: [0xf0118133, 0x00110201, 0, 0]) == nil)          // 17 groups
        #expect(MIDI2StreamMessage(words: [0xf004c3a9, 0, 0, 0]) == nil)                   // product instance ID not ASCII
        #expect(MIDI2StreamMessage(words: [0xf0070000, 0, 0, 0]) == nil)                   // reserved status
        #expect(MIDI2StreamMessage(words: [0xf4200000,
                                           0,
                                           0,
                                           0,
                                           0xfc200000,
                                           0,
                                           0,
                                           0]) == nil)                   // start of clip in two packets
        #expect(MIDI2StreamMessage(words: [0xf4034142,
                                           0x43444546,
                                           0x4748494a,
                                           0x4b4c4d4e,
                                           0xfc124f50,
                                           0,
                                           0,
                                           0]) == nil)                   // mixed statuses
        #expect(MIDI2StreamMessage(words: [0xf4120141,
                                           0x42434445,
                                           0x46474849,
                                           0x4a4b4c4d,
                                           0xfc12024e,
                                           0,
                                           0,
                                           0]) == nil)                   // mixed function blocks
        #expect(MIDI2StreamMessage(words: [0xf4034142, 0x43444546, 0x4748494a, 0x4b4c4d4e]) == nil)  // start, no end
        #expect(MIDI2StreamMessage(words: [0x00000000]) == nil)                            // utility
    }

    @Test
    func init_packets_names() throws {
        let name = String(repeating: "N", count: 98)
        let packets = try #require(MIDI2StreamMessage.endpointNameNotification(name).packets())

        #expect(packets.count == 7)
        #expect(MIDI2StreamMessage(packets: packets) == .endpointNameNotification(name))
        #expect(MIDI2StreamMessage(packets: packets + [packets[6]]) == nil)   // 8 packets
    }

    @Test
    func packets() {
        #expect(MIDI2StreamMessage.endpointDiscovery(umpVersionMajor: 1, umpVersionMinor: 1, filter: [.endpointInfo, .endpointName]).words()
                    == [0xf0000101, 0x00000005, 0, 0])
        #expect(MIDI2StreamMessage.endpointInfoNotification(endpointInfo).words() == [0xf0010101, 0x82000301, 0, 0])
        #expect(MIDI2StreamMessage.deviceIdentityNotification(deviceIdentity).words() == [0xf0020000, 0x00002109, 0x01020304, 0x01020304])
        #expect(MIDI2StreamMessage.endpointNameNotification("Ivor").words() == [0xf0034976, 0x6f720000, 0, 0])
        #expect(MIDI2StreamMessage.productInstanceIDNotification("SN-001").words() == [0xf004534e, 0x2d303031, 0, 0])
        #expect(MIDI2StreamMessage.streamConfigurationRequest(.init(midiProtocol: .midi2, receivesJRTimestamps: true)).words()
                    == [0xf0050202, 0, 0, 0])
        #expect(MIDI2StreamMessage.streamConfigurationNotification(.init(midiProtocol: .midi1, transmitsJRTimestamps: true)).words()
                    == [0xf0060101, 0, 0, 0])
        #expect(MIDI2StreamMessage.functionBlockDiscovery(nil, [.info, .name]).words() == [0xf010ff03, 0, 0, 0])
        #expect(MIDI2StreamMessage.functionBlockDiscovery(31, .name).words() == [0xf0101f02, 0, 0, 0])
        #expect(MIDI2StreamMessage.functionBlockInfoNotification(functionBlockInfo).words() == [0xf0118133, 0x00040201, 0, 0])
        #expect(MIDI2StreamMessage.functionBlockNameNotification(1, "Synth").words() == [0xf0120153, 0x796e7468, 0, 0])
        #expect(MIDI2StreamMessage.startOfClip.words() == [0xf0200000, 0, 0, 0])
        #expect(MIDI2StreamMessage.endOfClip.words() == [0xf0210000, 0, 0, 0])
    }

    @Test
    func packets_groupless() throws {
        let packets = try #require(MIDI2StreamMessage.startOfClip.packets())

        #expect(packets[0].group == nil)
    }

    @Test
    func packets_invalid() {
        #expect(MIDI2StreamMessage.endpointNameNotification(String(repeating: "N", count: 99)).packets() == nil)
        #expect(MIDI2StreamMessage.endpointNameNotification("A\u{0}").packets() == nil)
        #expect(MIDI2StreamMessage.functionBlockNameNotification(1, String(repeating: "N", count: 92)).packets() == nil)
        #expect(MIDI2StreamMessage.functionBlockNameNotification(32, "Synth").packets() == nil)
        #expect(MIDI2StreamMessage.productInstanceIDNotification(String(repeating: "1", count: 43)).packets() == nil)
        #expect(MIDI2StreamMessage.productInstanceIDNotification("é").packets() == nil)
        #expect(MIDI2StreamMessage.functionBlockDiscovery(32, .info).packets() == nil)
        #expect(MIDI2StreamMessage.endpointInfoNotification(.init(functionBlockCount: 33,
                                                                  hasStaticFunctionBlocks: false,
                                                                  supportsMIDI1Protocol: true,
                                                                  supportsMIDI2Protocol: true)).packets() == nil)
        #expect(MIDI2StreamMessage.deviceIdentityNotification(.init(manufacturerID: [0x43],
                                                                    family: 0,
                                                                    model: 0,
                                                                    softwareRevision: [0, 0, 0, 0])).packets() == nil)
        #expect(MIDI2StreamMessage.deviceIdentityNotification(.init(manufacturerID: [0x43, 0x00, 0x80],
                                                                    family: 0,
                                                                    model: 0,
                                                                    softwareRevision: [0, 0, 0, 0])).packets() == nil)
        #expect(MIDI2StreamMessage.functionBlockInfoNotification(.init(number: 0,
                                                                       direction: .input,
                                                                       firstGroup: 1,
                                                                       groupCount: 0)).packets() == nil)
        #expect(MIDI2StreamMessage.functionBlockInfoNotification(.init(number: 32,
                                                                       direction: .input,
                                                                       firstGroup: 1,
                                                                       groupCount: 1)).packets() == nil)
    }

    @Test
    func packets_multiplePackets() {
        #expect(MIDI2StreamMessage.endpointNameNotification("ABCDEFGHIJKLMNOPQRST").words()
                    == [0xf4034142,
                        0x43444546,
                        0x4748494a,
                        0x4b4c4d4e,         // start, 14 bytes
                        0xfc034f50,
                        0x51525354,
                        0x00000000,
                        0x00000000])        // end, 6 bytes
        #expect(MIDI2StreamMessage.functionBlockNameNotification(2, "ABCDEFGHIJKLMN").words()
                    == [0xf4120241,
                        0x42434445,
                        0x46474849,
                        0x4a4b4c4d,         // start, 13 bytes
                        0xfc12024e,
                        0x00000000,
                        0x00000000,
                        0x00000000])        // end, 1 byte
    }

    @Test
    func roundTrip() throws {
        let messages: [MIDI2StreamMessage] = [.deviceIdentityNotification(.init(manufacturerID: [0x7f, 0x7f, 0x7f],
                                                                                family: 16_383,
                                                                                model: 0,
                                                                                softwareRevision: [0x7f, 0, 0x7f, 0])),
                                              .endOfClip,
                                              .endpointDiscovery(umpVersionMajor: 2, umpVersionMinor: 0, filter: [.deviceIdentity,
                                                                                                                  .productInstanceID,
                                                                                                                  .streamConfiguration]),
                                              .endpointInfoNotification(.init(functionBlockCount: 32,
                                                                              hasStaticFunctionBlocks: false,
                                                                              supportsMIDI1Protocol: false,
                                                                              supportsMIDI2Protocol: true,
                                                                              receivesJRTimestamps: true)),
                                              .endpointNameNotification(""),
                                              .endpointNameNotification(String(repeating: "é", count: 49)),
                                              .functionBlockDiscovery(0, []),
                                              .functionBlockInfoNotification(.init(number: 31,
                                                                                   isActive: false,
                                                                                   direction: .output,
                                                                                   uiHint: .sender,
                                                                                   midi1Port: .restricted,
                                                                                   firstGroup: 16,
                                                                                   groupCount: 1,
                                                                                   midiCIVersion: 0x7f,
                                                                                   maxSysEx8Streams: 255)),
                                              .functionBlockNameNotification(31, String(repeating: "B", count: 91)),
                                              .productInstanceIDNotification(String(repeating: "~", count: 42)),
                                              .startOfClip,
                                              .streamConfigurationNotification(.init(midiProtocol: .midi2,
                                                                                     receivesJRTimestamps: true,
                                                                                     transmitsJRTimestamps: true)),
                                              .streamConfigurationRequest(.init(midiProtocol: .midi1))]

        for message in messages {
            let packets = try #require(message.packets())

            #expect(MIDI2StreamMessage(packets: packets) == message)
        }
    }
}
