import XCTest
import SwiftUI
@testable import DemoApp
@testable import HealthMetricKits

@MainActor
final class DependencyInjectionTests: XCTestCase {
    
    // MARK: - DIContainer Tests
    
    func testDIContainerSingleton() {
        let container1 = DIContainer.shared
        let container2 = DIContainer.shared
        
        XCTAssertTrue(container1 === container2, "DIContainer should be a singleton")
    }
    
    func testDIContainerMakeHealthDashboardViewModel() {
        let container = DIContainer.shared
        let viewModel = container.makeHealthDashboardViewModel()
        
        XCTAssertNotNil(viewModel)
        XCTAssertTrue(viewModel.isHealthDataAvailable)
    }
    
    func testDIContainerConfigureForTesting() {
        let container = DIContainer.shared
        container.configureForTesting()
        
        let viewModel = container.makeHealthDashboardViewModel()
        XCTAssertNotNil(viewModel)
        XCTAssertTrue(viewModel.isHealthDataAvailable)
    }
    
    func testDIContainerConfigureForProduction() {
        let container = DIContainer.shared
        container.configureForProduction()
        
        let viewModel = container.makeHealthDashboardViewModel()
        XCTAssertNotNil(viewModel)
    }
    
    func testDIContainerMockDependencies() {
        let container = DIContainer.shared
        let mockFetchUseCase = MockFetchHealthMetricsUseCase()
        let mockPermissionsUseCase = MockRequestPermissionsUseCase()
        let mockValidateUseCase = ValidateHealthMetricsUseCase()
        
        container.configureMockDependencies(
            fetchUseCase: mockFetchUseCase,
            permissionsUseCase: mockPermissionsUseCase,
            validateUseCase: mockValidateUseCase
        )
        
        let viewModel = container.makeHealthDashboardViewModel()
        XCTAssertNotNil(viewModel)
    }
    
    // MARK: - ViewModelFactory Tests
    
    func testViewModelFactoryInitialization() {
        let factory = ViewModelFactory()
        XCTAssertNotNil(factory)
    }
    
    func testViewModelFactoryMakeHealthDashboardViewModel() {
        let factory = ViewModelFactory()
        let viewModel = factory.makeHealthDashboardViewModel()
        
        XCTAssertNotNil(viewModel)
    }
    
    func testViewModelFactoryConfigureForTesting() {
        let factory = ViewModelFactory()
        factory.configureForTesting()
        
        let viewModel = factory.makeHealthDashboardViewModel()
        XCTAssertNotNil(viewModel)
        XCTAssertTrue(viewModel.isHealthDataAvailable)
    }
    
    func testViewModelFactoryConfigureForProduction() {
        let factory = ViewModelFactory()
        factory.configureForProduction()
        
        let viewModel = factory.makeHealthDashboardViewModel()
        XCTAssertNotNil(viewModel)
    }
    
    // MARK: - HealthDashboardView with Dependency Injection Tests
    
    func testHealthDashboardViewWithInjectedViewModel() async {
        let mockFetchUseCase = MockFetchHealthMetricsUseCase(
            mockResult: .success(HealthMetrics(
                steps: 10000,
                heartRateVariability: 45.0,
                restingHeartRate: 65.0,
                vo2Max: 42.0,
                sleepDuration: 28800
            ))
        )
        
        let mockPermissionsUseCase = MockRequestPermissionsUseCase()
        let validateUseCase = ValidateHealthMetricsUseCase()
        
        let viewModel = HealthDashboardViewModel(
            fetchHealthMetricsUseCase: mockFetchUseCase,
            requestPermissionsUseCase: mockPermissionsUseCase,
            validateHealthMetricsUseCase: validateUseCase
        )
        
        let view = HealthDashboardView(viewModel: viewModel)
        XCTAssertNotNil(view)
        
        // Test that the ViewModel is properly injected
        await viewModel.fetchHealthMetrics()
        XCTAssertNotNil(viewModel.healthMetrics)
        XCTAssertEqual(viewModel.healthMetrics?.steps, 10000)
    }
    
    func testHealthDashboardViewTestability() async {
        // Demonstrate how easy it is to test with different scenarios
        
        // Scenario 1: Error state
        let errorFetchUseCase = MockFetchHealthMetricsUseCase(
            mockResult: .failure(HealthDataError.permissionDenied)
        )
        
        let errorViewModel = HealthDashboardViewModel(
            fetchHealthMetricsUseCase: errorFetchUseCase,
            requestPermissionsUseCase: MockRequestPermissionsUseCase(),
            validateHealthMetricsUseCase: ValidateHealthMetricsUseCase()
        )
        
        await errorViewModel.fetchHealthMetrics()
        XCTAssertNotNil(errorViewModel.errorMessage)
        XCTAssertNil(errorViewModel.healthMetrics)
        
        // Scenario 2: Success state with warnings
        let warningMetrics = HealthMetrics(
            steps: 500, // Low step count should generate warning
            heartRateVariability: 45.0,
            restingHeartRate: 65.0,
            vo2Max: 42.0,
            sleepDuration: 28800
        )
        
        let warningFetchUseCase = MockFetchHealthMetricsUseCase(
            mockResult: .success(warningMetrics)
        )
        
        let warningViewModel = HealthDashboardViewModel(
            fetchHealthMetricsUseCase: warningFetchUseCase,
            requestPermissionsUseCase: MockRequestPermissionsUseCase(),
            validateHealthMetricsUseCase: ValidateHealthMetricsUseCase()
        )
        
        await warningViewModel.fetchHealthMetrics()
        XCTAssertNotNil(warningViewModel.healthMetrics)
        XCTAssertTrue(warningViewModel.hasValidationWarnings)
        XCTAssertFalse(warningViewModel.validationWarnings.isEmpty)
    }
    
    // MARK: - Integration Tests
    
    func testEndToEndDependencyInjection() async {
        // Test the complete flow from DIContainer to ViewModel to View
        let container = DIContainer.shared
        container.configureForTesting()
        
        let factory = ViewModelFactory(diContainer: container)
        let viewModel = factory.makeHealthDashboardViewModel()
        let view = HealthDashboardView(viewModel: viewModel)
        
        XCTAssertNotNil(view)
        
        // Test that everything works together
        await viewModel.fetchHealthMetrics()
        XCTAssertNotNil(viewModel.healthMetrics)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testCustomDependencyConfiguration() async {
        // Test injecting completely custom dependencies
        let customMetrics = HealthMetrics(
            steps: 99999,
            heartRateVariability: 123.45,
            restingHeartRate: 50.0,
            vo2Max: 60.0,
            sleepDuration: 32400 // 9 hours
        )
        
        let customFetchUseCase = MockFetchHealthMetricsUseCase(
            mockResult: .success(customMetrics)
        )
        
        let customPermissionsUseCase = MockRequestPermissionsUseCase(
            shouldThrowError: false,
            mockIsAvailable: true
        )
        
        let container = DIContainer.shared
        container.configureMockDependencies(
            fetchUseCase: customFetchUseCase,
            permissionsUseCase: customPermissionsUseCase,
            validateUseCase: ValidateHealthMetricsUseCase()
        )
        
        let viewModel = container.makeHealthDashboardViewModel()
        await viewModel.fetchHealthMetrics()
        
        XCTAssertEqual(viewModel.healthMetrics?.steps, 99999)
        XCTAssertEqual(viewModel.healthMetrics?.heartRateVariability, 123.45)
        XCTAssertTrue(viewModel.isHealthDataAvailable)
    }
}