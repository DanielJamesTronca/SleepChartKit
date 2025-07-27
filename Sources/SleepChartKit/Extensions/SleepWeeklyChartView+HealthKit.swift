#if canImport(HealthKit)
import HealthKit
import SwiftUI

/// HealthKit integration extensions for SleepWeeklyChartView
@available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
public extension SleepWeeklyChartView {
    
    /// Creates a weekly sleep chart from HealthKit samples grouped by day
    ///
    /// - Parameters:
    ///   - healthKitSamples: Array of HKCategorySample from HealthKit sleep analysis
    ///   - layout: Layout orientation (default: .vertical)
    ///   - showHealthMetrics: Whether to show health metrics (default: false)
    ///   - colorProvider: Provider for sleep stage colors (default: AppleSleepColorProvider)
    ///   - durationFormatter: Formatter for duration display (default: DefaultDurationFormatter)
    ///   - displayNameProvider: Provider for stage names (default: DefaultSleepStageDisplayNameProvider)
    ///   - weeklyConfig: Configuration for weekly chart appearance (default: .default)
    init(
        healthKitSamples: [HKCategorySample],
        layout: WeeklyChartLayout = .vertical,
        showHealthMetrics: Bool = false,
        colorProvider: SleepStageColorProvider = AppleSleepColorProvider(),
        durationFormatter: DurationFormatter = DefaultDurationFormatter(),
        displayNameProvider: SleepStageDisplayNameProvider = DefaultSleepStageDisplayNameProvider(),
        weeklyConfig: WeeklyChartConfiguration = .default
    ) {
        let weeklySamples = Self.groupSamplesByDay(healthKitSamples)
        
        self.init(
            weeklySamples: weeklySamples,
            layout: layout,
            showHealthMetrics: showHealthMetrics,
            colorProvider: colorProvider,
            durationFormatter: durationFormatter,
            displayNameProvider: displayNameProvider,
            weeklyConfig: weeklyConfig
        )
    }
    
    /// Creates a weekly sleep chart from HealthKit samples for a specific date range
    ///
    /// - Parameters:
    ///   - healthKitSamples: Array of HKCategorySample from HealthKit sleep analysis
    ///   - startDate: Start date for the week period
    ///   - endDate: End date for the week period
    ///   - layout: Layout orientation (default: .vertical)
    ///   - showHealthMetrics: Whether to show health metrics (default: false)
    ///   - colorProvider: Provider for sleep stage colors (default: AppleSleepColorProvider)
    ///   - durationFormatter: Formatter for duration display (default: DefaultDurationFormatter)
    ///   - displayNameProvider: Provider for stage names (default: DefaultSleepStageDisplayNameProvider)
    ///   - weeklyConfig: Configuration for weekly chart appearance (default: .default)
    init(
        healthKitSamples: [HKCategorySample],
        startDate: Date,
        endDate: Date,
        layout: WeeklyChartLayout = .vertical,
        showHealthMetrics: Bool = false,
        colorProvider: SleepStageColorProvider = AppleSleepColorProvider(),
        durationFormatter: DurationFormatter = DefaultDurationFormatter(),
        displayNameProvider: SleepStageDisplayNameProvider = DefaultSleepStageDisplayNameProvider(),
        weeklyConfig: WeeklyChartConfiguration = .default
    ) {
        let filteredSamples = healthKitSamples.filter { sample in
            sample.startDate >= startDate && sample.endDate <= endDate
        }
        
        let weeklySamples = Self.groupSamplesByDay(filteredSamples, startDate: startDate, endDate: endDate)
        
        self.init(
            weeklySamples: weeklySamples,
            layout: layout,
            showHealthMetrics: showHealthMetrics,
            colorProvider: colorProvider,
            durationFormatter: durationFormatter,
            displayNameProvider: displayNameProvider,
            weeklyConfig: weeklyConfig
        )
    }
    
    // MARK: - Helper Methods
    
    /// Groups HealthKit sleep samples by day to create DailySleepData objects
    ///
    /// - Parameters:
    ///   - samples: Array of HKCategorySample from HealthKit
    ///   - startDate: Optional start date to ensure all days in range are included
    ///   - endDate: Optional end date to ensure all days in range are included
    /// - Returns: Array of DailySleepData grouped by day
    private static func groupSamplesByDay(
        _ samples: [HKCategorySample],
        startDate: Date? = nil,
        endDate: Date? = nil
    ) -> [DailySleepData] {
        
        let calendar = Calendar.current
        let sleepSamples = SleepSample.samples(from: samples)
        
        // Group samples by day
        let groupedSamples = Dictionary(grouping: sleepSamples) { sample in
            calendar.startOfDay(for: sample.startDate)
        }
        
        // Determine date range
        let dates: [Date]
        if let startDate = startDate, let endDate = endDate {
            // Use provided date range
            dates = calendar.generateDates(from: startDate, to: endDate)
        } else if !sleepSamples.isEmpty {
            // Use range from samples
            let minDate = sleepSamples.map(\.startDate).min()!
            let maxDate = sleepSamples.map(\.endDate).max()!
            let startOfMinDay = calendar.startOfDay(for: minDate)
            let startOfMaxDay = calendar.startOfDay(for: maxDate)
            dates = calendar.generateDates(from: startOfMinDay, to: startOfMaxDay)
        } else {
            // No samples, return empty array
            dates = []
        }
        
        // Create DailySleepData for each day
        return dates.map { date in
            let samplesForDay = groupedSamples[date] ?? []
            return DailySleepData(date: date, samples: samplesForDay)
        }
    }
}

// MARK: - Calendar Extension

private extension Calendar {
    /// Generates an array of dates between start and end date (inclusive)
    func generateDates(from startDate: Date, to endDate: Date) -> [Date] {
        var dates: [Date] = []
        var currentDate = startOfDay(for: startDate)
        let endOfDay = startOfDay(for: endDate)
        
        while currentDate <= endOfDay {
            dates.append(currentDate)
            currentDate = date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return dates
    }
}

#endif