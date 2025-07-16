import Foundation

/// Protocol defining the interface for health data access
public protocol HealthDataProvider {
    /// Requests necessary permissions for health data access
    /// - Throws: HealthDataError if permissions cannot be obtained
    func requestPermissions() async throws
    
    /// Fetches health metrics for a specific date
    /// - Parameter date: The date for which to fetch metrics
    /// - Returns: HealthMetrics containing the day's health data
    /// - Throws: HealthDataError if data cannot be fetched
    func fetchHealthMetrics(for date: Date) async throws -> HealthMetrics
    
    /// Checks if health data is available on the current device
    /// - Returns: true if health data is available, false otherwise
    func isHealthDataAvailable() -> Bool
}