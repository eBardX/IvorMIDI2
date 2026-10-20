// © 2026 John Gary Pusey (see LICENSE.md)

extension MIDI2FlexDataMessage {

    /// The settings of a metronome.
    public struct Metronome {

        // MARK: Public Initializers

        /// Creates a `Metronome` instance.
        ///
        /// The bar accents divide the bar into one to three parts, each
        /// accented at its start, whose numbers of beats sum to the number of
        /// beats in the bar. An undivided bar has its number of beats as the
        /// first accent and 0 for the others.
        ///
        /// - Parameter clocksPerPrimaryClick:  The number of MIDI clocks per
        ///                                     primary click.
        /// - Parameter barAccent1:             The number of beats in the
        ///                                     first part of the bar.
        ///                                     Defaults to 0.
        /// - Parameter barAccent2:             The number of beats in the
        ///                                     second part of the bar.
        ///                                     Defaults to 0.
        /// - Parameter barAccent3:             The number of beats in the
        ///                                     third part of the bar.
        ///                                     Defaults to 0.
        /// - Parameter subdivisionClicks1:     The number of clicks of the
        ///                                     first subdivision within each
        ///                                     primary click, or 0 for none.
        ///                                     Defaults to 0.
        /// - Parameter subdivisionClicks2:     The number of clicks of the
        ///                                     second subdivision within each
        ///                                     primary click, or 0 for none.
        ///                                     Defaults to 0.
        public init(clocksPerPrimaryClick: UInt8,
                    barAccent1: UInt8 = 0,
                    barAccent2: UInt8 = 0,
                    barAccent3: UInt8 = 0,
                    subdivisionClicks1: UInt8 = 0,
                    subdivisionClicks2: UInt8 = 0) {
            self.barAccent1 = barAccent1
            self.barAccent2 = barAccent2
            self.barAccent3 = barAccent3
            self.clocksPerPrimaryClick = clocksPerPrimaryClick
            self.subdivisionClicks1 = subdivisionClicks1
            self.subdivisionClicks2 = subdivisionClicks2
        }

        // MARK: Public Instance Properties

        /// The number of beats in the first part of the bar, or the whole
        /// bar if it is not divided.
        public let barAccent1: UInt8

        /// The number of beats in the second part of the bar, or 0.
        public let barAccent2: UInt8

        /// The number of beats in the third part of the bar, or 0.
        public let barAccent3: UInt8

        /// The number of MIDI clocks per primary click.
        public let clocksPerPrimaryClick: UInt8

        /// The number of clicks of the first subdivision within each primary
        /// click, or 0 for none.
        public let subdivisionClicks1: UInt8

        /// The number of clicks of the second subdivision within each
        /// primary click, or 0 for none.
        public let subdivisionClicks2: UInt8
    }
}

// MARK: - Equatable

extension MIDI2FlexDataMessage.Metronome: Equatable {
}

// MARK: - Hashable

extension MIDI2FlexDataMessage.Metronome: Hashable {
}

// MARK: - Sendable

extension MIDI2FlexDataMessage.Metronome: Sendable {
}
