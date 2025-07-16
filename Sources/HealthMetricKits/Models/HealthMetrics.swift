import Foundation

/// A structure representing daily health metrics
public struct HealthMetrics {
    /// Number of steps taken during the day
    public let steps: Int?
    
    /// Heart rate variability measurement in milliseconds
    public let heartRateVariability: Double?
    
    /// Resting heart rate in beats per minute
    public let restingHeartRate: Double?
    
    /// VO₂Max measurement in ml/kg/min
    public let vo2Max: Double?
    
    /// Sleep duration in seconds
    public let sleepDuration: TimeInterval?
    
    /// The date this metrics data represents
    public let date: Date
    
    /// Initializes a new HealthMetrics instance
    /// - Parameters:
    ///   - steps: Number of steps taken (optional)
    ///   - heartRateVariability: HRV measurement in ms (optional)
    ///   - restingHeartRate: Resting heart rate in BPM (optional)
    ///   - vo2Max: VO₂Max measurement in ml/kg/min (optional)
    ///   - sleepDuration: Sleep duration in seconds (optional)
    ///   - date: The date for this data (defaults to current date)
    public init(
        steps: Int? = nil,
        heartRateVariability: Double? = nil,
        restingHeartRate: Double? = nil,
        vo2Max: Double? = nil,
        sleepDuration: TimeInterval? = nil,
        date: Date = Date()
    ) {
        self.steps = steps
        self.heartRateVariability = heartRateVariability
        self.restingHeartRate = restingHeartRate
        self.vo2Max = vo2Max
        self.sleepDuration = sleepDuration
        self.date = date
    }
}