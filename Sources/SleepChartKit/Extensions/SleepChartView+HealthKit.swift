#if canImport(HealthKit)
import SwiftUI
import HealthKit

@available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
public extension SleepChartView {
    /// Creates a new sleep chart view using HealthKit samples.
    ///
    /// - Parameters:
    ///   - healthKitSamples: Array of HKCategorySample objects from HealthKit
    ///   - style: The visual style of the chart (timeline, circular, or minimal; default: .timeline)
    ///   - circularConfig: Configuration for circular charts (default: .default)
    ///   - colorProvider: Provider for sleep stage colors (default: DefaultSleepStageColorProvider)
    ///   - durationFormatter: Formatter for duration display (default: DefaultDurationFormatter)
    ///   - timeSpanGenerator: Generator for time axis markers (default: DefaultTimeSpanGenerator)
    ///   - displayNameProvider: Provider for stage names (default: DefaultSleepStageDisplayNameProvider)
    init(
        healthKitSamples: [HKCategorySample],
        style: SleepChartStyle = .timeline,
        circularConfig: CircularChartConfiguration = .default,
        colorProvider: SleepStageColorProvider = DefaultSleepStageColorProvider(),
        durationFormatter: DurationFormatter = DefaultDurationFormatter(),
        timeSpanGenerator: TimeSpanGenerator = DefaultTimeSpanGenerator(),
        displayNameProvider: SleepStageDisplayNameProvider = DefaultSleepStageDisplayNameProvider()
    ) {
        let sleepSamples = SleepSample.samples(from: healthKitSamples)
        self.init(
            samples: sleepSamples,
            style: style,
            circularConfig: circularConfig,
            colorProvider: colorProvider,
            durationFormatter: durationFormatter,
            timeSpanGenerator: timeSpanGenerator,
            displayNameProvider: displayNameProvider
        )
    }
}
#endif
