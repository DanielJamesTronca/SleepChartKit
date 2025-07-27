import Foundation

/// Represents sleep data for a single day, containing all sleep samples for that 24-hour period.
///
/// This model aggregates sleep samples for a specific date and provides convenient
/// computed properties for weekly chart display and analysis.
public struct DailySleepData: Hashable, Identifiable {
    
    /// Unique identifier for the daily data
    public let id = UUID()
    
    /// The date this sleep data represents
    public let date: Date
    
    /// All sleep samples for this day
    public let samples: [SleepSample]
    
    /// Creates a new daily sleep data instance
    ///
    /// - Parameters:
    ///   - date: The date this data represents
    ///   - samples: Sleep samples for this day
    public init(date: Date, samples: [SleepSample]) {
        self.date = date
        self.samples = samples
    }
    
    // MARK: - Computed Properties
    
    /// Total sleep duration for this day
    public var totalSleepDuration: TimeInterval {
        samples.reduce(0) { $0 + $1.duration }
    }
    
    /// Day of week abbreviation (e.g., "Mon", "Tue")
    public var dayOfWeek: String {
        date.formatted(.dateTime.weekday(.abbreviated))
    }
    
    /// Single letter day of week, localized (e.g., "M", "T", "W")
    public var dayOfWeekSingleLetter: String {
        date.formatted(.dateTime.weekday(.oneDigit))
    }
    
    /// Date label for display (e.g., "12/25")
    public var dateLabel: String {
        date.formatted(.dateTime.month(.twoDigits).day(.twoDigits))
    }
    
    /// Full date label with year (e.g., "Dec 25, 2023")
    public var fullDateLabel: String {
        date.formatted(.dateTime.month().day().year())
    }
    
    /// Sleep start time for this day
    public var sleepStartTime: Date? {
        samples.first?.startDate
    }
    
    /// Sleep end time for this day
    public var sleepEndTime: Date? {
        samples.last?.endDate
    }
    
    /// Sleep efficiency (percentage of time asleep vs in bed)
    public var sleepEfficiency: Double {
        let timeInBed = totalTimeInBed
        guard timeInBed > 0 else { return 0 }
        
        let timeAsleep = samples
            .filter { $0.stage.isAsleep }
            .reduce(0) { $0 + $1.duration }
        
        return timeAsleep / timeInBed
    }
    
    /// Total time spent in bed (including awake time)
    public var totalTimeInBed: TimeInterval {
        guard let start = sleepStartTime, let end = sleepEndTime else { return 0 }
        return end.timeIntervalSince(start)
    }
    
    /// Sleep data aggregated by stage
    public var sleepDataByStage: [SleepStage: TimeInterval] {
        var data: [SleepStage: TimeInterval] = [:]
        for sample in samples {
            data[sample.stage, default: 0] += sample.duration
        }
        return data
    }
    
    /// Active sleep stages for this day, sorted by their natural order
    public var activeStages: [SleepStage] {
        sleepDataByStage.keys.sorted { $0.sortOrder < $1.sortOrder }
    }
    
    /// Whether this day has any sleep data
    public var hasSleepData: Bool {
        !samples.isEmpty
    }
    
    /// Sleep quality score (0-100) based on duration and efficiency
    public var sleepQualityScore: Int {
        let durationScore = min(totalSleepDuration / (8 * 3600), 1.0) * 50 // 50 points for 8+ hours
        let efficiencyScore = sleepEfficiency * 50 // 50 points for 100% efficiency
        return Int((durationScore + efficiencyScore).rounded())
    }
}
