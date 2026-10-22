// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

internal import IvorMIDI

/// A Flex Data message (message type 0xD): a setup or performance event, or
/// text, addressed to a MIDI channel or to a whole group.
///
/// Flex Data messages travel in four-word packets. Setup and performance
/// events fit in a single packet; text spans up to 32 packets of 12 UTF-8
/// bytes each.
public enum MIDI2FlexDataMessage {

    /// A metadata text message (status bank 0x01), such as a song’s name or
    /// copyright notice.
    case metadataText(Address, MetadataTextKind, String)

    /// A performance text message (status bank 0x02), such as a syllable of
    /// a lyric.
    case performanceText(Address, PerformanceTextKind, String)

    /// A set chord name message.
    case setChordName(Address, ChordName)

    /// A set key signature message.
    case setKeySignature(Address, KeySignature)

    /// A set metronome message, addressed to the group.
    case setMetronome(Metronome)

    /// A set tempo message, addressed to the group: the number of 10 ns
    /// units per quarter note.
    case setTempo(UInt32)

    /// A set time signature message, addressed to the group: the number of
    /// beats in a bar, the beat’s note value as a negative power of 2 (2 for
    /// a quarter note, 3 for an eighth note, and so on, or 0 for a
    /// non-standard value), and the number of 1/32 notes in 24 MIDI clocks.
    case setTimeSignature(numerator: UInt8, denominator: UInt8, thirtySecondNotes: UInt8)
}

// MARK: -

extension MIDI2FlexDataMessage {

    // MARK: Public Instance Properties

    /// The destination of the message within its group.
    public var address: Address {
        switch self {
        case let .metadataText(address, _, _),
             let .performanceText(address, _, _),
             let .setChordName(address, _),
             let .setKeySignature(address, _):
            address

        case .setMetronome,
             .setTempo,
             .setTimeSignature:
            .group
        }
    }

    // MARK: Private Type Properties

    private static let bytesPerPacket = 12
    private static let maxPacketCount = 32

    // MARK: Private Type Methods

    private static func _makeAddress(_ byte: UInt8) -> Address? {
        switch (byte >> 4) & 0x3 {
        case 0:
            MIDIChannel(uintValue: UInt(byte & 0xf) + 1).map { .channel($0) }

        case 1:
            .group

        default:
            nil
        }
    }

    private static func _makeAlterations(_ bytes: ArraySlice<UInt8>) -> [ChordName.Alteration]? {
        var alterations: [ChordName.Alteration] = []

        for byte in bytes where byte >> 4 != 0 {
            guard let alteration = ChordName.Alteration(type: byte >> 4,
                                                        degree: byte & 0xf)
            else { return nil }

            alterations.append(alteration)
        }

        return alterations
    }

    private static func _makeChordName(_ payload: [UInt8]) -> ChordName? {
        guard let chordType = ChordName.ChordType(rawValue: payload[1]),
              let alterations = _makeAlterations(payload[2...5]),
              let bassChordType = ChordName.ChordType(rawValue: payload[9]),
              let bassAlterations = _makeAlterations(payload[10...11])
        else { return nil }

        let tonic: ChordName.Note?
        let bass: ChordName.Note?

        if payload[0] & 0xf == 0 {
            tonic = nil
        } else {
            guard let note = _makeNote(payload[0])
            else { return nil }

            tonic = note
        }

        // A bass note of 0 means the chord’s tonic, whatever its accidental.
        if payload[8] & 0xf == 0 {
            bass = nil
        } else {
            guard let note = _makeNote(payload[8])
            else { return nil }

            bass = note
        }

        return ChordName(tonic: tonic,
                         chordType: chordType,
                         alterations: alterations,
                         bass: bass,
                         bassChordType: bassChordType,
                         bassAlterations: bassAlterations)
    }

    // Makes a message from the single packet of a setup or performance
    // event (status bank 0x00).
    private static func _makeEvent(_ status: UInt8,
                                   _ address: Address,
                                   _ payload: [UInt8]) -> Self? {
        switch (status, address) {
        case (0x00, .group):
            .setTempo(payload[0...3].reduce(UInt32(0)) { ($0 << 8) | UInt32($1) })

        case (0x01, .group):
            .setTimeSignature(numerator: payload[0],
                              denominator: payload[1],
                              thirtySecondNotes: payload[2])

        case (0x02, .group):
            .setMetronome(Metronome(clocksPerPrimaryClick: payload[0],
                                    barAccent1: payload[1],
                                    barAccent2: payload[2],
                                    barAccent3: payload[3],
                                    subdivisionClicks1: payload[4],
                                    subdivisionClicks2: payload[5]))

        case (0x05, _):
            _makeKeySignature(payload).map { .setKeySignature(address, $0) }

        case (0x06, _):
            _makeChordName(payload).map { .setChordName(address, $0) }

        default:
            nil
        }
    }

    private static func _makeKeySignature(_ payload: [UInt8]) -> KeySignature? {
        let tonic: NoteLetter?

        if payload[0] & 0xf == 0 {
            tonic = nil
        } else {
            guard let letter = NoteLetter(rawValue: payload[0] & 0xf)
            else { return nil }

            tonic = letter
        }

        return KeySignature(sharpsOrFlats: _signedNibble(payload[0] >> 4),
                            tonic: tonic)
    }

    private static func _makeNote(_ byte: UInt8) -> ChordName.Note? {
        let accidental = _signedNibble(byte >> 4)

        guard let letter = NoteLetter(rawValue: byte & 0xf),
              (-2...2).contains(accidental)
        else { return nil }

        return ChordName.Note(letter,
                              accidental: accidental)
    }

    // The byte of a chord name note: its accidental, then its letter, or
    // `nil` if the accidental is out of range.
    private static func _noteByte(_ note: ChordName.Note?) -> UInt8? {
        guard let note
        else { return 0 }

        guard (-2...2).contains(note.accidental)
        else { return nil }

        return (UInt8(bitPattern: note.accidental) << 4) | note.letter.rawValue
    }

    private static func _signedNibble(_ nibble: UInt8) -> Int8 {
        Int8(bitPattern: nibble << 4) >> 4
    }

    // MARK: Private Instance Methods

    private func _chordNamePayload(_ chordName: ChordName) -> [UInt8]? {
        let alterations = chordName.alterations.compactMap(\.byte)
        let bassAlterations = chordName.bassAlterations.compactMap(\.byte)

        guard alterations.count == chordName.alterations.count,
              alterations.count <= 4,
              bassAlterations.count == chordName.bassAlterations.count,
              bassAlterations.count <= 2,
              let tonicByte = Self._noteByte(chordName.tonic),
              let bassByte = chordName.bass == nil ? 0x80 : Self._noteByte(chordName.bass)
        else { return nil }

        return [tonicByte, chordName.chordType.rawValue]
            + alterations + [UInt8](repeating: 0, count: 6 - alterations.count)
            + [bassByte, chordName.bassChordType.rawValue]
            + bassAlterations + [UInt8](repeating: 0, count: 2 - bassAlterations.count)
    }

    // The address of this message, and its status bank, status, and payload
    // bytes, or `nil` if it cannot be encoded.
    private func _fields() -> (Address, [UInt8])? {
        switch self {
        case let .metadataText(address, kind, text):
            MIDI2Packet.textBytes(of: text).map { (address, [0x01, kind.rawValue] + $0) }

        case let .performanceText(address, kind, text):
            MIDI2Packet.textBytes(of: text).map { (address, [0x02, kind.rawValue] + $0) }

        case let .setChordName(address, chordName):
            _chordNamePayload(chordName).map { (address, [0x00, 0x06] + $0) }

        case let .setKeySignature(address, keySignature):
            _keySignaturePayload(keySignature).map { (address, [0x00, 0x05] + $0) }

        case let .setMetronome(metronome):
            (.group, [0x00,
                      0x02,
                      metronome.clocksPerPrimaryClick,
                      metronome.barAccent1,
                      metronome.barAccent2,
                      metronome.barAccent3,
                      metronome.subdivisionClicks1,
                      metronome.subdivisionClicks2])

        case let .setTempo(tenNanoseconds):
            (.group, [0x00, 0x00] + [24, 16, 8, 0].map { UInt8(truncatingIfNeeded: tenNanoseconds >> $0) })

        case let .setTimeSignature(numerator, denominator, thirtySecondNotes):
            (.group, [0x00, 0x01, numerator, denominator, thirtySecondNotes])
        }
    }

    private func _keySignaturePayload(_ keySignature: KeySignature) -> [UInt8]? {
        guard (-8...7).contains(keySignature.sharpsOrFlats)
        else { return nil }

        return [(UInt8(bitPattern: keySignature.sharpsOrFlats) << 4) | (keySignature.tonic?.rawValue ?? 0)]
    }
}

// MARK: - Equatable

extension MIDI2FlexDataMessage: Equatable {
}

// MARK: - Hashable

extension MIDI2FlexDataMessage: Hashable {
}

// MARK: - MIDI2PacketsConvertible

extension MIDI2FlexDataMessage: MIDI2PacketsConvertible {

    // MARK: Public Initializers

    /// Creates a `MIDI2FlexDataMessage` instance from the Flex Data packets
    /// (message type 0xD) that encode it, or `nil` if the packets do not
    /// encode exactly one valid message.
    ///
    /// Every packet must have the same group, address, status bank, and
    /// status, and the packets must be contiguous. Set tempo, set time
    /// signature, and set metronome messages must be addressed to the group.
    ///
    /// - Parameter packets:    The packets, in order: a single packet for a
    ///                         setup or performance event, or up to 32 for
    ///                         text.
    public init?(packets: [MIDI2Packet]) {
        let headers = packets.map { Array($0.bytes.prefix(4)) }

        guard let first = headers.first,
              packets.count <= Self.maxPacketCount,
              packets.allSatisfy({ $0.messageType == 0xd && $0.group == packets[0].group }),
              headers.allSatisfy({ $0[1] & 0x3f == first[1] & 0x3f && $0[2...3] == first[2...3] }),
              MIDI2Packet.isValidFormatSequence(headers.map { $0[1] >> 6 }),
              let address = Self._makeAddress(first[1])
        else { return nil }

        let payload = packets.flatMap { $0.bytes.dropFirst(4) }
        let message: Self? = switch first[2] {
        case 0x00:
            packets.count == 1 ? Self._makeEvent(first[3], address, payload) : nil

        case 0x01:
            MetadataTextKind(rawValue: first[3]).flatMap { kind in
                MIDI2Packet.text(from: payload).map { .metadataText(address, kind, $0) }
            }

        case 0x02:
            PerformanceTextKind(rawValue: first[3]).flatMap { kind in
                MIDI2Packet.text(from: payload).map { .performanceText(address, kind, $0) }
            }

        default:
            nil
        }

        guard let message
        else { return nil }

        self = message
    }

    // MARK: Public Instance Methods

    /// Returns this message as one or more Flex Data packets (message type
    /// 0xD).
    ///
    /// - Parameter group:  The UMP group. Defaults to group 1.
    ///
    /// - Returns:  The packets, in order, or `nil` if the message cannot be
    ///             encoded: a value is out of range, or text holds a null
    ///             character or needs more than 32 packets.
    public func packets(group: MIDI2Group = 1) -> [MIDI2Packet]? {
        guard let groupByte = group.bytesValue?.first,
              let (address, fields) = _fields()
        else { return nil }

        let addressBits: UInt8

        switch address {
        case let .channel(channel):
            guard let channelByte = channel.bytesValue?.first
            else { return nil }

            addressBits = channelByte

        case .group:
            addressBits = 0x10
        }

        let chunks = MIDI2Packet.chunks(of: Array(fields.dropFirst(2)),
                                        size: Self.bytesPerPacket)

        guard chunks.count <= Self.maxPacketCount
        else { return nil }

        var packets: [MIDI2Packet] = []

        for (index, chunk) in chunks.enumerated() {
            let format = MIDI2Packet.format(ofPacketAt: index,
                                            count: chunks.count)
            let header = [0xd0 | groupByte, (format << 6) | addressBits, fields[0], fields[1]]
            let padding = [UInt8](repeating: 0,
                                  count: Self.bytesPerPacket - chunk.count)

            guard let packet = MIDI2Packet(bytes: header + chunk + padding)
            else { return nil }

            packets.append(packet)
        }

        return packets
    }
}

// MARK: - Sendable

extension MIDI2FlexDataMessage: Sendable {
}
