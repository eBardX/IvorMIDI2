// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI2
import Testing

struct MIDI2StreamMessageEndpointDiscoveryFilterTests {
}

// MARK: -

extension MIDI2StreamMessageEndpointDiscoveryFilterTests {
    @Test
    func hashable() {
        let set: Set<MIDI2StreamMessage.EndpointDiscoveryFilter> = [.deviceIdentity, .deviceIdentity, .endpointInfo]

        #expect(set.count == 2)
    }

    @Test
    func init_rawValue() {
        #expect(MIDI2StreamMessage.EndpointDiscoveryFilter(rawValue: 0x1f).rawValue == 0x1f)
        #expect(MIDI2StreamMessage.EndpointDiscoveryFilter(rawValue: 0x00).isEmpty)
    }

    @Test
    func init_rawValue_ignoresReservedBits() {
        #expect(MIDI2StreamMessage.EndpointDiscoveryFilter(rawValue: 0xff).rawValue == 0x1f)
    }

    @Test
    func options() {
        #expect(MIDI2StreamMessage.EndpointDiscoveryFilter.deviceIdentity.rawValue == 0x02)
        #expect(MIDI2StreamMessage.EndpointDiscoveryFilter.endpointInfo.rawValue == 0x01)
        #expect(MIDI2StreamMessage.EndpointDiscoveryFilter.endpointName.rawValue == 0x04)
        #expect(MIDI2StreamMessage.EndpointDiscoveryFilter.productInstanceID.rawValue == 0x08)
        #expect(MIDI2StreamMessage.EndpointDiscoveryFilter.streamConfiguration.rawValue == 0x10)
    }

    @Test
    func union() {
        let filter: MIDI2StreamMessage.EndpointDiscoveryFilter = [.deviceIdentity, .endpointInfo]

        #expect(filter.contains(.deviceIdentity))
        #expect(filter.contains(.endpointInfo))
        #expect(filter.rawValue == 0x03)
    }
}
