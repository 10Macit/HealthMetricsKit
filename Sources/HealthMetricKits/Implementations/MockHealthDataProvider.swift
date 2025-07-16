import Foundation

/// Mock implementation of HealthDataProvider
/// Provides deterministic mock data for development and testing
@available(iOS 16.0, macOS 10.15, *)
public final class MockHealthDataProvider: HealthDataProvider {
    
    public init() {}
    
    public func isHealthDataAvailable() -> Bool {
        return true
    }
    
    public func requestPermissions() async throws {
        // Mock implementation - always succeeds
        // In a real scenario, you might want to simulate different permission states
    }
    
    public func fetchHealthMetrics(for date: Date) async throws -> HealthMetrics {
        // Simulate network/processing delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Generate deterministic mock data based on date
        // This ensures consistent values for the same date across runs
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        
        // Use day of year as seed for consistent but varied values
        let seed = Double(dayOfYear)
        
        return HealthMetrics(
            steps: generateSteps(seed: seed),
            heartRateVariability: generateHRV(seed: seed),
            restingHeartRate: generateRestingHeartRate(seed: seed),
            vo2Max: generateVO2Max(seed: seed),
            sleepDuration: generateSleepDuration(seed: seed),
            date: date
        )
    }
    
    // MARK: - Private Mock Data Generation
    
    private func generateSteps(seed: Double) -> Int {
        // Generate steps between 8,000 - 12,950
        let baseSteps = 8000
        let variation = Int((seed.truncatingRemainder(dividingBy: 100)) * 50)
        return baseSteps + variation
    }
    
    private func generateHRV(seed: Double) -> Double {
        // Generate HRV between 30 - 70 ms
        let baseHRV = 30.0
        let variation = (seed.truncatingRemainder(dividingBy: 50)) * 0.8
        return baseHRV + variation
    }
    
    private func generateRestingHeartRate(seed: Double) -> Double {
        // Generate RHR between 55 - 85 BPM
        let baseRHR = 55.0
        let variation = (seed.truncatingRemainder(dividingBy: 25)) * 1.2
        return baseRHR + variation
    }
    
    private func generateVO2Max(seed: Double) -> Double {
        // Generate VO₂Max between 35 - 65 ml/kg/min
        let baseVO2Max = 35.0
        let variation = (seed.truncatingRemainder(dividingBy: 20)) * 1.5
        return baseVO2Max + variation
    }
    
    private func generateSleepDuration(seed: Double) -> TimeInterval {
        // Generate sleep duration between 6.5 - 9.5 hours (in seconds)
        let baseHours = 6.5
        let variationHours = (seed.truncatingRemainder(dividingBy: 10)) * 0.3
        let totalHours = baseHours + variationHours
        return totalHours * 3600 // Convert to seconds
    }
}