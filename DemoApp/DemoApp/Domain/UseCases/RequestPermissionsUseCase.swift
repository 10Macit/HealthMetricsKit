import Foundation
import HealthMetricKits

/// Use case for requesting health data permissions
/// Encapsulates the business logic for permission management and validation
public protocol RequestPermissionsUseCaseProtocol {
    func execute() async throws
    func isHealthDataAvailable() -> Bool
}

public final class RequestPermissionsUseCase: RequestPermissionsUseCaseProtocol {
    private let repository: HealthMetricsRepository
    
    public init(repository: HealthMetricsRepository) {
        self.repository = repository
    }
    
    public func execute() async throws {
        // Business rule: Check if health data is available before requesting permissions
        guard isHealthDataAvailable() else {
            throw HealthDataError.healthDataNotAvailable
        }
        
        // Request permissions through repository
        try await repository.requestPermissions()
        
        // Business rule: Log successful permission grant
        print("✅ Health data permissions granted successfully")
    }
    
    public func isHealthDataAvailable() -> Bool {
        return repository.isHealthDataAvailable()
    }
}

/// Mock implementation for testing
public final class MockRequestPermissionsUseCase: RequestPermissionsUseCaseProtocol {
    private var shouldThrowError: Bool
    private var mockIsAvailable: Bool
    
    public init(shouldThrowError: Bool = false, mockIsAvailable: Bool = true) {
        self.shouldThrowError = shouldThrowError
        self.mockIsAvailable = mockIsAvailable
    }
    
    public func setShouldThrowError(_ shouldThrow: Bool) {
        self.shouldThrowError = shouldThrow
    }
    
    public func setMockIsAvailable(_ isAvailable: Bool) {
        self.mockIsAvailable = isAvailable
    }
    
    public func execute() async throws {
        // Simulate async delay
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        if shouldThrowError {
            throw HealthDataError.permissionDenied
        }
        
        // Mock successful execution
    }
    
    public func isHealthDataAvailable() -> Bool {
        return mockIsAvailable
    }
}