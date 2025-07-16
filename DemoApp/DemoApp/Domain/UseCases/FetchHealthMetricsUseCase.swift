import Foundation
import HealthMetricsKit

/// Use case for fetching health metrics for a specific date
/// Encapsulates the business logic for retrieving and validating health data
public protocol FetchHealthMetricsUseCaseProtocol {
    func execute(for date: Date) async throws -> HealthMetrics
}

public final class FetchHealthMetricsUseCase: FetchHealthMetricsUseCaseProtocol {
    private let repository: HealthMetricsRepository
    
    public init(repository: HealthMetricsRepository) {
        self.repository = repository
    }
    
    public func execute(for date: Date) async throws -> HealthMetrics {
        // Business rule: Don't allow fetching data for future dates
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let requestedDate = calendar.startOfDay(for: date)
        
        if requestedDate > today {
            throw HealthDataError.invalidData
        }
        
        // Fetch the metrics from repository
        let metrics = try await repository.fetchHealthMetrics(for: date)
        
        // Business rule: Log when we have incomplete data
        if !metrics.isComplete {
            print("⚠️ Incomplete health metrics for \(date). Available: \(metrics.completedMetricsCount)/5")
        }
        
        return metrics
    }
}

/// Mock implementation for testing
public final class MockFetchHealthMetricsUseCase: FetchHealthMetricsUseCaseProtocol {
    private var mockResult: Result<HealthMetrics, Error>
    
    public init(mockResult: Result<HealthMetrics, Error> = .success(HealthMetrics())) {
        self.mockResult = mockResult
    }
    
    public func setMockResult(_ result: Result<HealthMetrics, Error>) {
        self.mockResult = result
    }
    
    public func execute(for date: Date) async throws -> HealthMetrics {
        // Simulate async delay
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        switch mockResult {
        case .success(let metrics):
            return metrics
        case .failure(let error):
            throw error
        }
    }
}
