import XCTest
@testable import SleepChartKit
import SwiftUI

final class CircularChartTests: XCTestCase {
    
    func testCircularChartConfiguration() {
        let config = CircularChartConfiguration(
            lineWidth: 20,
            size: 200,
            showLabels: false
        )
        
        XCTAssertEqual(config.lineWidth, 20)
        XCTAssertEqual(config.size, 200)
        XCTAssertFalse(config.showLabels)
    }
    
    func testDefaultConfiguration() {
        let defaultConfig = CircularChartConfiguration.default
        
        XCTAssertEqual(defaultConfig.lineWidth, 16)
        XCTAssertEqual(defaultConfig.size, 160)
        XCTAssertTrue(defaultConfig.showLabels)
    }
    
    func testSleepChartStyleEnum() {
        let timelineStyle = SleepChartStyle.timeline
        let circularStyle = SleepChartStyle.circular
        let minimalStyle = SleepChartStyle.minimal
        
        XCTAssertNotEqual(timelineStyle, circularStyle)
        XCTAssertNotEqual(timelineStyle, minimalStyle)
        XCTAssertNotEqual(circularStyle, minimalStyle)
    }
    
    func testAppleSleepColorProvider() {
        let colorProvider = AppleSleepColorProvider()
        
        // Test that each stage returns a color
        for stage in SleepStage.allCases {
            let color = colorProvider.color(for: stage)
            XCTAssertNotNil(color)
        }
    }
    
    func testPastelSleepColorProvider() {
        let colorProvider = PastelSleepColorProvider()
        
        // Test that each stage returns a color
        for stage in SleepStage.allCases {
            let color = colorProvider.color(for: stage)
            XCTAssertNotNil(color)
        }
    }
    
    func testHighContrastSleepColorProvider() {
        let colorProvider = HighContrastSleepColorProvider()
        
        // Test that each stage returns a color
        for stage in SleepStage.allCases {
            let color = colorProvider.color(for: stage)
            XCTAssertNotNil(color)
        }
    }
    
    @MainActor
    func testCircularChartViewCreation() {
        let samples = createTestSamples()
        
        let circularChart = SleepCircularChartView(
            samples: samples,
            lineWidth: 18,
            size: 180
        )
        
        XCTAssertNotNil(circularChart)
    }
    
    @MainActor
    func testSleepChartViewWithCircularStyle() {
        let samples = createTestSamples()
        let config = CircularChartConfiguration(size: 200)
        
        let chart = SleepChartView(
            samples: samples,
            style: .circular,
            circularConfig: config
        )
        
        XCTAssertNotNil(chart)
    }
    
    @MainActor
    func testSleepChartViewWithMinimalStyle() {
        let samples = createTestSamples()
        
        let chart = SleepChartView(
            samples: samples,
            style: .minimal
        )
        
        XCTAssertNotNil(chart)
    }
    
    // MARK: - Helper Methods
    
    private func createTestSamples() -> [SleepSample] {
        let calendar = Calendar.current
        let baseDate = calendar.startOfDay(for: Date())
        let startDate = calendar.date(byAdding: .hour, value: 22, to: baseDate)!
        
        return [
            SleepSample(
                stage: .asleepCore,
                startDate: startDate,
                endDate: calendar.date(byAdding: .hour, value: 2, to: startDate)!
            ),
            SleepSample(
                stage: .asleepDeep,
                startDate: calendar.date(byAdding: .hour, value: 2, to: startDate)!,
                endDate: calendar.date(byAdding: .hour, value: 4, to: startDate)!
            ),
            SleepSample(
                stage: .asleepREM,
                startDate: calendar.date(byAdding: .hour, value: 4, to: startDate)!,
                endDate: calendar.date(byAdding: .hour, value: 6, to: startDate)!
            )
        ]
    }
}
