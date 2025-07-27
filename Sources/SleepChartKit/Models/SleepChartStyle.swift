import Foundation

/// Defines the visual style for sleep charts
public enum SleepChartStyle {
    /// Traditional timeline chart with horizontal bars
    case timeline
    
    /// Circular chart with color-coded segments
    case circular
    
    /// Weekly chart showing multiple days of sleep data
    case weekly(WeeklyChartLayout)
}

/// Configuration options for circular sleep charts
public struct CircularChartConfiguration: Sendable {
    /// Width of the circular segments
    public let lineWidth: CGFloat
    
    /// Size of the circular chart
    public let size: CGFloat
    
    /// Whether to show labels inside the circle
    public let showLabels: Bool
    
    /// Creates a new circular chart configuration
    ///
    /// - Parameters:
    ///   - lineWidth: Width of the circular segments (default: 16)
    ///   - size: Size of the circular chart (default: 160)
    ///   - showLabels: Whether to show time labels (default: true)
    public init(
        lineWidth: CGFloat = 16,
        size: CGFloat = 160,
        showLabels: Bool = true
    ) {
        self.lineWidth = lineWidth
        self.size = size
        self.showLabels = showLabels
    }
    
    /// Default configuration for circular charts
    public static let `default` = CircularChartConfiguration()
}
