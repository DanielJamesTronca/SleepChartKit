import SwiftUI

/// A SwiftUI view that displays sleep data as a circular chart with color-coded sleep stages.
///
/// The chart displays sleep stages as arc segments around a circle, with each segment's
/// size proportional to the time spent in that sleep stage. The chart includes customizable
/// colors and styling options.
///
/// ## Usage
/// ```swift
/// // Basic usage with sleep samples
/// SleepCircularChartView(samples: sleepSamples)
///
/// // With custom styling
/// SleepCircularChartView(
///     samples: sleepSamples,
///     colorProvider: customColorProvider,
///     lineWidth: 20,
///     size: 200
/// )
/// ```
public struct SleepCircularChartView: View {
    
    // MARK: - Properties
    
    /// The sleep samples to display in the chart
    private let samples: [SleepSample]
    
    /// Provider for sleep stage colors
    private let colorProvider: SleepStageColorProvider
    
    /// Width of the circular segments
    private let lineWidth: CGFloat
    
    /// Size of the circular chart
    private let size: CGFloat
    
    /// Background color of the chart
    private let backgroundColor: Color
    
    /// Whether to show labels inside the circle
    private let showLabels: Bool
    
    /// Whether to show sun/moon icons at start/end of sleep arc
    private let showIcons: Bool
    
    /// Sleep duration threshold in hours (default: 9 hours)
    private let thresholdHours: Double
    
    // MARK: - Initialization
    
    /// Creates a new circular sleep chart view with the specified configuration.
    ///
    /// - Parameters:
    ///   - samples: The sleep samples to display
    ///   - colorProvider: Provider for sleep stage colors (default: DefaultSleepStageColorProvider)
    ///   - lineWidth: Width of the circular segments (default: 16)
    ///   - size: Size of the circular chart (default: 160)
    ///   - backgroundColor: Background color of the chart (default: clear)
    ///   - showLabels: Whether to show time labels (default: true)
    ///   - showIcons: Whether to show sun/moon icons at start/end of sleep arc (default: true)
    ///   - thresholdHours: Sleep duration threshold in hours for percentage calculation (default: 9)
    public init(
        samples: [SleepSample],
        colorProvider: SleepStageColorProvider = DefaultSleepStageColorProvider(),
        lineWidth: CGFloat = 16,
        size: CGFloat = 160,
        backgroundColor: Color = .clear,
        showLabels: Bool = true,
        showIcons: Bool = true,
        thresholdHours: Double = 9.0
    ) {
        self.samples = samples
        self.colorProvider = colorProvider
        self.lineWidth = lineWidth
        self.size = size
        self.backgroundColor = backgroundColor
        self.showLabels = showLabels
        self.showIcons = showIcons
        self.thresholdHours = thresholdHours
    }
    
    // MARK: - Computed Properties
    
    /// Total duration of all sleep samples
    private var totalDuration: TimeInterval {
        samples.reduce(0) { $0 + $1.duration }
    }
    
    /// Sleep start and end times for the entire sleep session
    private var sleepPeriod: (start: Date, end: Date)? {
        guard let firstSample = samples.first, let lastSample = samples.last else { return nil }
        return (start: firstSample.startDate, end: lastSample.endDate)
    }
    
    /// Sleep segments with calculated angles based on percentage of threshold
    private var sleepSegments: [SleepSegment] {
        guard !samples.isEmpty else { return [] }
        
        let thresholdSeconds = thresholdHours * 3600
        let sleepPercentage = min(totalDuration / thresholdSeconds, 1.0)
        let totalArcDegrees = sleepPercentage * 360
        
        var segments: [SleepSegment] = []
        var currentAngle: Double = -90 // Start at top (12 o'clock)
        
        //making the chart look like the sleep starts at it would on a clock
        let sleepStart = samples.first!.startDate
        
        var h: Double = Double(Calendar.current.component(.hour, from: sleepStart))
        if h >= 12 { h -= 12 }
        
        let m: Double = Double(Calendar.current.component(.minute, from: sleepStart))
        
        var difference: Double = (360 / 12) * h
        difference += (360 / 12) * (m / 60)
        
        currentAngle += difference
        
        
        for sample in samples {
            let samplePercentage = sample.duration / totalDuration
            let sampleArcDegrees = samplePercentage * totalArcDegrees
            
            let startAngle = currentAngle
            let endAngle = currentAngle + sampleArcDegrees
            
            segments.append(SleepSegment(
                stage: sample.stage,
                startAngle: startAngle,
                endAngle: endAngle,
                duration: sample.duration,
                startDate: sample.startDate,
                endDate: sample.endDate
            ))
            
            currentAngle = endAngle
        }
        
        return segments
    }
    
    
    /// Start time for label display
    private var startTime: String? {
        samples.first?.startDate.formatted(date: .omitted, time: .shortened)
    }
    
    /// End time for label display
    private var endTime: String? {
        samples.last?.endDate.formatted(date: .omitted, time: .shortened)
    }
    
    /// Total sleep duration formatted
    private var totalSleepDuration: String {
        let hours = Int(totalDuration) / 3600
        let minutes = (Int(totalDuration) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
    
    // MARK: - Body
    
    public var body: some View {
        ZStack {
            backgroundColor
            
            // Circular chart segments using Canvas for better control
            Canvas { context, canvasSize in
                drawCircularChart(context: context, canvasSize: canvasSize)
            }
            
            // Sun and moon symbols
            if showIcons && !sleepSegments.isEmpty {
                sleepStartEndSymbols()
            }
            
            // Center content
            if showLabels {
                VStack(spacing: 4) {
                    Text(totalSleepDuration)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    if let startTime = startTime, let endTime = endTime {
                        Text("\(startTime) - \(endTime)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .frame(width: size + 32, height: size + 32)
    }
    
    // MARK: - Symbol Views
    
    /// Sun and moon symbols positioned at the start and end of the sleep arc
    @ViewBuilder
    private func sleepStartEndSymbols() -> some View {
        if let firstSegment = sleepSegments.first,
           let lastSegment = sleepSegments.last {
            
            // Position symbols very close to the start and end points (minimal padding)
            let paddingDegrees: Double = 2
            let firstSymbolAngle = firstSegment.startAngle + paddingDegrees
            let lastSymbolAngle = lastSegment.endAngle - paddingDegrees
            
            // Position symbols on the inner ring segments
            let outerRadius = size / 2
            let outerRingRadius = outerRadius - (lineWidth * 0.6)
            let innerRingRadius = outerRingRadius
            let symbolOffset = innerRingRadius
            
            // Moon symbol at start of sleep arc
            Image(systemName: "moon.fill")
                .foregroundColor(.white)
                .font(.caption2)
                .offset(
                    x: symbolOffset * cos(firstSymbolAngle * .pi / 180),
                    y: symbolOffset * sin(firstSymbolAngle * .pi / 180)
                )
            
            // Sun symbol at end of sleep arc
            Image(systemName: "sun.max.fill")
                .foregroundColor(.white)
                .font(.caption2)
                .offset(
                    x: symbolOffset * cos(lastSymbolAngle * .pi / 180),
                    y: symbolOffset * sin(lastSymbolAngle * .pi / 180)
                )
        }
    }
    
    // MARK: - Drawing Methods
    
    /// Draws the circular chart using Canvas for precise control
    private func drawCircularChart(context: GraphicsContext, canvasSize: CGSize) {
        let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
        // Calculate radii for concentric rings design
        let outerRadius = size / 2
        let outerRingRadius = outerRadius - (lineWidth * 0.6) // Outer background ring position
        let outerRingStrokeWidth = lineWidth * 1.5 // Outer ring stroke width
        let innerRingRadius = outerRingRadius // Inner ring centered on outer ring stroke
        
        // Draw outer background ring (complete circle) FIRST
        let outerRingPath = Path { path in
            path.addArc(
                center: center,
                radius: outerRingRadius,
                startAngle: Angle.degrees(0),
                endAngle: Angle.degrees(360),
                clockwise: false
            )
        }
        
        context.stroke(
            outerRingPath,
            with: .color(Color.gray.opacity(0.2)),
            style: StrokeStyle(
                lineWidth: outerRingStrokeWidth,
                lineCap: .round,
                lineJoin: .round
            )
        )
        
        
        // Draw sleep stage segments on inner ring
        for segment in sleepSegments {
            let startAngle = Angle.degrees(segment.startAngle)
            let endAngle = Angle.degrees(segment.endAngle)
            let segmentColor = colorProvider.color(for: segment.stage)
            
            // Create path for the arc segment on inner ring
            var path = Path()
            path.addArc(
                center: center,
                radius: innerRingRadius,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: false
            )
            
            // Stroke segments on inner ring with straight caps
            context.stroke(
                path,
                with: .color(segmentColor),
                style: StrokeStyle(
                    lineWidth: lineWidth,
                    lineCap: .butt,
                    lineJoin: .miter
                )
            )
        }
        
        // Add custom rounded caps for inner ring segments
        if let firstSegment = sleepSegments.first,
           let lastSegment = sleepSegments.last {
            
            let firstStartAngle = Angle.degrees(firstSegment.startAngle)
            let lastEndAngle = Angle.degrees(lastSegment.endAngle)
            
            // Calculate positions for the inner ring caps
            let firstStartX = center.x + innerRingRadius * cos(CGFloat(firstStartAngle.radians))
            let firstStartY = center.y + innerRingRadius * sin(CGFloat(firstStartAngle.radians))
            let lastEndX = center.x + innerRingRadius * cos(CGFloat(lastEndAngle.radians))
            let lastEndY = center.y + innerRingRadius * sin(CGFloat(lastEndAngle.radians))
            
            // Draw semicircle cap at start of inner ring
            let startCapColor = colorProvider.color(for: firstSegment.stage)
            let startCapPath = Path { path in
                let innerCapRadius = innerRingRadius - lineWidth / 2
                
                let innerX = center.x + innerCapRadius * cos(CGFloat(firstStartAngle.radians))
                let innerY = center.y + innerCapRadius * sin(CGFloat(firstStartAngle.radians))
                
                // Draw semicircle cap for inner ring
                path.move(to: CGPoint(x: innerX, y: innerY))
                path.addArc(
                    center: CGPoint(x: firstStartX, y: firstStartY),
                    radius: lineWidth / 2,
                    startAngle: firstStartAngle + Angle.degrees(180),
                    endAngle: firstStartAngle,
                    clockwise: false
                )
                path.addLine(to: CGPoint(x: innerX, y: innerY))
            }
            context.fill(startCapPath, with: .color(startCapColor))
            
            // Draw semicircle cap at end of inner ring
            let endCapColor = colorProvider.color(for: lastSegment.stage)
            let endCapPath = Path { path in
                let innerCapRadius = innerRingRadius - lineWidth / 2
                
                let innerX = center.x + innerCapRadius * cos(CGFloat(lastEndAngle.radians))
                let innerY = center.y + innerCapRadius * sin(CGFloat(lastEndAngle.radians))
                
                // Draw semicircle cap for inner ring
                path.move(to: CGPoint(x: innerX, y: innerY))
                path.addArc(
                    center: CGPoint(x: lastEndX, y: lastEndY),
                    radius: lineWidth / 2,
                    startAngle: lastEndAngle,
                    endAngle: lastEndAngle + Angle.degrees(180),
                    clockwise: false
                )
                path.addLine(to: CGPoint(x: innerX, y: innerY))
            }
            context.fill(endCapPath, with: .color(endCapColor))
        }
    }
}

// MARK: - Supporting Types

/// Represents a segment of the circular sleep chart
private struct SleepSegment {
    let id = UUID()
    let stage: SleepStage
    let startAngle: Double
    let endAngle: Double
    let duration: TimeInterval
    let startDate: Date
    let endDate: Date
}


// MARK: - Preview

#if DEBUG
struct SleepCircularChartView_Previews: PreviewProvider {
    static var previews: some View {
        let calendar = Calendar.current
        let baseDate = calendar.startOfDay(for: Date())
        let startDate = calendar.date(byAdding: .hour, value: 22, to: baseDate)!
        
        let samples = [
            SleepSample(stage: .inBed, startDate: startDate, endDate: calendar.date(byAdding: .minute, value: 15, to: startDate)!),
            SleepSample(stage: .asleepCore, startDate: calendar.date(byAdding: .minute, value: 15, to: startDate)!, endDate: calendar.date(byAdding: .hour, value: 2, to: startDate)!),
            SleepSample(stage: .asleepDeep, startDate: calendar.date(byAdding: .hour, value: 2, to: startDate)!, endDate: calendar.date(byAdding: .hour, value: 4, to: startDate)!),
            SleepSample(stage: .asleepREM, startDate: calendar.date(byAdding: .hour, value: 4, to: startDate)!, endDate: calendar.date(byAdding: .hour, value: 6, to: startDate)!),
            SleepSample(stage: .awake, startDate: calendar.date(byAdding: .hour, value: 6, to: startDate)!, endDate: calendar.date(byAdding: .hour, value: 6, to: startDate)!.addingTimeInterval(600)),
            SleepSample(stage: .asleepCore, startDate: calendar.date(byAdding: .hour, value: 6, to: startDate)!.addingTimeInterval(600), endDate: calendar.date(byAdding: .hour, value: 8, to: startDate)!)
        ]
        
        VStack(spacing: 40) {
            SleepCircularChartView(samples: samples)
            
            SleepCircularChartView(
                samples: samples,
                lineWidth: 20,
                size: 200
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif
