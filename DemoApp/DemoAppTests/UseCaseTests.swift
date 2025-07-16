import XCTest
import Combine
@testable import DemoApp
@testable import HealthMetricsKit

@MainActor
final class UseCaseTests: XCTestCase {
    
    private var mockRepository: MockHealthMetricsRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockHealthMetricsRepository()
    }
    
    override func tearDown() {
        mockRepository = nil
        super.tearDown()
    }
    
    // MARK: - FetchHealthMetricsUseCase Tests
    
    func testFetchHealthMetricsUseCaseSuccess() async throws {
        let testMetrics = HealthMetrics(
            steps: 10000,
            heartRateVariability: 45.0,
            restingHeartRate: 65.0,
            vo2Max: 42.0,
            sleepDuration: 28800
        )
        mockRepository.mockMetrics = testMetrics
        
        let useCase = FetchHealthMetricsUseCase(repository: mockRepository)
        let result = try await useCase.execute(for: Date())
        
        XCTAssertEqual(result.steps, 10000)
        XCTAssertEqual(result.heartRateVariability, 45.0)
        XCTAssertEqual(result.restingHeartRate, 65.0)
        XCTAssertEqual(result.vo2Max, 42.0)
        XCTAssertEqual(result.sleepDuration, 28800)
    }
    
    func testFetchHealthMetricsUseCaseFutureDate() async {
        let useCase = FetchHealthMetricsUseCase(repository: mockRepository)
        let futureDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        
        do {
            _ = try await useCase.execute(for: futureDate)
            XCTFail("Should throw error for future date")
        } catch {
            XCTAssertTrue(error is HealthDataError)
            if case HealthDataError.invalidData = error {
                // Expected error
            } else {
                XCTFail("Wrong error type")
            }
        }
    }
    
    func testFetchHealthMetricsUseCaseRepositoryError() async {
        mockRepository.shouldThrowError = true
        let useCase = FetchHealthMetricsUseCase(repository: mockRepository)
        
        do {
            _ = try await useCase.execute(for: Date())
            XCTFail("Should throw error from repository")
        } catch {
            XCTAssertTrue(error is HealthDataError)
        }
    }
    
    // MARK: - RequestPermissionsUseCase Tests
    
    func testRequestPermissionsUseCaseSuccess() async throws {
        mockRepository.mockIsAvailable = true
        mockRepository.shouldThrowError = false
        
        let useCase = RequestPermissionsUseCase(repository: mockRepository)
        
        // Should not throw
        try await useCase.execute()
        
        XCTAssertTrue(useCase.isHealthDataAvailable())
    }
    
    func testRequestPermissionsUseCaseHealthDataNotAvailable() async {
        mockRepository.mockIsAvailable = false
        
        let useCase = RequestPermissionsUseCase(repository: mockRepository)
        
        do {
            try await useCase.execute()
            XCTFail("Should throw error when health data not available")
        } catch {
            if case HealthDataError.healthDataNotAvailable = error {
                // Expected error
            } else {
                XCTFail("Wrong error type")
            }
        }
    }
    
    func testRequestPermissionsUseCasePermissionDenied() async {
        mockRepository.mockIsAvailable = true
        mockRepository.shouldThrowError = true
        
        let useCase = RequestPermissionsUseCase(repository: mockRepository)
        
        do {
            try await useCase.execute()
            XCTFail("Should throw error when permissions denied")
        } catch {
            XCTAssertTrue(error is HealthDataError)
        }
    }
    
    // MARK: - ValidateHealthMetricsUseCase Tests
    
    func testValidateHealthMetricsUseCaseAllValid() {
        let metrics = HealthMetrics(
            steps: 10000,
            heartRateVariability: 45.0,
            restingHeartRate: 65.0,
            vo2Max: 42.0,
            sleepDuration: 28800 // 8 hours
        )
        
        let useCase = ValidateHealthMetricsUseCase()
        let result = useCase.execute(metrics)
        
        XCTAssertTrue(result.isValid)
        XCTAssertEqual(result.validMetrics.count, 5)
        XCTAssertTrue(result.invalidMetrics.isEmpty)
    }
    
    func testValidateHealthMetricsUseCaseInvalidValues() {
        let metrics = HealthMetrics(
            steps: -100, // Invalid
            heartRateVariability: 500.0, // Invalid
            restingHeartRate: 65.0, // Valid
            vo2Max: 42.0, // Valid
            sleepDuration: 28800 // Valid
        )
        
        let useCase = ValidateHealthMetricsUseCase()
        let result = useCase.execute(metrics)
        
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.validMetrics.count, 3)
        XCTAssertEqual(result.invalidMetrics.count, 2)
        XCTAssertTrue(result.invalidMetrics.contains("Steps"))
        XCTAssertTrue(result.invalidMetrics.contains("Heart Rate Variability"))
    }
    
    func testValidateHealthMetricsUseCaseWarnings() {
        let metrics = HealthMetrics(
            steps: 500, // Valid but low - should generate warning
            heartRateVariability: 8.0, // Valid but low - should generate warning
            restingHeartRate: 105.0, // Valid but high - should generate warning
            vo2Max: 15.0, // Valid but low - should generate warning
            sleepDuration: 3600 // 1 hour - valid but low - should generate warning
        )
        
        let useCase = ValidateHealthMetricsUseCase()
        let result = useCase.execute(metrics)
        
        XCTAssertTrue(result.isValid) // Should still be valid despite warnings
        XCTAssertEqual(result.validMetrics.count, 5)
        XCTAssertFalse(result.warnings.isEmpty)
        XCTAssertGreaterThan(result.warnings.count, 0)
    }
    
    func testValidateHealthMetricsUseCaseInsufficientData() {
        let metrics = HealthMetrics(
            steps: 10000, // Valid
            heartRateVariability: 45.0 // Valid
            // Missing other metrics - only 2 valid metrics, need 3 for valid result
        )
        
        let useCase = ValidateHealthMetricsUseCase()
        let result = useCase.execute(metrics)
        
        XCTAssertFalse(result.isValid) // Less than 3 valid metrics
        XCTAssertEqual(result.validMetrics.count, 2)
        XCTAssertTrue(result.invalidMetrics.isEmpty)
    }
    
    // MARK: - Mock Use Case Tests
    
    func testMockFetchHealthMetricsUseCase() async throws {
        let mockMetrics = HealthMetrics(steps: 5000)
        let mockUseCase = MockFetchHealthMetricsUseCase(mockResult: .success(mockMetrics))
        
        let result = try await mockUseCase.execute(for: Date())
        XCTAssertEqual(result.steps, 5000)
    }
    
    func testMockFetchHealthMetricsUseCaseError() async {
        let mockUseCase = MockFetchHealthMetricsUseCase(mockResult: .failure(HealthDataError.permissionDenied))
        
        do {
            _ = try await mockUseCase.execute(for: Date())
            XCTFail("Should throw error")
        } catch {
            if case HealthDataError.permissionDenied = error {
                // Expected error
            } else {
                XCTFail("Wrong error type")
            }
        }
    }
    
    func testMockRequestPermissionsUseCase() async throws {
        let mockUseCase = MockRequestPermissionsUseCase(shouldThrowError: false, mockIsAvailable: true)
        
        // Should not throw
        try await mockUseCase.execute()
        XCTAssertTrue(mockUseCase.isHealthDataAvailable())
    }
    
    func testMockRequestPermissionsUseCaseError() async {
        let mockUseCase = MockRequestPermissionsUseCase(shouldThrowError: true)
        
        do {
            try await mockUseCase.execute()
            XCTFail("Should throw error")
        } catch {
            if case HealthDataError.permissionDenied = error {
                // Expected error
            } else {
                XCTFail("Wrong error type")
            }
        }
    }
}
