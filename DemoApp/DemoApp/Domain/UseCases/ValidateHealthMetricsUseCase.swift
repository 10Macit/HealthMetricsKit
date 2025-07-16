import Foundation
import HealthMetricsKit

/// Use case for validating health metrics data
/// Encapsulates business rules for health data validation and quality checks
public protocol ValidateHealthMetricsUseCaseProtocol {
    func execute(_ metrics: HealthMetrics) -> HealthMetricsValidationResult
}

public struct HealthMetricsValidationResult {
    public let isValid: Bool
    public let validMetrics: [String]
    public let invalidMetrics: [String]
    public let warnings: [String]
    
    public init(isValid: Bool, validMetrics: [String], invalidMetrics: [String], warnings: [String]) {
        self.isValid = isValid
        self.validMetrics = validMetrics
        self.invalidMetrics = invalidMetrics
        self.warnings = warnings
    }
}

public final class ValidateHealthMetricsUseCase: ValidateHealthMetricsUseCaseProtocol {
    
    public init() {}
    
    public func execute(_ metrics: HealthMetrics) -> HealthMetricsValidationResult {
        var validMetrics: [String] = []
        var invalidMetrics: [String] = []
        var warnings: [String] = []
        
        // Validate steps
        if let steps = metrics.steps {
            if HealthMetricsFormatter.isValidStepCount(steps) {
                validMetrics.append("Steps")
                if steps < 1000 {
                    warnings.append("Step count is unusually low")
                } else if steps > 50000 {
                    warnings.append("Step count is unusually high")
                }
            } else {
                invalidMetrics.append("Steps")
            }
        }
        
        // Validate heart rate variability
        if let hrv = metrics.heartRateVariability {
            if HealthMetricsFormatter.isValidHeartRateVariability(hrv) {
                validMetrics.append("Heart Rate Variability")
                if hrv < 10 {
                    warnings.append("HRV is below typical healthy range")
                }
            } else {
                invalidMetrics.append("Heart Rate Variability")
            }
        }
        
        // Validate resting heart rate
        if let rhr = metrics.restingHeartRate {
            if HealthMetricsFormatter.isValidRestingHeartRate(rhr) {
                validMetrics.append("Resting Heart Rate")
                if rhr < 40 || rhr > 100 {
                    warnings.append("Resting heart rate is outside typical range")
                }
            } else {
                invalidMetrics.append("Resting Heart Rate")
            }
        }
        
        // Validate VO₂Max
        if let vo2Max = metrics.vo2Max {
            if HealthMetricsFormatter.isValidVO2Max(vo2Max) {
                validMetrics.append("VO₂Max")
                if vo2Max < 20 {
                    warnings.append("VO₂Max indicates poor cardiovascular fitness")
                }
            } else {
                invalidMetrics.append("VO₂Max")
            }
        }
        
        // Validate sleep duration
        if let sleepDuration = metrics.sleepDuration {
            if HealthMetricsFormatter.isValidSleepDuration(sleepDuration) {
                validMetrics.append("Sleep Duration")
                let hours = sleepDuration / 3600
                if hours < 6 {
                    warnings.append("Sleep duration is below recommended minimum")
                } else if hours > 10 {
                    warnings.append("Sleep duration is above typical range")
                }
            } else {
                invalidMetrics.append("Sleep Duration")
            }
        }
        
        // Business rule: At least 3 valid metrics required for a "valid" result
        let isValid = validMetrics.count >= 3 && invalidMetrics.isEmpty
        
        return HealthMetricsValidationResult(
            isValid: isValid,
            validMetrics: validMetrics,
            invalidMetrics: invalidMetrics,
            warnings: warnings
        )
    }
}
