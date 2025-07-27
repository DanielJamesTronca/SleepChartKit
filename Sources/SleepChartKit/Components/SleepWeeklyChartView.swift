import SwiftUI

/// A SwiftUI view that displays sleep data for a week with health metrics integration.
///
/// The chart displays daily sleep patterns over a week period, showing sleep stages,
/// durations, and optional health metrics. Each day is represented as a separate
/// column or row with customizable styling.
///
/// ## Usage
/// ```swift
/// // Basic weekly usage
/// SleepWeeklyChartView(weeklySamples: weeklyData)
///
/// // With custom styling
/// SleepWeeklyChartView(
///     weeklySamples: weeklyData,
///     layout: .horizontal,
///     showHealthMetrics: true
/// )
/// ```
public struct SleepWeeklyChartView: View {
    
    // MARK: - Properties
    
    /// The weekly sleep data to display in the chart
    private let weeklySamples: [DailySleepData]
    
    /// The layout orientation of the weekly chart
    private let layout: WeeklyChartLayout
    
    /// Whether to show health metrics alongside sleep data
    private let showHealthMetrics: Bool
    
    /// Provider for sleep stage colors
    private let colorProvider: SleepStageColorProvider
    
    /// Formatter for displaying durations
    private let durationFormatter: DurationFormatter
    
    /// Provider for sleep stage display names
    private let displayNameProvider: SleepStageDisplayNameProvider
    
    /// Configuration for the weekly chart appearance
    private let weeklyConfig: WeeklyChartConfiguration
    
    // MARK: - Initialization
    
    /// Creates a new weekly sleep chart view with the specified configuration.
    ///
    /// - Parameters:
    ///   - weeklySamples: The weekly sleep data to display
    ///   - layout: Layout orientation (default: .vertical)
    ///   - showHealthMetrics: Whether to show health metrics (default: false)
    ///   - colorProvider: Provider for sleep stage colors (default: DefaultSleepStageColorProvider)
    ///   - durationFormatter: Formatter for duration display (default: DefaultDurationFormatter)
    ///   - displayNameProvider: Provider for stage names (default: DefaultSleepStageDisplayNameProvider)
    ///   - weeklyConfig: Configuration for weekly chart appearance (default: .default)
    public init(
        weeklySamples: [DailySleepData],
        layout: WeeklyChartLayout = .vertical,
        showHealthMetrics: Bool = false,
        colorProvider: SleepStageColorProvider = DefaultSleepStageColorProvider(),
        durationFormatter: DurationFormatter = DefaultDurationFormatter(),
        displayNameProvider: SleepStageDisplayNameProvider = DefaultSleepStageDisplayNameProvider(),
        weeklyConfig: WeeklyChartConfiguration = .default
    ) {
        self.weeklySamples = weeklySamples
        self.layout = layout
        self.showHealthMetrics = showHealthMetrics
        self.colorProvider = colorProvider
        self.durationFormatter = durationFormatter
        self.displayNameProvider = displayNameProvider
        self.weeklyConfig = weeklyConfig
    }
    
    // MARK: - Computed Properties
    
    /// All unique sleep stages present in the weekly data
    private var allStages: [SleepStage] {
        Set(weeklySamples.flatMap { $0.samples.map(\.stage) })
            .sorted { $0.sortOrder < $1.sortOrder }
    }
    
    /// Average sleep duration for the week
    private var averageSleepDuration: TimeInterval {
        let totalDuration = weeklySamples.reduce(0) { $0 + $1.totalSleepDuration }
        return weeklySamples.isEmpty ? 0 : totalDuration / Double(weeklySamples.count)
    }
    
    /// Formatted average sleep duration
    private var formattedAverageDuration: String {
        durationFormatter.format(averageSleepDuration)
    }
    
    // MARK: - Body
    
    public var body: some View {
        VStack(spacing: weeklyConfig.componentSpacing) {
            // Header with week summary
            weeklyHeaderView
            
            // Main chart content
            switch layout {
            case .vertical:
                verticalWeeklyChart
            case .horizontal:
                horizontalWeeklyChart
            }
            
            // Legend
            SleepLegendView(
                activeStages: allStages,
                sleepData: aggregatedSleepData,
                colorProvider: colorProvider,
                durationFormatter: durationFormatter,
                displayNameProvider: displayNameProvider
            )
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Header View
    
    /// Header section showing weekly summary
    private var weeklyHeaderView: some View {
        VStack(spacing: 8) {
            Text("Weekly Sleep Overview")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 16) {
                VStack {
                    Text("Avg Sleep")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formattedAverageDuration)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                if showHealthMetrics {
                    // Placeholder for health metrics
                    VStack {
                        Text("Sleep Score")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("--")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Chart Layouts
    
    /// Vertical layout with days arranged in columns
    private var verticalWeeklyChart: some View {
        HStack(spacing: weeklyConfig.daySpacing) {
            ForEach(Array(weeklySamples.enumerated()), id: \.offset) { index, dailyData in
                DailySleepColumnView(
                    dailyData: dailyData,
                    colorProvider: colorProvider,
                    durationFormatter: durationFormatter,
                    config: weeklyConfig
                )
            }
        }
        .padding(.horizontal)
    }
    
    /// Horizontal layout with days arranged in rows
    private var horizontalWeeklyChart: some View {
        VStack(spacing: weeklyConfig.daySpacing) {
            ForEach(Array(weeklySamples.enumerated()), id: \.offset) { index, dailyData in
                DailySleepRowView(
                    dailyData: dailyData,
                    colorProvider: colorProvider,
                    durationFormatter: durationFormatter,
                    config: weeklyConfig
                )
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Helper Properties
    
    /// Aggregated sleep data for legend display
    private var aggregatedSleepData: [SleepStage: TimeInterval] {
        var data: [SleepStage: TimeInterval] = [:]
        for dailyData in weeklySamples {
            for sample in dailyData.samples {
                data[sample.stage, default: 0] += sample.duration
            }
        }
        return data
    }
}

// MARK: - Supporting Views

/// View for displaying daily sleep data in a vertical column
private struct DailySleepColumnView: View {
    let dailyData: DailySleepData
    let colorProvider: SleepStageColorProvider
    let durationFormatter: DurationFormatter
    let config: WeeklyChartConfiguration
    
    var body: some View {
        VStack(spacing: 8) {
            // Sleep duration chart with rounded rectangles
            sleepDurationChart
            
            // Single letter day label at bottom
            Text(dailyData.dayOfWeekSingleLetter)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var sleepDurationChart: some View {
        VStack(spacing: config.segmentSpacing) {
            ForEach(Array(dailyData.samples.enumerated()), id: \.offset) { _, sample in
                RoundedRectangle(cornerRadius: config.segmentCornerRadius)
                    .fill(colorProvider.color(for: sample.stage))
                    .frame(
                        width: config.columnWidth,
                        height: max(4, CGFloat(sample.duration / 3600) * config.hourHeight)
                    )
            }
        }
        .frame(height: config.maxColumnHeight, alignment: .bottom)
    }
}

/// View for displaying daily sleep data in a horizontal row
private struct DailySleepRowView: View {
    let dailyData: DailySleepData
    let colorProvider: SleepStageColorProvider
    let durationFormatter: DurationFormatter
    let config: WeeklyChartConfiguration
    
    var body: some View {
        HStack(spacing: 8) {
            // Single letter day label
            Text(dailyData.dayOfWeekSingleLetter)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .frame(width: 20, alignment: .center)
            
            // Sleep timeline with rounded rectangles
            sleepTimelineBar
            
            // Duration
            Text(durationFormatter.format(dailyData.totalSleepDuration))
                .font(.caption)
                .fontWeight(.medium)
                .frame(width: 50, alignment: .trailing)
        }
    }
    
    private var sleepTimelineBar: some View {
        HStack(spacing: config.segmentSpacing) {
            ForEach(Array(dailyData.samples.enumerated()), id: \.offset) { _, sample in
                RoundedRectangle(cornerRadius: config.segmentCornerRadius)
                    .fill(colorProvider.color(for: sample.stage))
                    .frame(
                        width: max(4, CGFloat(sample.duration / 3600) * config.hourWidth),
                        height: config.rowHeight
                    )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview

#if DEBUG
struct SleepWeeklyChartView_Previews: PreviewProvider {
    static var previews: some View {
        let calendar = Calendar.current
        let today = Date()
        
        let sampleWeeklyData = (0..<7).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            let startDate = calendar.date(bySettingHour: 22, minute: 0, second: 0, of: date)!
            
            return DailySleepData(
                date: date,
                samples: [
                    SleepSample(stage: .inBed, startDate: startDate, endDate: calendar.date(byAdding: .minute, value: 15, to: startDate)!),
                    SleepSample(stage: .asleepCore, startDate: calendar.date(byAdding: .minute, value: 15, to: startDate)!, endDate: calendar.date(byAdding: .hour, value: 3, to: startDate)!),
                    SleepSample(stage: .asleepDeep, startDate: calendar.date(byAdding: .hour, value: 3, to: startDate)!, endDate: calendar.date(byAdding: .hour, value: 5, to: startDate)!),
                    SleepSample(stage: .asleepREM, startDate: calendar.date(byAdding: .hour, value: 5, to: startDate)!, endDate: calendar.date(byAdding: .hour, value: 7, to: startDate)!)
                ]
            )
        }.reversed().map { $0 }
        
        VStack(spacing: 40) {
            SleepWeeklyChartView(
                weeklySamples: sampleWeeklyData,
                layout: .vertical
            )
            
            SleepWeeklyChartView(
                weeklySamples: sampleWeeklyData,
                layout: .horizontal
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif
