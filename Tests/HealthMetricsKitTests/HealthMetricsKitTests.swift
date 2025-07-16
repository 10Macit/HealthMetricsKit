import XCTest
@testable import HealthMetricsKit

final class HealthMetricsKitTests: XCTestCase {
    
    // MARK: - HealthMetrics Tests
    
    func testHealthMetricsInitialization() {
        let date = Date()
        let metrics = HealthMetrics(
            steps: 10000,
            heartRateVariability: 45.5,
            restingHeartRate: 65.0,
            vo2Max: 42.5,
            sleepDuration: 28800, // 8 hours
            date: date
        )
        
        XCTAssertEqual(metrics.steps, 10000)
        XCTAssertEqual(metrics.heartRateVariability, 45.5)
        XCTAssertEqual(metrics.restingHeartRate, 65.0)
        XCTAssertEqual(metrics.vo2Max, 42.5)
        XCTAssertEqual(metrics.sleepDuration, 28800)
        XCTAssertEqual(metrics.date, date)
    }
    
    func testHealthMetricsWithNilValues() {
        let metrics = HealthMetrics()
        
        XCTAssertNil(metrics.steps)
        XCTAssertNil(metrics.heartRateVariability)
        XCTAssertNil(metrics.restingHeartRate)
        XCTAssertNil(metrics.vo2Max)
        XCTAssertNil(metrics.sleepDuration)
        XCTAssertNotNil(metrics.date)
    }
    
    // MARK: - MockHealthDataProvider Tests
    
    func testMockHealthDataProviderAvailability() {
        let provider = MockHealthDataProvider()
        XCTAssertTrue(provider.isHealthDataAvailable())
    }
    
    func testMockHealthDataProviderPermissions() async throws {
        let provider = MockHealthDataProvider()
        
        // Should not throw
        try await provider.requestPermissions()
    }
    
    func testMockHealthDataProviderFetchMetrics() async throws {
        let provider = MockHealthDataProvider()
        let testDate = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 1))!
        
        let metrics = try await provider.fetchHealthMetrics(for: testDate)
        
        XCTAssertNotNil(metrics.steps)
        XCTAssertNotNil(metrics.heartRateVariability)
        XCTAssertNotNil(metrics.restingHeartRate)
        XCTAssertNotNil(metrics.vo2Max)
        XCTAssertNotNil(metrics.sleepDuration)
        XCTAssertEqual(metrics.date, testDate)
        
        // Verify reasonable ranges
        XCTAssertGreaterThan(metrics.steps!, 0)
        XCTAssertGreaterThan(metrics.heartRateVariability!, 0)
        XCTAssertGreaterThan(metrics.restingHeartRate!, 0)
        XCTAssertGreaterThan(metrics.vo2Max!, 0)
        XCTAssertGreaterThan(metrics.sleepDuration!, 0)
    }
    
    func testMockHealthDataProviderDeterministicValues() async throws {
        let provider = MockHealthDataProvider()
        let testDate = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 1))!
        
        let metrics1 = try await provider.fetchHealthMetrics(for: testDate)
        let metrics2 = try await provider.fetchHealthMetrics(for: testDate)
        
        // Same date should produce same values (deterministic)
        XCTAssertEqual(metrics1.steps, metrics2.steps)
        XCTAssertEqual(metrics1.heartRateVariability, metrics2.heartRateVariability)
        XCTAssertEqual(metrics1.restingHeartRate, metrics2.restingHeartRate)
        XCTAssertEqual(metrics1.vo2Max, metrics2.vo2Max)
        XCTAssertEqual(metrics1.sleepDuration, metrics2.sleepDuration)
    }
    
    func testMockHealthDataProviderDifferentDates() async throws {
        let provider = MockHealthDataProvider()
        let date1 = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 1))!
        let date2 = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 2))!
        
        let metrics1 = try await provider.fetchHealthMetrics(for: date1)
        let metrics2 = try await provider.fetchHealthMetrics(for: date2)
        
        // Different dates should produce different values
        XCTAssertNotEqual(metrics1.steps, metrics2.steps)
    }
    
    // MARK: - HealthDataError Tests
    
    func testHealthDataErrorDescriptions() {
        let permissionError = HealthDataError.permissionDenied
        let unavailableError = HealthDataError.healthDataNotAvailable
        let fetchError = HealthDataError.dataFetchFailed(NSError(domain: "test", code: 1))
        let invalidError = HealthDataError.invalidData
        
        XCTAssertNotNil(permissionError.errorDescription)
        XCTAssertNotNil(unavailableError.errorDescription)
        XCTAssertNotNil(fetchError.errorDescription)
        XCTAssertNotNil(invalidError.errorDescription)
        
        XCTAssertTrue(permissionError.errorDescription!.contains("permission"))
        XCTAssertTrue(unavailableError.errorDescription!.contains("not available"))
        XCTAssertTrue(fetchError.errorDescription!.contains("Failed to fetch"))
        XCTAssertTrue(invalidError.errorDescription!.contains("Invalid"))
    }
    
    // MARK: - Performance Tests
    
    func testMockProviderPerformance() async throws {
        let provider = MockHealthDataProvider()
        let testDate = Date()
        
        measure {
            let expectation = XCTestExpectation(description: "Fetch metrics")
            expectation.fulfill() // Just measure the sync part for now
        }
        
        // Separate async test
        let startTime = CFAbsoluteTimeGetCurrent()
        _ = try await provider.fetchHealthMetrics(for: testDate)
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        // Should complete within reasonable time (including mock delay)
        XCTAssertLessThan(timeElapsed, 1.0, "Mock provider should complete quickly")
    }
}
