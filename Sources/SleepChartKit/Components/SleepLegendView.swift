import SwiftUI

public struct SleepLegendView: View {
    private let activeStages: [SleepStage]
    private let sleepData: [SleepStage: TimeInterval]
    private let colorProvider: SleepStageColorProvider
    private let durationFormatter: DurationFormatter
    private let displayNameProvider: SleepStageDisplayNameProvider
    private let hideDurations: Bool
    
    public init(
        activeStages: [SleepStage],
        sleepData: [SleepStage: TimeInterval],
        colorProvider: SleepStageColorProvider = DefaultSleepStageColorProvider(),
        durationFormatter: DurationFormatter = DefaultDurationFormatter(),
        displayNameProvider: SleepStageDisplayNameProvider = DefaultSleepStageDisplayNameProvider(),
        hideDurations: Bool = false
    ) {
        self.activeStages = activeStages
        self.sleepData = sleepData
        self.colorProvider = colorProvider
        self.durationFormatter = durationFormatter
        self.displayNameProvider = displayNameProvider
        self.hideDurations = hideDurations
    }
    
    // MARK: - Layout Configuration
    
    /// Grid configuration for legend items with adaptive sizing
    private var oneRow: [GridItem] {
        [
            GridItem(.adaptive(minimum: SleepChartConstants.legendItemMinWidth,
                               maximum: SleepChartConstants.legendItemMaxWidth)
            )
        ]
    }
    
    private var twoRows: [GridItem] {
        [
            GridItem(.adaptive(minimum: SleepChartConstants.legendItemMinWidth,
                               maximum: SleepChartConstants.legendItemMaxWidth), spacing: 0, alignment: .leading),
            
            GridItem(.adaptive(minimum: SleepChartConstants.legendItemMinWidth,
                               maximum: SleepChartConstants.legendItemMaxWidth), spacing: 0, alignment: .leading)
            
        ]
    }
    
    // MARK: - Body
    
    public var body: some View {
        
            ViewThatFits {
                
                LazyHGrid(
                    rows: oneRow,
                    alignment: .center,
                    spacing: SleepChartConstants.legendItemSpacing
                ) {
                    legendItems
                }
                
                LazyHGrid(
                    rows: twoRows,
                    alignment: .center,
                    spacing: SleepChartConstants.legendItemSpacing
                ) {
                    legendItems
                }
            }
        }
        
        // MARK: - Legend Items
        
        @ViewBuilder
        private var legendItems: some View {
            ForEach(activeStages, id: \.self) { stage in
                // Only show stages that have recorded time
                if let duration = sleepData[stage], duration > 0 {
                    LegendItem(
                        stage: stage,
                        duration: hideDurations ? nil : duration,
                        colorProvider: colorProvider,
                        durationFormatter: durationFormatter,
                        displayNameProvider: displayNameProvider
                    )
                }
            }
        }
}

/// A single legend item displaying a sleep stage with its color, name, and duration.
///
/// This view shows a colored circle indicator, the stage name, and formatted duration
/// in a horizontal layout suitable for use in a legend grid.
public struct LegendItem: View {
    
    // MARK: - Properties
    
    /// The sleep stage this item represents
    let stage: SleepStage
    
    /// The total duration for this sleep stage
    let duration: TimeInterval?
    
    /// Provider for the stage color
    let colorProvider: SleepStageColorProvider
    
    /// Formatter for the duration display
    let durationFormatter: DurationFormatter
    
    /// Provider for the stage display name
    let displayNameProvider: SleepStageDisplayNameProvider
    
    public init(stage: SleepStage,
         duration: TimeInterval?,
         colorProvider: SleepStageColorProvider = DefaultSleepStageColorProvider(),
         durationFormatter: DurationFormatter = DefaultDurationFormatter(),
         displayNameProvider: SleepStageDisplayNameProvider = DefaultSleepStageDisplayNameProvider()) {
        
        self.stage = stage
        self.duration = duration
        self.colorProvider = colorProvider
        self.durationFormatter = durationFormatter
        self.displayNameProvider = displayNameProvider
    }
    
    // MARK: - Body
    
    public var body: some View {
        HStack(spacing: 4) {
            // Color indicator circle
            Circle()
                .fill(colorProvider.color(for: stage))
                .frame(
                    width: SleepChartConstants.legendCircleSize,
                    height: SleepChartConstants.legendCircleSize
                )
            
            // Stage name
            Text(displayNameProvider.displayName(for: stage))
                .font(.caption)
                .foregroundColor(.secondary)
            
            if let duration {
                
                // Duration
                Text(durationFormatter.format(duration))
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.primary)
            }
        }
    }
}
