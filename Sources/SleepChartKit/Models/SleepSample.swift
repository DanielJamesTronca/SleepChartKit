import Foundation
#if canImport(HealthKit)
import HealthKit
#endif

public struct SleepSample: Hashable, Codable {
    public let stage: SleepStage
    public let startDate: Date
    public let endDate: Date
    
    public init(stage: SleepStage, startDate: Date, endDate: Date) {
        self.stage = stage
        self.startDate = startDate
        self.endDate = endDate
    }
    
    #if canImport(HealthKit)
    @available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
    public init?(healthKitSample: HKCategorySample) {
        guard let sleepAnalysisValue = HKCategoryValueSleepAnalysis(rawValue: healthKitSample.value),
              let stage = SleepStage(healthKitValue: sleepAnalysisValue) else {
            return nil
        }
        
        self.stage = stage
        self.startDate = healthKitSample.startDate
        self.endDate = healthKitSample.endDate
    }
    
    @available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
    public static func samples(from healthKitSamples: [HKCategorySample]) -> [SleepSample] {
        return healthKitSamples.compactMap { SleepSample(healthKitSample: $0) }
    }
    #endif
    
    public var duration: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }
}
