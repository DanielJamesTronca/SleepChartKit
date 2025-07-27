import SwiftUI

/// Example demonstrating how to use the SleepWeeklyChartView with sample data.
///
/// This example shows various configurations of the weekly chart including
/// vertical and horizontal layouts, with and without health metrics.
public struct WeeklyChartExample: View {
    
    // MARK: - Sample Data
    
    /// Sample weekly sleep data for demonstration
    private let sampleWeeklyData: [DailySleepData] = {
        let calendar = Calendar.current
        let today = Date()
        
        return (0..<7).compactMap { dayOffset in
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            let startHour = [21, 22, 23, 22, 21, 23, 22][dayOffset % 7] // Varying bedtimes
            let startDate = calendar.date(bySettingHour: startHour, minute: 0, second: 0, of: date)!
            
            // Simulate different sleep patterns for each day
            let sleepDuration = [7.5, 8.2, 6.8, 7.8, 8.5, 6.2, 8.8][dayOffset % 7] // Hours
            let deepSleepRatio = [0.25, 0.22, 0.28, 0.24, 0.26, 0.20, 0.30][dayOffset % 7]
            let remSleepRatio = [0.22, 0.25, 0.20, 0.23, 0.24, 0.18, 0.26][dayOffset % 7]
            
            let totalSleepSeconds = sleepDuration * 3600
            let deepSleepSeconds = totalSleepSeconds * deepSleepRatio
            let remSleepSeconds = totalSleepSeconds * remSleepRatio
            let coreSleepSeconds = totalSleepSeconds - deepSleepSeconds - remSleepSeconds
            
            var currentDate = startDate
            var samples: [SleepSample] = []
            
            // In bed period
            let inBedDuration: TimeInterval = 900 // 15 minutes
            samples.append(SleepSample(
                stage: .inBed,
                startDate: currentDate,
                endDate: currentDate.addingTimeInterval(inBedDuration)
            ))
            currentDate = currentDate.addingTimeInterval(inBedDuration)
            
            // Core sleep period
            samples.append(SleepSample(
                stage: .asleepCore,
                startDate: currentDate,
                endDate: currentDate.addingTimeInterval(coreSleepSeconds)
            ))
            currentDate = currentDate.addingTimeInterval(coreSleepSeconds)
            
            // Deep sleep period
            samples.append(SleepSample(
                stage: .asleepDeep,
                startDate: currentDate,
                endDate: currentDate.addingTimeInterval(deepSleepSeconds)
            ))
            currentDate = currentDate.addingTimeInterval(deepSleepSeconds)
            
            // REM sleep period
            samples.append(SleepSample(
                stage: .asleepREM,
                startDate: currentDate,
                endDate: currentDate.addingTimeInterval(remSleepSeconds)
            ))
            currentDate = currentDate.addingTimeInterval(remSleepSeconds)
            
            // Optional brief awake period for some days
            if dayOffset % 3 == 0 {
                let awakeDuration: TimeInterval = 300 // 5 minutes
                samples.append(SleepSample(
                    stage: .awake,
                    startDate: currentDate,
                    endDate: currentDate.addingTimeInterval(awakeDuration)
                ))
                currentDate = currentDate.addingTimeInterval(awakeDuration)
                
                // Back to core sleep
                samples.append(SleepSample(
                    stage: .asleepCore,
                    startDate: currentDate,
                    endDate: currentDate.addingTimeInterval(1800) // 30 minutes
                ))
            }
            
            return DailySleepData(date: date, samples: samples)
        }.reversed().map { $0 }
    }()
    
    // MARK: - Body
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                // Vertical weekly chart with rounded rectangles
                VStack(alignment: .leading, spacing: 16) {
                    Text("Weekly Sleep Chart")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    SleepWeeklyChartView(
                        weeklySamples: sampleWeeklyData,
                        layout: .vertical
                    )
                }
                
                Divider()
                
                // Horizontal weekly chart
                VStack(alignment: .leading, spacing: 16) {
                    Text("Horizontal Weekly Sleep Chart")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    SleepWeeklyChartView(
                        weeklySamples: sampleWeeklyData,
                        layout: .horizontal
                    )
                }
                
                Divider()
                
                // Compact weekly chart
                VStack(alignment: .leading, spacing: 16) {
                    Text("Compact Weekly Chart")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    SleepWeeklyChartView(
                        weeklySamples: sampleWeeklyData,
                        layout: .vertical,
                        weeklyConfig: .compact
                    )
                }
                
                Divider()
                
                // Weekly chart with health metrics
                VStack(alignment: .leading, spacing: 16) {
                    Text("Weekly Chart with Health Metrics")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    SleepWeeklyChartView(
                        weeklySamples: sampleWeeklyData,
                        layout: .vertical,
                        showHealthMetrics: true,
                        weeklyConfig: .large
                    )
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Weekly Sleep Charts")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Preview

#if DEBUG
struct WeeklyChartExample_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WeeklyChartExample()
        }
        .previewDisplayName("Weekly Chart Example")
    }
}
#endif