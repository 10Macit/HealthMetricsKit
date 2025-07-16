import Foundation
import HealthMetricKits

public protocol HealthMetricsRepository {
    func requestPermissions() async throws
    func fetchHealthMetrics(for date: Date) async throws -> HealthMetrics
    func isHealthDataAvailable() -> Bool
}
