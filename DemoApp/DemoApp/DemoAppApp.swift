//
//  DemoAppApp.swift
//  DemoApp
//
//  Created by Samet Macit on 16/07/2025.
//

import SwiftUI
import HealthMetricKits

@main
struct DemoAppApp: App {
    // MARK: - Dependency Injection Setup
    
    @StateObject private var viewModelFactory = ViewModelFactory()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.viewModelFactory, viewModelFactory)
                .onAppear {
                    setupDependencies()
                }
        }
    }
    
    // MARK: - Configuration
    
    private func setupDependencies() {
        switch DIContainer.Configuration.current {
        case .development:
            viewModelFactory.configureForTesting()
        case .staging:
            viewModelFactory.configureForStaging()
            Task {
                await requestHealthKitPermissions()
            }
        case .production:
            viewModelFactory.configureForProduction()
            Task {
                await requestHealthKitPermissions()
            }
        }
    }
    
    /// Requests HealthKit permissions for production builds
    @MainActor
    private func requestHealthKitPermissions() async {
        do {
            let permissionsUseCase = DIContainer.shared.getRequestPermissionsUseCase()
            try await permissionsUseCase.execute()
            
            // Notify that permissions were granted successfully
            NotificationCenter.default.post(name: .healthKitPermissionsGranted, object: nil)
        } catch {
            print("Failed to request HealthKit permissions: \(error)")
        }
    }
}
