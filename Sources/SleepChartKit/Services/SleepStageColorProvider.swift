import SwiftUI
#if canImport(HealthKit)
import HealthKit
#endif

public protocol SleepStageColorProvider {
    func color(for stage: SleepStage) -> Color
    
    #if canImport(HealthKit)
    @available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
    func color(for healthKitValue: HKCategoryValueSleepAnalysis) -> Color
    #endif
}

#if canImport(HealthKit)
@available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
public extension SleepStageColorProvider {
    func color(for healthKitValue: HKCategoryValueSleepAnalysis) -> Color {
        guard let stage = SleepStage(healthKitValue: healthKitValue) else {
            return .gray
        }
        return color(for: stage)
    }
}
#endif

public struct DefaultSleepStageColorProvider: SleepStageColorProvider {
    public init() {}
    
    public func color(for stage: SleepStage) -> Color {
        switch stage {
        case .awake:
            return .orange
        case .asleepREM:
            return .cyan
        case .asleepCore:
            return .blue
        case .asleepDeep:
            return .indigo
        case .asleepUnspecified:
            return Color(UIColor.lightGray)
        case .inBed:
            return .gray
        }
    }
    
}

public struct CustomSleepStageColorProvider: SleepStageColorProvider {
    
    var awakeColour: Color
    var remColour: Color
    var coreColour: Color
    var deepColour: Color
    var unspecifiedColour: Color
    var inBedColour: Color
    
    public init(awake: Color? = nil, REM: Color? = nil, core: Color? = nil, deep: Color? = nil, unspecified: Color? = nil, inBed: Color? = nil) {
        
        self.awakeColour = awake ?? .orange
        self.remColour = REM ?? .cyan
        self.coreColour = core ?? .blue
        self.deepColour = deep ?? .indigo
        self.unspecifiedColour = unspecified ?? .purple
        self.inBedColour = inBed ?? .gray
    }
    
    public func color(for stage: SleepStage) -> Color {
        
        switch stage {
            
        case .awake: return awakeColour
        case .asleepREM: return remColour
        case .asleepCore: return coreColour
        case .asleepDeep: return deepColour
        case .asleepUnspecified: return unspecifiedColour
        case .inBed: return inBedColour
            
        }
    }
}
