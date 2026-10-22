// © 2026 John Gary Pusey (see LICENSE.md)

public import IvorMIDI

extension MIDI2StreamMessage {

    /// The identity of a device, as a device identity notification or a
    /// MIDI 1.0 device inquiry reply declares it.
    public struct DeviceIdentity {

        // MARK: Public Initializers

        /// Creates a `DeviceIdentity` instance.
        ///
        /// - Parameter manufacturerID:     The manufacturer’s system exclusive
        ///                                 ID: three 7-bit bytes, with a
        ///                                 1-byte ID followed by two zero
        ///                                 bytes.
        /// - Parameter family:             The device family.
        /// - Parameter model:              The model within the family.
        /// - Parameter softwareRevision:   The software revision level: four
        ///                                 7-bit bytes.
        public init(manufacturerID: [UInt8],
                    family: MIDIData2Value,
                    model: MIDIData2Value,
                    softwareRevision: [UInt8]) {
            self.family = family
            self.manufacturerID = manufacturerID
            self.model = model
            self.softwareRevision = softwareRevision
        }

        // MARK: Public Instance Properties

        /// The device family.
        public let family: MIDIData2Value

        /// The manufacturer’s system exclusive ID: three 7-bit bytes.
        public let manufacturerID: [UInt8]

        /// The model within the family.
        public let model: MIDIData2Value

        /// The software revision level: four 7-bit bytes.
        public let softwareRevision: [UInt8]
    }
}

// MARK: - Equatable

extension MIDI2StreamMessage.DeviceIdentity: Equatable {
}

// MARK: - Hashable

extension MIDI2StreamMessage.DeviceIdentity: Hashable {
}

// MARK: - Sendable

extension MIDI2StreamMessage.DeviceIdentity: Sendable {
}
