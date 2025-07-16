import Foundation
import HealthMetricsKit

/// Dependency Injection Container for managing app dependencies
/// Follows the Service Locator pattern for dependency management
public final class DIContainer: ObservableObject {
    
    // MARK: - Configuration
    
    /// Application configuration based on schemes
    public enum Configuration {
        case test
        case dev
        case production
        
        /// Current configuration based on environment variables
        static var current: Configuration {
            if let envConfig = ProcessInfo.processInfo.environment["APP_CONFIGURATION"] {
                switch envConfig {
                case "Test":
                    return .test
                case "Dev":
                    return .dev
                case "Production":
                    return .production
                default:
                    return .test
                }
            }
            
            // Fallback to build configuration
            #if DEBUG
            return .test
            #else
            return .production
            #endif
        }
    }
    
    // MARK: - Singleton
    public static let shared = DIContainer()
    
    // MARK: - Dependencies
    private lazy var healthMetricsRepository: HealthMetricsRepository = {
        let provider: HealthDataProvider
        switch Configuration.current {
        case .test:
            provider = MockHealthDataProvider()
        case .dev:
            provider = MockDataWithInjectionProvider()
        case .production:
            provider = HealthKitDataProvider()
        }
        return DefaultHealthMetricsRepository(healthDataProvider: provider)
    }()
    
    private lazy var fetchHealthMetricsUseCase: FetchHealthMetricsUseCaseProtocol = {
        FetchHealthMetricsUseCase(repository: healthMetricsRepository)
    }()
    
    private lazy var requestPermissionsUseCase: RequestPermissionsUseCaseProtocol = {
        RequestPermissionsUseCase(repository: healthMetricsRepository)
    }()
    
    private lazy var validateHealthMetricsUseCase: ValidateHealthMetricsUseCaseProtocol = {
        ValidateHealthMetricsUseCase()
    }()
    
    private init() {}
    
    // MARK: - Factory Methods
    
    /// Creates a configured HealthDashboardViewModel with all dependencies
    @MainActor
    public func makeHealthDashboardViewModel() -> HealthDashboardViewModel {
        return HealthDashboardViewModel(
            fetchHealthMetricsUseCase: fetchHealthMetricsUseCase,
            requestPermissionsUseCase: requestPermissionsUseCase,
            validateHealthMetricsUseCase: validateHealthMetricsUseCase
        )
    }
    
    /// Returns the RequestPermissionsUseCase for external use
    public func getRequestPermissionsUseCase() -> RequestPermissionsUseCaseProtocol {
        return requestPermissionsUseCase
    }
    
    // MARK: - Configuration Methods
    
    /// Configures the container to use real HealthKit data
    /// Call this when you want to switch from mock to real data
    public func configureForProduction() {
        healthMetricsRepository = DefaultHealthMetricsRepository(
            healthDataProvider: HealthKitDataProvider()
        )
        
        // Recreate use cases with new repository
        invalidateUseCases()
    }
    
    /// Configures the container to use mock data with HealthKit injection
    /// Perfect for dev environment - tests real HealthKit flow with controlled data
    public func configureForDev() {
        healthMetricsRepository = DefaultHealthMetricsRepository(
            healthDataProvider: MockDataWithInjectionProvider()
        )
        
        // Recreate use cases with new repository
        invalidateUseCases()
    }
    
    /// Configures the container to use pure mock data
    /// Useful for testing and unit tests
    public func configureForTesting() {
        healthMetricsRepository = DefaultHealthMetricsRepository(
            healthDataProvider: MockHealthDataProvider()
        )
        
        // Recreate use cases with new repository
        invalidateUseCases()
    }
    
    /// Allows injection of custom dependencies for testing
    public func configureMockDependencies(
        fetchUseCase: FetchHealthMetricsUseCaseProtocol? = nil,
        permissionsUseCase: RequestPermissionsUseCaseProtocol? = nil,
        validateUseCase: ValidateHealthMetricsUseCaseProtocol? = nil
    ) {
        if let fetchUseCase = fetchUseCase {
            self.fetchHealthMetricsUseCase = fetchUseCase
        }
        if let permissionsUseCase = permissionsUseCase {
            self.requestPermissionsUseCase = permissionsUseCase
        }
        if let validateUseCase = validateUseCase {
            self.validateHealthMetricsUseCase = validateUseCase
        }
    }
    
    // MARK: - Private Methods
    
    private func invalidateUseCases() {
        fetchHealthMetricsUseCase = FetchHealthMetricsUseCase(repository: healthMetricsRepository)
        requestPermissionsUseCase = RequestPermissionsUseCase(repository: healthMetricsRepository)
        validateHealthMetricsUseCase = ValidateHealthMetricsUseCase()
    }
}

import SwiftUI
// MARK: - SwiftUI Environment Key

public struct DIContainerKey: EnvironmentKey {
    public static let defaultValue: DIContainer = DIContainer.shared
}

public extension EnvironmentValues {
    var diContainer: DIContainer {
        get { self[DIContainerKey.self] }
        set { self[DIContainerKey.self] = newValue }
    }
}
