// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI2
import Testing

struct MIDI2FlexDataMessageKeySignatureTests {
}

// MARK: -

extension MIDI2FlexDataMessageKeySignatureTests {
    @Test
    func equality() {
        #expect(MIDI2FlexDataMessage.KeySignature(sharpsOrFlats: 1, tonic: .g) == .init(sharpsOrFlats: 1, tonic: .g))
        #expect(MIDI2FlexDataMessage.KeySignature(sharpsOrFlats: 1, tonic: .g) != .init(sharpsOrFlats: 1, tonic: .e))
        #expect(MIDI2FlexDataMessage.KeySignature(sharpsOrFlats: 1, tonic: .g) != .init(sharpsOrFlats: -1, tonic: .g))
    }

    @Test
    func hashable() {
        let set: Set<MIDI2FlexDataMessage.KeySignature> = [.init(sharpsOrFlats: 0, tonic: .c),
                                                           .init(sharpsOrFlats: 0, tonic: .c),
                                                           .init(sharpsOrFlats: -8, tonic: nil)]

        #expect(set.count == 2)
    }

    @Test
    func init_unknown() {
        let keySignature = MIDI2FlexDataMessage.KeySignature(sharpsOrFlats: -8, tonic: nil)

        #expect(keySignature.sharpsOrFlats == -8)
        #expect(keySignature.tonic == nil)
    }

    @Test
    func init_values() {
        let keySignature = MIDI2FlexDataMessage.KeySignature(sharpsOrFlats: -3, tonic: .c)

        #expect(keySignature.sharpsOrFlats == -3)
        #expect(keySignature.tonic == .c)
    }
}
