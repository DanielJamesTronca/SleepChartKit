import Foundation

public protocol TimeSpanGenerator {
    func generateTimeSpans(for samples: [SleepSample]) -> [TimeSpan]
}

public struct DefaultTimeSpanGenerator: TimeSpanGenerator {
    private let timeFormatter: DateFormatter
    
    public init() {
        self.timeFormatter = DateFormatter()
        self.timeFormatter.dateFormat = "HH:mm"
    }
    
    public func generateTimeSpans(for samples: [SleepSample]) -> [TimeSpan] {
        guard let firstSample = samples.first,
              let lastSample = samples.last else { return [] }
        
        let totalDuration = lastSample.endDate.timeIntervalSince(firstSample.startDate)
        guard totalDuration > 0 else { return [] }
        
        var spans: [TimeSpan] = []
        let intervalCount = 4
        
        for i in 1..<intervalCount {
            let fraction = CGFloat(i) / CGFloat(intervalCount)
            let timeOffset = TimeInterval(fraction) * totalDuration
            let date = firstSample.startDate.addingTimeInterval(timeOffset)
            let timeString = timeFormatter.string(from: date)
            
            spans.append(TimeSpan(time: timeString, position: fraction))
        }
        
        return spans
    }
}