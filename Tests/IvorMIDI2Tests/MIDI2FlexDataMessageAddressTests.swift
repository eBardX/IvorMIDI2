// © 2026 John Gary Pusey (see LICENSE.md)

import IvorMIDI
@testable import IvorMIDI2
import Testing
import XestiTools

struct MIDI2FlexDataMessageAddressTests {
}

// MARK: -

extension MIDI2FlexDataMessageAddressTests {
    @Test
    func equality() {
        #expect(MIDI2FlexDataMessage.Address.channel(1) == .channel(1))
        #expect(MIDI2FlexDataMessage.Address.channel(1) != .channel(2))
        #expect(MIDI2FlexDataMessage.Address.channel(1) != .group)
        #expect(MIDI2FlexDataMessage.Address.group == .group)
    }

    @Test
    func hashable() {
        let set: Set<MIDI2FlexDataMessage.Address> = [.channel(1), .channel(1), .channel(16), .group, .group]

        #expect(set.count == 3)
    }
}
