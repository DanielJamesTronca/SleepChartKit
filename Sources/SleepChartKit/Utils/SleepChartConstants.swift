import Foundation
import SwiftUI

/// Constants used throughout the SleepChartKit library
public enum SleepChartConstants {
    
    // MARK: - Chart Dimensions
    
    /// Default height for the sleep timeline graph
    public static let chartHeight: CGFloat = 100
    
    /// Total height for the entire sleep chart view including axis and legend
    public static let totalChartHeight: CGFloat = 170
    
    /// Number of sleep stage rows in the timeline
    public static let stageRowCount: CGFloat = 5
    
    // MARK: - Spacing and Padding
    
    /// Vertical spacing between chart components
    public static let componentSpacing: CGFloat = 8
    
    /// Padding for chart legend items
    public static let legendItemSpacing: CGFloat = 20
    
    /// Horizontal padding for time axis labels
    public static let axisHorizontalPadding: CGFloat = 4
    
    /// Bottom padding for dotted lines overlay
    public static let dottedLinesBottomPadding: CGFloat = 5
    
    /// Negative top padding to align axis with chart
    public static let axisNegativeTopPadding: CGFloat = -15
    
    /// Top padding for legend view
    public static let legendTopPadding: CGFloat = 4
    
    // MARK: - Visual Elements
    
    /// Width and height for legend color circles
    public static let legendCircleSize: CGFloat = 8
    
    /// Minimum width for axis time labels
    public static let axisLabelMinWidth: CGFloat = 40
    
    /// Width for time span labels in axis
    public static let timeSpanLabelWidth: CGFloat = 40
    
    /// Available width offset for time span positioning
    public static let timeSpanWidthOffset: CGFloat = 8
    
    /// Additional start padding for time span positioning
    public static let timeSpanStartPadding: CGFloat = 4
    
    // MARK: - Chart Rendering
    
    /// Minimum width for sleep stage bars to ensure visibility
    public static let minimumBarWidth: CGFloat = 1
    
    /// Corner radius ratio for sleep stage bars (bar height / ratio)
    public static let barCornerRadiusRatio: CGFloat = 6
    
    /// Line width for dotted grid lines
    public static let dottedLineWidth: CGFloat = 0.5
    
    /// Dash pattern for dotted grid lines
    public static let dottedLineDashPattern: [CGFloat] = [2, 3]
    
    /// Opacity for dotted grid lines
    public static let dottedLineOpacity: CGFloat = 0.5
    
    /// Line width for stage connector curves
    public static let connectorLineWidth: CGFloat = 1.5
    
    /// Opacity for stage connector curves
    public static let connectorOpacity: CGFloat = 0.4
    
    /// Control point ratio for connector curve smoothness
    public static let connectorControlPointRatio1: CGFloat = 0.3
    public static let connectorControlPointRatio2: CGFloat = 0.7
    
    // MARK: - Legend Configuration
    
    /// Minimum width for legend grid items
    public static let legendItemMinWidth: CGFloat = 100
    
    /// Maximum width for legend grid items
    public static let legendItemMaxWidth: CGFloat = 150
    
    /// Corner radius for chart clipping
    public static let chartClipCornerRadius: CGFloat = 8
    
    // MARK: - Dotted Lines Overlay
    
    /// Height extension for dotted lines below the chart
    public static let dottedLinesHeightExtension: CGFloat = 15
}
