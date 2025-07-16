import Foundation
import SwiftUI

/// Factory for creating ViewModels with proper dependency injection
/// Provides a centralized way to create ViewModels with their dependencies
public final class ViewModelFactory: ObservableObject {
    private let diContainer: DIContainer
    
    public init(diContainer: DIContainer = DIContainer.shared) {
        self.diContainer = diContainer
    }
    
    // MARK: - ViewModel Factory Methods
    
    /// Creates a HealthDashboardViewModel with injected dependencies
    @MainActor
    public func makeHealthDashboardViewModel() -> HealthDashboardViewModel {
        return diContainer.makeHealthDashboardViewModel()
    }
    
    // MARK: - Configuration
    
    /// Configures the factory for production environment
    public func configureForProduction() {
        diContainer.configureForProduction()
    }
    
    /// Configures the factory for dev environment
    /// Uses MockDataWithInjectionProvider for realistic HealthKit testing
    public func configureForDev() {
        diContainer.configureForDev()
    }
    
    /// Configures the factory for testing environment
    public func configureForTesting() {
        diContainer.configureForTesting()
    }
}

// MARK: - SwiftUI Environment Key for ViewModelFactory

public struct ViewModelFactoryKey: EnvironmentKey {
    public static let defaultValue: ViewModelFactory = ViewModelFactory()
}

public extension EnvironmentValues {
    var viewModelFactory: ViewModelFactory {
        get { self[ViewModelFactoryKey.self] }
        set { self[ViewModelFactoryKey.self] = newValue }
    }
}