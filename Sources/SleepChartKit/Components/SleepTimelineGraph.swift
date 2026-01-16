import SwiftUI

/// A SwiftUI view that renders sleep data as a timeline graph with horizontal bars for each sleep stage.
///
/// This view displays sleep stages as colored horizontal bars positioned vertically by stage type,
/// with smooth connecting curves between stage transitions. Each bar's width represents the duration
/// of that sleep stage, and the vertical position indicates the stage type.
///
/// ## Features
/// - Horizontal bars for each sleep stage with configurable colors
/// - Smooth curved connectors between different sleep stages
/// - Automatic filtering of "inBed" stages when other sleep data exists
/// - Rounded corners on bars for a polished appearance
///
/// ## Usage
/// ```swift
/// SleepTimelineGraph(
///     samples: sleepSamples,
///     colorProvider: customColorProvider
/// )
/// ```
public struct SleepTimelineGraph: View {
    
    // MARK: - Properties
    
    /// The sleep samples to render in the timeline
    let samples: [SleepSample]
    
    /// Provider for sleep stage colors
    let colorProvider: SleepStageColorProvider

    // MARK: - Initialization
    
    /// Creates a new sleep timeline graph.
    ///
    /// - Parameters:
    ///   - samples: The sleep samples to display
    ///   - colorProvider: Provider for sleep stage colors (default: DefaultSleepStageColorProvider)
    public init(
        samples: [SleepSample],
        colorProvider: SleepStageColorProvider = DefaultSleepStageColorProvider()
    ) {
        self.samples = samples
        self.colorProvider = colorProvider
    }

    // MARK: - Layout Calculations
    
    /// Calculates the vertical offset for a sleep stage bar within the timeline.
    ///
    /// Sleep stages are arranged vertically with awake at the top and deeper sleep stages below.
    /// Spacing is calculated to evenly distribute the stages within the available height.
    ///
    /// - Parameters:
    ///   - stage: The sleep stage to position
    ///   - totalHeight: Total available height for the timeline
    ///   - barHeight: Height of individual stage bars
    /// - Returns: The y-offset for the stage bar
    private func yOffsetForStage(_ stage: SleepStage, totalHeight: CGFloat, barHeight: CGFloat) -> CGFloat {
        let totalBarHeight = barHeight * SleepChartConstants.stageRowCount
        let totalSpacing = max(0, totalHeight - totalBarHeight)
        let spacing = totalSpacing / (SleepChartConstants.stageRowCount - 1)

        switch stage {
        case .awake:
            return 0
        case .asleepREM:
            return barHeight + spacing
        case .asleepCore:
            return (barHeight + spacing) * 2
        case .asleepDeep:
            return (barHeight + spacing) * 3
        case .asleepUnspecified, .inBed:
            return (barHeight + spacing) * 4
        }
    }

    /// Calculates the height of individual sleep stage bars.
    ///
    /// - Parameter totalHeight: Total available height for the timeline
    /// - Returns: The height for each stage bar
    private func barHeight(totalHeight: CGFloat) -> CGFloat {
        return totalHeight / SleepChartConstants.stageRowCount
    }

    // MARK: - Body
    
    public var body: some View {
        Canvas { context, size in
            // Ensure we have valid sample data
            guard let firstSample = samples.first, 
                  let lastSample = samples.last else { return }

            // Calculate total time span for the sleep session
            let totalDuration = lastSample.endDate.timeIntervalSince(firstSample.startDate)
            guard totalDuration > 0 else { return }

            // Set up drawing dimensions
            let totalWidth = size.width
            let totalHeight = size.height
            let stageBarHeight = barHeight(totalHeight: totalHeight)

            // Track previous sample for drawing connectors
            var previousRect: CGRect?
            var previousStage: SleepStage?

            // Render each sleep sample as a bar with potential connectors
            for sample in samples {
                let currentStage = sample.stage

                // Skip "inBed" stages if other sleep stages exist (more specific data available)
                if currentStage == .inBed && samples.contains(where: { $0.stage != .inBed }) {
                     continue
                }

                // Calculate bar positioning and dimensions
                let sampleDuration = sample.duration
                let startTimeOffset = sample.startDate.timeIntervalSince(firstSample.startDate)

                let rectX = (startTimeOffset / totalDuration) * totalWidth
                let rectWidth = (sampleDuration / totalDuration) * totalWidth
                let rectY = yOffsetForStage(currentStage, totalHeight: totalHeight, barHeight: stageBarHeight)

                // Ensure minimum width for visibility
                let finalWidth = max(SleepChartConstants.minimumBarWidth, rectWidth)

                // Create and render the sleep stage bar
                let currentRect = CGRect(x: rectX, y: rectY, width: finalWidth, height: stageBarHeight)
                let cornerRadius = stageBarHeight / SleepChartConstants.barCornerRadiusRatio
                let path = Path(roundedRect: currentRect, cornerRadius: cornerRadius)
                context.fill(path, with: .color(colorProvider.color(for: currentStage)))

                // Draw connector curve between different sleep stages
                if let prevRect = previousRect, 
                   let prevStage = previousStage, 
                   currentStage != prevStage {
                    renderStageConnector(
                        context: context,
                        from: prevRect,
                        to: currentRect,
                        fromStage: previousStage,
                        toStage: currentStage
                    )
                }

                // Update tracking variables for next iteration
                previousRect = currentRect
                previousStage = currentStage
            }
        }
    }
    
    // MARK: - Private Rendering Methods
    
    /// Renders a smooth curve connecting two sleep stage bars.
    ///
    /// - Parameters:
    ///   - context: The graphics context for drawing
    ///   - from: The rectangle of the starting sleep stage bar
    ///   - to: The rectangle of the ending sleep stage bar
    private func renderStageConnector(
        context: GraphicsContext,
        from startRect: CGRect,
        to endRect: CGRect,
        fromStage: SleepStage?,
        toStage: SleepStage?
    ) {
        let startPoint = CGPoint(x: startRect.maxX - SleepChartConstants.connectorOffset, y: startRect.midY)
        let endPoint = CGPoint(x: endRect.minX + SleepChartConstants.connectorOffset, y: endRect.midY)
        
        // Calculate control points for smooth Bézier curve
        let controlPoint1 = CGPoint(
            x: startPoint.x + (endPoint.x - startPoint.x) * SleepChartConstants.connectorControlPointRatio1,
            y: startPoint.y
        )
        let controlPoint2 = CGPoint(
            x: startPoint.x + (endPoint.x - startPoint.x) * SleepChartConstants.connectorControlPointRatio2,
            y: endPoint.y
        )

        // Create and draw the connector curve
        var connectorPath = Path()
        connectorPath.move(to: startPoint)
        connectorPath.addCurve(to: endPoint, control1: controlPoint1, control2: controlPoint2)

        var gradient = Gradient(stops: [.init(color: .blue, location: 0), .init(color: .red, location: 1)])
        
        if let fromStage,
           let toStage {
            
            let start = colorProvider.color(for: fromStage).opacity(SleepChartConstants.connectorOpacity)
            let end = colorProvider.color(for: toStage).opacity(SleepChartConstants.connectorOpacity)
            
            gradient = Gradient(stops: [.init(color: start, location: 0), .init(color: end, location: 1)])
        }
        
        context.stroke(
            connectorPath,
            with: .linearGradient(gradient, startPoint: controlPoint1, endPoint: controlPoint2),
            lineWidth: SleepChartConstants.connectorLineWidth
        )
    }
}
