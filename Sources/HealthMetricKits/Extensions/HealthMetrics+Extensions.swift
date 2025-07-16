import Foundation

// MARK: - HealthMetrics Extensions

extension HealthMetrics {
    /// Returns a formatted string for sleep duration in hours and minutes
    public var formattedSleepDuration: String {
        guard let sleepDuration = sleepDuration else { return "N/A" }
        let hours = Int(sleepDuration) / 3600
        let minutes = Int(sleepDuration) % 3600 / 60
        return "\(hours)h \(minutes)m"
    }
    
    /// Returns true if all health metrics have values
    public var isComplete: Bool {
        return steps != nil &&
               heartRateVariability != nil &&
               restingHeartRate != nil &&
               vo2Max != nil &&
               sleepDuration != nil
    }
    
    /// Returns the number of metrics that have values
    public var completedMetricsCount: Int {
        var count = 0
        if steps != nil { count += 1 }
        if heartRateVariability != nil { count += 1 }
        if restingHeartRate != nil { count += 1 }
        if vo2Max != nil { count += 1 }
        if sleepDuration != nil { count += 1 }
        return count
    }
    
    /// Returns a formatted date string for the metrics date
    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - CustomStringConvertible

extension HealthMetrics: CustomStringConvertible {
    public var description: String {
        let stepString = steps.map { "\($0) steps" } ?? "N/A"
        let hrvString = heartRateVariability.map { String(format: "%.1f ms", $0) } ?? "N/A"
        let rhrString = restingHeartRate.map { String(format: "%.0f BPM", $0) } ?? "N/A"
        let vo2MaxString = vo2Max.map { String(format: "%.1f ml/kg/min", $0) } ?? "N/A"
        let sleepString = formattedSleepDuration
        
        return """
        HealthMetrics for \(formattedDate):
        • Steps: \(stepString)
        • Heart Rate Variability: \(hrvString)
        • Resting Heart Rate: \(rhrString)
        • VO₂Max: \(vo2MaxString)
        • Sleep Duration: \(sleepString)
        """
    }
}