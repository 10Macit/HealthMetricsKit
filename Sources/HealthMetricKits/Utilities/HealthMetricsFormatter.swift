import Foundation

/// Utility class for formatting health metrics into user-friendly strings
public struct HealthMetricsFormatter {
    
    /// Formats a step count into a readable string
    /// - Parameter steps: The number of steps
    /// - Returns: Formatted string (e.g., "10,000 steps")
    public static func formatSteps(_ steps: Int?) -> String {
        guard let steps = steps else { return "N/A" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return "\(formatter.string(from: NSNumber(value: steps)) ?? "\(steps)") steps"
    }
    
    /// Formats heart rate variability into a readable string
    /// - Parameter hrv: HRV value in milliseconds
    /// - Returns: Formatted string (e.g., "45.2 ms")
    public static func formatHeartRateVariability(_ hrv: Double?) -> String {
        guard let hrv = hrv else { return "N/A" }
        return String(format: "%.1f ms", hrv)
    }
    
    /// Formats resting heart rate into a readable string
    /// - Parameter rhr: Resting heart rate in BPM
    /// - Returns: Formatted string (e.g., "65 BPM")
    public static func formatRestingHeartRate(_ rhr: Double?) -> String {
        guard let rhr = rhr else { return "N/A" }
        return String(format: "%.0f BPM", rhr)
    }
    
    /// Formats VO₂Max into a readable string
    /// - Parameter vo2Max: VO₂Max value in ml/kg/min
    /// - Returns: Formatted string (e.g., "42.5 ml/kg/min")
    public static func formatVO2Max(_ vo2Max: Double?) -> String {
        guard let vo2Max = vo2Max else { return "N/A" }
        return String(format: "%.1f ml/kg/min", vo2Max)
    }
    
    /// Formats sleep duration into a readable string
    /// - Parameter duration: Sleep duration in seconds
    /// - Returns: Formatted string (e.g., "8h 30m")
    public static func formatSleepDuration(_ duration: TimeInterval?) -> String {
        guard let duration = duration else { return "N/A" }
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        return "\(hours)h \(minutes)m"
    }
    
    /// Formats a date for health metrics display
    /// - Parameter date: The date to format
    /// - Returns: Formatted date string
    public static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Health Metric Range Validators

extension HealthMetricsFormatter {
    
    /// Validates if a step count is within a reasonable range
    /// - Parameter steps: The step count to validate
    /// - Returns: true if the steps are within a reasonable range (0-100,000)
    public static func isValidStepCount(_ steps: Int) -> Bool {
        return steps >= 0 && steps <= 100_000
    }
    
    /// Validates if HRV is within a reasonable range
    /// - Parameter hrv: The HRV value to validate
    /// - Returns: true if HRV is within a reasonable range (1-200 ms)
    public static func isValidHeartRateVariability(_ hrv: Double) -> Bool {
        return hrv >= 1.0 && hrv <= 200.0
    }
    
    /// Validates if resting heart rate is within a reasonable range
    /// - Parameter rhr: The resting heart rate to validate
    /// - Returns: true if RHR is within a reasonable range (30-120 BPM)
    public static func isValidRestingHeartRate(_ rhr: Double) -> Bool {
        return rhr >= 30.0 && rhr <= 120.0
    }
    
    /// Validates if VO₂Max is within a reasonable range
    /// - Parameter vo2Max: The VO₂Max value to validate
    /// - Returns: true if VO₂Max is within a reasonable range (10-90 ml/kg/min)
    public static func isValidVO2Max(_ vo2Max: Double) -> Bool {
        return vo2Max >= 10.0 && vo2Max <= 90.0
    }
    
    /// Validates if sleep duration is within a reasonable range
    /// - Parameter duration: The sleep duration to validate (in seconds)
    /// - Returns: true if duration is within a reasonable range (1-16 hours)
    public static func isValidSleepDuration(_ duration: TimeInterval) -> Bool {
        let hours = duration / 3600
        return hours >= 1.0 && hours <= 16.0
    }
}