// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI2
import Testing

struct MIDI2FlexDataMessageMetronomeTests {
}

// MARK: -

extension MIDI2FlexDataMessageMetronomeTests {
    @Test
    func equality() {
        #expect(MIDI2FlexDataMessage.Metronome(clocksPerPrimaryClick: 24) == .init(clocksPerPrimaryClick: 24))
        #expect(MIDI2FlexDataMessage.Metronome(clocksPerPrimaryClick: 24) != .init(clocksPerPrimaryClick: 36))
        #expect(MIDI2FlexDataMessage.Metronome(clocksPerPrimaryClick: 24)
                    != .init(clocksPerPrimaryClick: 24, subdivisionClicks2: 3))
    }

    @Test
    func hashable() {
        let set: Set<MIDI2FlexDataMessage.Metronome> = [.init(clocksPerPrimaryClick: 24, barAccent1: 4),
                                                        .init(clocksPerPrimaryClick: 24, barAccent1: 4),
                                                        .init(clocksPerPrimaryClick: 24, barAccent1: 3)]

        #expect(set.count == 2)
    }

    @Test
    func init_allProperties() {
        let metronome = MIDI2FlexDataMessage.Metronome(clocksPerPrimaryClick: 24,
                                                       barAccent1: 3,
                                                       barAccent2: 3,
                                                       barAccent3: 2,
                                                       subdivisionClicks1: 2,
                                                       subdivisionClicks2: 4)

        #expect(metronome.clocksPerPrimaryClick == 24)
        #expect(metronome.barAccent1 == 3)
        #expect(metronome.barAccent2 == 3)
        #expect(metronome.barAccent3 == 2)
        #expect(metronome.subdivisionClicks1 == 2)
        #expect(metronome.subdivisionClicks2 == 4)
    }

    @Test
    func init_defaults() {
        let metronome = MIDI2FlexDataMessage.Metronome(clocksPerPrimaryClick: 36)

        #expect(metronome.barAccent1 == 0)
        #expect(metronome.barAccent2 == 0)
        #expect(metronome.barAccent3 == 0)
        #expect(metronome.subdivisionClicks1 == 0)
        #expect(metronome.subdivisionClicks2 == 0)
    }
}
