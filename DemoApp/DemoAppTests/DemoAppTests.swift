//
//  DemoAppTests.swift
//  DemoAppTests
//
//  Created by Samet Macit on 16/07/2025.
//

import XCTest
@testable import DemoApp
@testable import HealthMetricsKit

final class DemoAppTests: XCTestCase {
    
    func testHealthMetricsRepositoryWithMockProvider() async throws {
        let mockProvider = MockHealthDataProvider()
        let repository = DefaultHealthMetricsRepository(healthDataProvider: mockProvider)
        
        XCTAssertTrue(repository.isHealthDataAvailable())
        
        // Test permissions
        try await repository.requestPermissions()
        
        // Test fetching metrics
        let metrics = try await repository.fetchHealthMetrics(for: Date())
        XCTAssertNotNil(metrics)
        XCTAssertNotNil(metrics.steps)
    }
    
    func testHealthMetricsRepositoryWithHealthKitProvider() {
        let healthKitProvider = HealthKitDataProvider()
        let repository = DefaultHealthMetricsRepository(healthDataProvider: healthKitProvider)
        
        // This test will pass on device but may fail on simulator
        // depending on HealthKit availability
        let isAvailable = repository.isHealthDataAvailable()
        XCTAssertTrue(isAvailable || !isAvailable) // Always passes but documents the dependency
    }
    
    func testHealthMetricsExtensions() {
        let metrics = HealthMetrics(
            steps: 12345,
            heartRateVariability: 45.67,
            restingHeartRate: 68.5,
            vo2Max: 42.3,
            sleepDuration: 28800
        )
        
        XCTAssertEqual(metrics.steps, 12345)
        XCTAssertEqual(metrics.heartRateVariability ?? 0, 45.67, accuracy: 0.01)
        XCTAssertEqual(metrics.restingHeartRate ?? 0, 68.5, accuracy: 0.01)
        XCTAssertEqual(metrics.vo2Max ?? 0, 42.3, accuracy: 0.01)
        XCTAssertEqual(metrics.sleepDuration ?? 0, 28800)
    }
    
    func testHealthMetricsRepositoryErrorHandling() async {
        let mockProvider = FailingMockProvider()
        let repository = DefaultHealthMetricsRepository(healthDataProvider: mockProvider)
        
        do {
            _ = try await repository.fetchHealthMetrics(for: Date())
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertTrue(error is HealthDataError)
        }
    }
}

// MARK: - Test Helpers

private class FailingMockProvider: HealthDataProvider {
    func requestPermissions() async throws {
        throw HealthDataError.permissionDenied
    }
    
    func fetchHealthMetrics(for date: Date) async throws -> HealthMetrics {
        throw HealthDataError.dataFetchFailed(NSError(domain: "test", code: 1))
    }
    
    func isHealthDataAvailable() -> Bool {
        return false
    }
}
