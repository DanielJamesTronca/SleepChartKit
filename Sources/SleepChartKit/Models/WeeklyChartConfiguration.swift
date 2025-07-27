import Foundation

/// Layout options for the weekly sleep chart
public enum WeeklyChartLayout: CaseIterable, Sendable {
    /// Vertical layout with days displayed as columns
    case vertical
    
    /// Horizontal layout with days displayed as rows
    case horizontal
}

/// Configuration options for weekly sleep charts
public struct WeeklyChartConfiguration: Sendable {
    
    /// Spacing between chart components
    public let componentSpacing: CGFloat
    
    /// Spacing between individual days
    public let daySpacing: CGFloat
    
    /// Width of each day column in vertical layout
    public let columnWidth: CGFloat
    
    /// Maximum height for day columns
    public let maxColumnHeight: CGFloat
    
    /// Height representing one hour of sleep in column layout
    public let hourHeight: CGFloat
    
    /// Corner radius for rounded rectangle sleep segments
    public let segmentCornerRadius: CGFloat
    
    /// Spacing between sleep stage segments within a day
    public let segmentSpacing: CGFloat
    
    /// Width representing one hour of sleep in row layout
    public let hourWidth: CGFloat
    
    /// Height of each row in horizontal layout
    public let rowHeight: CGFloat
    
    /// Whether to show health metrics integration
    public let showHealthMetrics: Bool
    
    /// Whether to highlight weekends differently
    public let highlightWeekends: Bool
    
    /// Creates a new weekly chart configuration
    ///
    /// - Parameters:
    ///   - componentSpacing: Spacing between chart components (default: 16)
    ///   - daySpacing: Spacing between individual days (default: 8)
    ///   - columnWidth: Width of each day column (default: 40)
    ///   - maxColumnHeight: Maximum height for columns (default: 120)
    ///   - hourHeight: Height per hour in columns (default: 15)
    ///   - segmentCornerRadius: Corner radius for rounded segments (default: 4)
    ///   - segmentSpacing: Spacing between segments (default: 2)
    ///   - hourWidth: Width per hour in rows (default: 20)
    ///   - rowHeight: Height of each row (default: 20)
    ///   - showHealthMetrics: Show health metrics (default: false)
    ///   - highlightWeekends: Highlight weekends (default: true)
    public init(
        componentSpacing: CGFloat = 16,
        daySpacing: CGFloat = 8,
        columnWidth: CGFloat = 40,
        maxColumnHeight: CGFloat = 120,
        hourHeight: CGFloat = 15,
        segmentCornerRadius: CGFloat = 4,
        segmentSpacing: CGFloat = 2,
        hourWidth: CGFloat = 20,
        rowHeight: CGFloat = 20,
        showHealthMetrics: Bool = false,
        highlightWeekends: Bool = true
    ) {
        self.componentSpacing = componentSpacing
        self.daySpacing = daySpacing
        self.columnWidth = columnWidth
        self.maxColumnHeight = maxColumnHeight
        self.hourHeight = hourHeight
        self.segmentCornerRadius = segmentCornerRadius
        self.segmentSpacing = segmentSpacing
        self.hourWidth = hourWidth
        self.rowHeight = rowHeight
        self.showHealthMetrics = showHealthMetrics
        self.highlightWeekends = highlightWeekends
    }
    
    /// Default configuration for weekly charts
    public static let `default` = WeeklyChartConfiguration()
    
    /// Compact configuration with smaller dimensions
    public static let compact = WeeklyChartConfiguration(
        componentSpacing: 12,
        daySpacing: 6,
        columnWidth: 32,
        maxColumnHeight: 80,
        hourHeight: 10,
        segmentCornerRadius: 3,
        segmentSpacing: 1,
        hourWidth: 15,
        rowHeight: 16
    )
    
    /// Large configuration with bigger dimensions for better visibility
    public static let large = WeeklyChartConfiguration(
        componentSpacing: 20,
        daySpacing: 12,
        columnWidth: 50,
        maxColumnHeight: 160,
        hourHeight: 20,
        segmentCornerRadius: 6,
        segmentSpacing: 3,
        hourWidth: 25,
        rowHeight: 24
    )
}