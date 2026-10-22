// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI2
import Testing

struct MIDI2NoteAttributeTests {
}

// MARK: -

extension MIDI2NoteAttributeTests {
    @Test
    func data() {
        #expect(MIDI2NoteAttribute.manufacturerSpecific(0x1234).data == 0x1234)
        #expect(MIDI2NoteAttribute.pitch(0x8a00).data == 0x8a00)
        #expect(MIDI2NoteAttribute.profileSpecific(0xffff).data == 0xffff)
    }

    @Test
    func equality() {
        #expect(MIDI2NoteAttribute.pitch(1) == .pitch(1))
        #expect(MIDI2NoteAttribute.pitch(1) != .pitch(2))
        #expect(MIDI2NoteAttribute.pitch(1) != .profileSpecific(1))
    }

    @Test
    func hashable() {
        let set: Set<MIDI2NoteAttribute> = [.manufacturerSpecific(1), .manufacturerSpecific(1), .pitch(1)]

        #expect(set.count == 2)
    }

    @Test
    func init_type() {
        #expect(MIDI2NoteAttribute(type: 0x01, data: 7) == .manufacturerSpecific(7))
        #expect(MIDI2NoteAttribute(type: 0x02, data: 7) == .profileSpecific(7))
        #expect(MIDI2NoteAttribute(type: 0x03, data: 7) == .pitch(7))
    }

    @Test
    func init_type_reserved() {
        #expect(MIDI2NoteAttribute(type: 0x00, data: 7) == nil)
        #expect(MIDI2NoteAttribute(type: 0x04, data: 7) == nil)
        #expect(MIDI2NoteAttribute(type: 0xff, data: 7) == nil)
    }

    @Test
    func type() {
        #expect(MIDI2NoteAttribute.manufacturerSpecific(0).type == 0x01)
        #expect(MIDI2NoteAttribute.profileSpecific(0).type == 0x02)
        #expect(MIDI2NoteAttribute.pitch(0).type == 0x03)
    }
}
