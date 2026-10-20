// © 2026 John Gary Pusey (see LICENSE.md)

import IvorMIDI
@testable import IvorMIDI2
import Testing
import XestiTools

struct MIDI2StreamMessageDeviceIdentityTests {
}

// MARK: -

extension MIDI2StreamMessageDeviceIdentityTests {
    @Test
    func equality() {
        let identity1 = MIDI2StreamMessage.DeviceIdentity(manufacturerID: [0x43, 0, 0],
                                                          family: 1,
                                                          model: 2,
                                                          softwareRevision: [1, 0, 0, 0])
        let identity2 = MIDI2StreamMessage.DeviceIdentity(manufacturerID: [0x43, 0, 0],
                                                          family: 1,
                                                          model: 2,
                                                          softwareRevision: [1, 0, 0, 0])
        let identity3 = MIDI2StreamMessage.DeviceIdentity(manufacturerID: [0x43, 0, 0],
                                                          family: 1,
                                                          model: 3,
                                                          softwareRevision: [1, 0, 0, 0])

        #expect(identity1 == identity2)
        #expect(identity1 != identity3)
    }

    @Test
    func init_values() {
        let identity = MIDI2StreamMessage.DeviceIdentity(manufacturerID: [0x00, 0x21, 0x09],
                                                         family: 257,
                                                         model: 515,
                                                         softwareRevision: [1, 2, 3, 4])

        #expect(identity.manufacturerID == [0x00, 0x21, 0x09])
        #expect(identity.family == 257)
        #expect(identity.model == 515)
        #expect(identity.softwareRevision == [1, 2, 3, 4])
    }
}
