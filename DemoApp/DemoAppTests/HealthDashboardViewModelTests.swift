import XCTest
import Combine
@testable import DemoApp
@testable import HealthMetricsKit

@MainActor
final class HealthDashboardViewModelTests: XCTestCase {
    
    private var mockFetchUseCase: MockFetchHealthMetricsUseCase!
    private var mockPermissionsUseCase: MockRequestPermissionsUseCase!
    private var mockValidationUseCase: ValidateHealthMetricsUseCase!
    private var viewModel: HealthDashboardViewModel!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockFetchUseCase = MockFetchHealthMetricsUseCase()
        mockPermissionsUseCase = MockRequestPermissionsUseCase()
        mockValidationUseCase = ValidateHealthMetricsUseCase()
        
        viewModel = HealthDashboardViewModel(
            fetchHealthMetricsUseCase: mockFetchUseCase,
            requestPermissionsUseCase: mockPermissionsUseCase,
            validateHealthMetricsUseCase: mockValidationUseCase
        )
        
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        cancellables = nil
        viewModel = nil
        mockValidationUseCase = nil
        mockPermissionsUseCase = nil
        mockFetchUseCase = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertNil(viewModel.healthMetrics)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertNotNil(viewModel.selectedDate)
    }
    
    func testFetchHealthMetricsSuccess() async {
        let testMetrics = HealthMetrics(
            steps: 10000,
            heartRateVariability: 45.0,
            restingHeartRate: 65.0,
            vo2Max: 42.0,
            sleepDuration: 28800
        )
        
        mockFetchUseCase.setMockResult(.success(testMetrics))
        
        await viewModel.fetchHealthMetrics()
        
        XCTAssertEqual(viewModel.healthMetrics?.steps, 10000)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertNotNil(viewModel.validationResult)
        XCTAssertTrue(viewModel.validationResult?.isValid == true)
    }
    
    func testFetchHealthMetricsFailure() async {
        mockFetchUseCase.setMockResult(.failure(HealthDataError.permissionDenied))
        
        await viewModel.fetchHealthMetrics()
        
        XCTAssertNil(viewModel.healthMetrics)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertNil(viewModel.validationResult)
    }
    
    func testLoadingState() async {
        let testMetrics = HealthMetrics(steps: 5000)
        mockFetchUseCase.setMockResult(.success(testMetrics))
        
        let task = Task {
            await viewModel.fetchHealthMetrics()
        }
        
        // Check loading state is active during fetch
        try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds
        XCTAssertTrue(viewModel.isLoading)
        
        await task.value
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testFormattedSleepDuration() {
        let metrics = HealthMetrics(sleepDuration: 28800) // 8 hours
        viewModel.healthMetrics = metrics
        
        XCTAssertEqual(viewModel.formattedSleepDuration, "8h 0m")
    }
    
    func testFormattedSleepDurationWithMinutes() {
        let metrics = HealthMetrics(sleepDuration: 27900) // 7 hours 45 minutes
        viewModel.healthMetrics = metrics
        
        XCTAssertEqual(viewModel.formattedSleepDuration, "7h 45m")
    }
    
    func testFormattedSleepDurationNil() {
        let metrics = HealthMetrics()
        viewModel.healthMetrics = metrics
        
        XCTAssertEqual(viewModel.formattedSleepDuration, "N/A")
    }
    
    func testRequestPermissions() async {
        let testMetrics = HealthMetrics(steps: 5000)
        mockPermissionsUseCase.setShouldThrowError(false)
        mockFetchUseCase.setMockResult(.success(testMetrics))
        
        await viewModel.requestPermissions()
        
        XCTAssertNotNil(viewModel.healthMetrics)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testRequestPermissionsFailure() async {
        mockPermissionsUseCase.setShouldThrowError(true)
        
        await viewModel.requestPermissions()
        
        XCTAssertNotNil(viewModel.errorMessage)
    }
    
    func testIsHealthDataAvailable() {
        mockPermissionsUseCase.setMockIsAvailable(true)
        XCTAssertTrue(viewModel.isHealthDataAvailable)
        
        mockPermissionsUseCase.setMockIsAvailable(false)
        XCTAssertFalse(viewModel.isHealthDataAvailable)
    }
    
    func testRetryFetch() async {
        mockFetchUseCase.setMockResult(.failure(HealthDataError.permissionDenied))
        await viewModel.fetchHealthMetrics()
        XCTAssertNotNil(viewModel.errorMessage)
        
        let successMetrics = HealthMetrics(steps: 8000)
        mockFetchUseCase.setMockResult(.success(successMetrics))
        
        await viewModel.retryFetch()
        
        XCTAssertNotNil(viewModel.healthMetrics)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    // MARK: - Dependency Injection Benefits
    
    func testEasyScenarioTesting() async {
        // Demonstrate how DI makes it trivial to test different scenarios
        
        // Test empty data scenario
        let emptyMetrics = HealthMetrics()
        mockFetchUseCase.setMockResult(.success(emptyMetrics))
        
        await viewModel.fetchHealthMetrics()
        
        XCTAssertEqual(viewModel.metricsCompletionPercentage, 0.0)
        XCTAssertFalse(viewModel.hasValidationWarnings)
        
        // Test partial data scenario
        let partialMetrics = HealthMetrics(steps: 5000, heartRateVariability: 30.0)
        mockFetchUseCase.setMockResult(.success(partialMetrics))
        
        await viewModel.fetchHealthMetrics()
        
        XCTAssertEqual(viewModel.metricsCompletionPercentage, 0.4) // 2 out of 5
        
        // Test complete data scenario
        let completeMetrics = HealthMetrics(
            steps: 10000,
            heartRateVariability: 45.0,
            restingHeartRate: 65.0,
            vo2Max: 42.0,
            sleepDuration: 28800
        )
        mockFetchUseCase.setMockResult(.success(completeMetrics))
        
        await viewModel.fetchHealthMetrics()
        
        XCTAssertEqual(viewModel.metricsCompletionPercentage, 1.0) // All 5 metrics
    }
    
    func testPermissionScenarios() async {
        // Test permission denied scenario
        mockPermissionsUseCase.setShouldThrowError(true)
        mockPermissionsUseCase.setMockIsAvailable(false)
        
        XCTAssertFalse(viewModel.isHealthDataAvailable)
        
        await viewModel.requestPermissions()
        XCTAssertNotNil(viewModel.errorMessage)
        
        // Test permission granted scenario
        mockPermissionsUseCase.setShouldThrowError(false)
        mockPermissionsUseCase.setMockIsAvailable(true)
        mockFetchUseCase.setMockResult(.success(HealthMetrics(steps: 8000)))
        
        await viewModel.requestPermissions()
        XCTAssertTrue(viewModel.isHealthDataAvailable)
        XCTAssertNotNil(viewModel.healthMetrics)
    }
    
    // MARK: - New Tests for Use Case Architecture
    
    func testValidationWarnings() async {
        let metricsWithWarnings = HealthMetrics(
            steps: 500, // Low step count - should generate warning
            heartRateVariability: 45.0,
            restingHeartRate: 65.0,
            vo2Max: 42.0,
            sleepDuration: 28800
        )
        
        mockFetchUseCase.setMockResult(.success(metricsWithWarnings))
        
        await viewModel.fetchHealthMetrics()
        
        XCTAssertTrue(viewModel.hasValidationWarnings)
        XCTAssertFalse(viewModel.validationWarnings.isEmpty)
    }
    
    func testMetricsCompletionPercentage() {
        let partialMetrics = HealthMetrics(
            steps: 10000,
            heartRateVariability: 45.0
            // Missing 3 other metrics
        )
        
        viewModel.healthMetrics = partialMetrics
        
        XCTAssertEqual(viewModel.metricsCompletionPercentage, 0.4, accuracy: 0.01) // 2/5 = 0.4
    }
    
    func testFormattedPropertiesUseUtilities() {
        let metrics = HealthMetrics(sleepDuration: 27000) // 7.5 hours
        viewModel.healthMetrics = metrics
        
        // Test that formatted properties use the utility formatter
        let formattedSleep = viewModel.formattedSleepDuration
        let expectedSleep = HealthMetricsFormatter.formatSleepDuration(27000)
        
        XCTAssertEqual(formattedSleep, expectedSleep)
        
        let formattedDate = viewModel.formattedDate
        let expectedDate = HealthMetricsFormatter.formatDate(viewModel.selectedDate)
        
        XCTAssertEqual(formattedDate, expectedDate)
    }
    
    func testSelectedDateChanges() {
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        
        // Initially should be today
        XCTAssertEqual(Calendar.current.isDate(viewModel.selectedDate, inSameDayAs: today), true)
        
        // Change to yesterday
        viewModel.selectedDate = yesterday
        XCTAssertEqual(Calendar.current.isDate(viewModel.selectedDate, inSameDayAs: yesterday), true)
        
        // Verify formatted date reflects the change
        let expectedYesterdayFormat = HealthMetricsFormatter.formatDate(yesterday)
        XCTAssertEqual(viewModel.formattedDate, expectedYesterdayFormat)
    }
}

// MARK: - Mock Repository

class MockHealthMetricsRepository: HealthMetricsRepository {
    var mockMetrics: HealthMetrics?
    var shouldThrowError = false
    var mockIsAvailable = true
    var delay: TimeInterval = 0
    
    func requestPermissions() async throws {
        if delay > 0 {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        
        if shouldThrowError {
            throw HealthDataError.permissionDenied
        }
    }
    
    func fetchHealthMetrics(for date: Date) async throws -> HealthMetrics {
        if delay > 0 {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        
        if shouldThrowError {
            throw HealthDataError.dataFetchFailed(NSError(domain: "test", code: 1))
        }
        
        return mockMetrics ?? HealthMetrics(date: date)
    }
    
    func isHealthDataAvailable() -> Bool {
        return mockIsAvailable
    }
}
