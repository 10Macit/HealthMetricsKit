//
//  DefaultHealthMetricsRepository.swift
//  DemoApp
//
//  Created by Samet Macit on 16/07/2025.
//

import Foundation
import HealthMetricsKit

final class DefaultHealthMetricsRepository: HealthMetricsRepository {
    private let healthDataProvider: HealthDataProvider
    
    init(healthDataProvider: HealthDataProvider = MockHealthDataProvider()) {
        self.healthDataProvider = healthDataProvider
    }
    
    func requestPermissions() async throws {
        try await healthDataProvider.requestPermissions()
    }
    
    func fetchHealthMetrics(for date: Date) async throws -> HealthMetrics {
        try await healthDataProvider.fetchHealthMetrics(for: date)
    }
    
    func isHealthDataAvailable() -> Bool {
        healthDataProvider.isHealthDataAvailable()
    }
}
