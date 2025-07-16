import Foundation
import HealthMetricsKit

public protocol HealthMetricsRepository {
    func requestPermissions() async throws
    func fetchHealthMetrics(for date: Date) async throws -> HealthMetrics
    func isHealthDataAvailable() -> Bool
}
