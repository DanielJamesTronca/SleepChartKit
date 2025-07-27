import SwiftUI

/// A SwiftUI view that displays sleep data as either a timeline or circular chart.
///
/// The chart can display sleep stages as horizontal bars (timeline style) or as 
/// color-coded segments around a circle (circular style). Both styles include 
/// customizable colors and optional legends.
///
/// ## Usage
/// ```swift
/// // Basic timeline usage
/// SleepChartView(samples: sleepSamples)
///
/// // Circular chart
/// SleepChartView(
///     samples: sleepSamples,
///     style: .circular,
///     circularConfig: CircularChartConfiguration(size: 200, lineWidth: 20)
/// )
///
/// // With custom providers
/// SleepChartView(
///     samples: sleepSamples,
///     colorProvider: customColorProvider,
///     displayNameProvider: localizedNameProvider
/// )
/// ```
public struct SleepChartView: View {
    
    // MARK: - Properties
    
    /// The sleep samples to display in the chart
    private let samples: [SleepSample]
    
    /// The weekly sleep data (for weekly charts only)
    private let weeklySamples: [DailySleepData]?
    
    /// The visual style of the chart
    private let style: SleepChartStyle
    
    /// Configuration for circular charts
    private let circularConfig: CircularChartConfiguration
    
    /// Configuration for weekly charts
    private let weeklyConfig: WeeklyChartConfiguration
    
    /// Provider for sleep stage colors
    private let colorProvider: SleepStageColorProvider
    
    /// Formatter for displaying durations in the legend
    private let durationFormatter: DurationFormatter
    
    /// Generator for time span markers on the axis
    private let timeSpanGenerator: TimeSpanGenerator
    
    /// Provider for sleep stage display names
    private let displayNameProvider: SleepStageDisplayNameProvider
    
    // MARK: - Initialization
    
    /// Creates a new sleep chart view with the specified configuration.
    ///
    /// - Parameters:
    ///   - samples: The sleep samples to display
    ///   - style: The visual style of the chart (default: .timeline)
    ///   - circularConfig: Configuration for circular charts (default: .default)
    ///   - colorProvider: Provider for sleep stage colors (default: DefaultSleepStageColorProvider)
    ///   - durationFormatter: Formatter for duration display (default: DefaultDurationFormatter)
    ///   - timeSpanGenerator: Generator for time axis markers (default: DefaultTimeSpanGenerator)
    ///   - displayNameProvider: Provider for stage names (default: DefaultSleepStageDisplayNameProvider)
    public init(
        samples: [SleepSample],
        style: SleepChartStyle = .timeline,
        circularConfig: CircularChartConfiguration = .default,
        colorProvider: SleepStageColorProvider = DefaultSleepStageColorProvider(),
        durationFormatter: DurationFormatter = DefaultDurationFormatter(),
        timeSpanGenerator: TimeSpanGenerator = DefaultTimeSpanGenerator(),
        displayNameProvider: SleepStageDisplayNameProvider = DefaultSleepStageDisplayNameProvider()
    ) {
        self.samples = samples
        self.weeklySamples = nil
        self.style = style
        self.circularConfig = circularConfig
        self.weeklyConfig = .default
        self.colorProvider = colorProvider
        self.durationFormatter = durationFormatter
        self.timeSpanGenerator = timeSpanGenerator
        self.displayNameProvider = displayNameProvider
    }
    
    /// Creates a new weekly sleep chart view with the specified configuration.
    ///
    /// - Parameters:
    ///   - weeklySamples: The weekly sleep data to display
    ///   - layout: The layout orientation for the weekly chart (default: .vertical)
    ///   - weeklyConfig: Configuration for weekly charts (default: .default)
    ///   - colorProvider: Provider for sleep stage colors (default: DefaultSleepStageColorProvider)
    ///   - durationFormatter: Formatter for duration display (default: DefaultDurationFormatter)
    ///   - displayNameProvider: Provider for stage names (default: DefaultSleepStageDisplayNameProvider)
    public init(
        weeklySamples: [DailySleepData],
        layout: WeeklyChartLayout = .vertical,
        weeklyConfig: WeeklyChartConfiguration = .default,
        colorProvider: SleepStageColorProvider = DefaultSleepStageColorProvider(),
        durationFormatter: DurationFormatter = DefaultDurationFormatter(),
        displayNameProvider: SleepStageDisplayNameProvider = DefaultSleepStageDisplayNameProvider()
    ) {
        self.samples = []
        self.weeklySamples = weeklySamples
        self.style = .weekly(layout)
        self.circularConfig = .default
        self.weeklyConfig = weeklyConfig
        self.colorProvider = colorProvider
        self.durationFormatter = durationFormatter
        self.timeSpanGenerator = DefaultTimeSpanGenerator()
        self.displayNameProvider = displayNameProvider
    }
    
    // MARK: - Computed Properties
    
    /// Aggregated sleep data by stage, calculating total duration for each stage
    private var sleepData: [SleepStage: TimeInterval] {
        var data: [SleepStage: TimeInterval] = [:]
        for sample in samples {
            data[sample.stage, default: 0] += sample.duration
        }
        return data
    }
    
    /// Active sleep stages sorted by their natural order
    private var activeStages: [SleepStage] {
        sleepData.keys.sorted { $0.sortOrder < $1.sortOrder }
    }
    
    /// Time span markers for the horizontal axis
    private var timeSpans: [TimeSpan] {
        timeSpanGenerator.generateTimeSpans(for: samples)
    }
    
    /// Formatted start time for the axis labels
    private var startTime: String? {
        samples.first?.startDate.formatted(date: .omitted, time: .shortened)
    }
    
    /// Formatted end time for the axis labels
    private var endTime: String? {
        samples.last?.endDate.formatted(date: .omitted, time: .shortened)
    }
    
    // MARK: - Body
    
    public var body: some View {
        switch style {
        case .timeline:
            timelineChartView
        case .circular:
            circularChartView
        case .weekly(let layout):
            weeklyChartView(layout: layout)
        }
    }
    
    // MARK: - Chart Views
    
    /// Timeline chart view (original implementation)
    private var timelineChartView: some View {
        VStack(spacing: SleepChartConstants.componentSpacing) {
            // Chart area with timeline graph and dotted lines overlay
            chartWithDottedLinesOverlay
            
            // Time axis showing start/end times and intermediate markers
            SleepTimeAxisView(
                startTime: startTime,
                endTime: endTime,
                timeSpans: timeSpans
            )
            .padding(.top, SleepChartConstants.axisNegativeTopPadding)

            // Legend showing sleep stages with colors and durations
            SleepLegendView(
                activeStages: activeStages,
                sleepData: sleepData,
                colorProvider: colorProvider,
                durationFormatter: durationFormatter,
                displayNameProvider: displayNameProvider
            )
            .padding(.top, SleepChartConstants.legendTopPadding)
        }
        .frame(height: SleepChartConstants.totalChartHeight)
    }
    
    /// Circular chart view with optional legend
    private var circularChartView: some View {
        VStack(spacing: 20) {
            SleepCircularChartView(
                samples: samples,
                colorProvider: colorProvider,
                lineWidth: circularConfig.lineWidth,
                size: circularConfig.size,
                showLabels: circularConfig.showLabels
            )
            
            // Optional legend for circular charts
            SleepLegendView(
                activeStages: activeStages,
                sleepData: sleepData,
                colorProvider: colorProvider,
                durationFormatter: durationFormatter,
                displayNameProvider: displayNameProvider
            )
        }
    }
    
    /// Weekly chart view with the specified layout
    private func weeklyChartView(layout: WeeklyChartLayout) -> some View {
        Group {
            if let weeklySamples = weeklySamples {
                SleepWeeklyChartView(
                    weeklySamples: weeklySamples,
                    layout: layout,
                    colorProvider: colorProvider,
                    durationFormatter: durationFormatter,
                    displayNameProvider: displayNameProvider,
                    weeklyConfig: weeklyConfig
                )
            } else {
                Text("Weekly data not available")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Private Views
    
    /// Chart area combining the sleep timeline graph with dotted vertical lines overlay
    private var chartWithDottedLinesOverlay: some View {
        ZStack(alignment: .bottom) {
            // Main sleep timeline graph showing sleep stages as horizontal bars
            SleepTimelineGraph(
                samples: samples,
                colorProvider: colorProvider
            )
            .frame(height: SleepChartConstants.chartHeight)
            .clipShape(RoundedRectangle(cornerRadius: SleepChartConstants.chartClipCornerRadius))

            // Dotted vertical lines connecting chart to time axis
            dottedLinesOverlay
        }
    }
    
    /// Dotted vertical lines overlay for time axis alignment
    private var dottedLinesOverlay: some View {
        GeometryReader { geometry in
            let axisHeight = geometry.size.height - SleepChartConstants.chartHeight
            let lineBottomY = geometry.size.height - (axisHeight / 2)
            let lineTopY = geometry.size.height - SleepChartConstants.chartHeight

            Path { path in
                // Start line
                path.move(to: CGPoint(x: 0, y: lineBottomY))
                path.addLine(to: CGPoint(x: 0, y: lineTopY))

                // End line
                path.move(to: CGPoint(x: geometry.size.width, y: lineBottomY))
                path.addLine(to: CGPoint(x: geometry.size.width, y: lineTopY))

                // Intermediate time span lines
                for span in timeSpans {
                    let xPos = geometry.size.width * span.position
                    path.move(to: CGPoint(x: xPos, y: lineBottomY))
                    path.addLine(to: CGPoint(x: xPos, y: lineTopY))
                }
            }
            .stroke(
                style: StrokeStyle(
                    lineWidth: SleepChartConstants.dottedLineWidth,
                    dash: SleepChartConstants.dottedLineDashPattern
                )
            )
            .foregroundColor(.secondary.opacity(SleepChartConstants.dottedLineOpacity))
        }
        .frame(height: SleepChartConstants.chartHeight + SleepChartConstants.dottedLinesHeightExtension)
        .padding(.bottom, SleepChartConstants.dottedLinesBottomPadding)
    }
}
