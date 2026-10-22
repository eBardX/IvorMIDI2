// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI2
import Testing

// The suite is named for its source file, MIDI2StreamMessage.FunctionBlockDiscoveryFilter.swift.
// swiftlint:disable:next type_name
struct MIDI2StreamMessageFunctionBlockDiscoveryFilterTests {
}

// MARK: -

extension MIDI2StreamMessageFunctionBlockDiscoveryFilterTests {
    @Test
    func hashable() {
        let set: Set<MIDI2StreamMessage.FunctionBlockDiscoveryFilter> = [.info, .info, .name]

        #expect(set.count == 2)
    }

    @Test
    func init_rawValue() {
        #expect(MIDI2StreamMessage.FunctionBlockDiscoveryFilter(rawValue: 0x03).rawValue == 0x03)
        #expect(MIDI2StreamMessage.FunctionBlockDiscoveryFilter(rawValue: 0x00).isEmpty)
    }

    @Test
    func init_rawValue_ignoresReservedBits() {
        #expect(MIDI2StreamMessage.FunctionBlockDiscoveryFilter(rawValue: 0xff).rawValue == 0x03)
    }

    @Test
    func options() {
        #expect(MIDI2StreamMessage.FunctionBlockDiscoveryFilter.info.rawValue == 0x01)
        #expect(MIDI2StreamMessage.FunctionBlockDiscoveryFilter.name.rawValue == 0x02)
    }

    @Test
    func union() {
        let filter: MIDI2StreamMessage.FunctionBlockDiscoveryFilter = [.info, .name]

        #expect(filter.contains(.info))
        #expect(filter.contains(.name))
        #expect(filter.rawValue == 0x03)
    }
}
