import Foundation
import Combine
import HealthMetricsKit

@MainActor
public final class HealthDashboardViewModel: ObservableObject {
    @Published var healthMetrics: HealthMetrics?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedDate = Date()
    @Published var validationResult: HealthMetricsValidationResult?
    
    // Use Cases - encapsulate business logic
    private let fetchHealthMetricsUseCase: FetchHealthMetricsUseCaseProtocol
    private let requestPermissionsUseCase: RequestPermissionsUseCaseProtocol
    private let validateHealthMetricsUseCase: ValidateHealthMetricsUseCaseProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        fetchHealthMetricsUseCase: FetchHealthMetricsUseCaseProtocol? = nil,
        requestPermissionsUseCase: RequestPermissionsUseCaseProtocol? = nil,
        validateHealthMetricsUseCase: ValidateHealthMetricsUseCaseProtocol? = nil
    ) {
        // Default to production implementations if none provided
        let repository = DefaultHealthMetricsRepository()
        self.fetchHealthMetricsUseCase = fetchHealthMetricsUseCase ?? FetchHealthMetricsUseCase(repository: repository)
        self.requestPermissionsUseCase = requestPermissionsUseCase ?? RequestPermissionsUseCase(repository: repository)
        self.validateHealthMetricsUseCase = validateHealthMetricsUseCase ?? ValidateHealthMetricsUseCase()
        
        setupObservers()
    }
    
    private func setupObservers() {
        $selectedDate
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] date in
                Task {
                    print("date changed")
                    await self?.fetchHealthMetrics(for: date)
                }
            }
            .store(in: &cancellables)
    }
    
    func fetchHealthMetrics(for date: Date = Date()) async {
        isLoading = true
        errorMessage = nil
        validationResult = nil
        
        // Start timing for minimum loading duration
        let startTime = Date()
        
        do {
            // Use the fetch use case instead of direct repository access
            let metrics = try await fetchHealthMetricsUseCase.execute(for: date)
            healthMetrics = metrics
            
            // Validate the fetched metrics using the validation use case
            validationResult = validateHealthMetricsUseCase.execute(metrics)
            
            // Log warnings if any
            if let warnings = validationResult?.warnings, !warnings.isEmpty {
                print("⚠️ Health metrics warnings: \(warnings.joined(separator: ", "))")
            }
            
        } catch {
            errorMessage = error.localizedDescription
            healthMetrics = nil
            validationResult = nil
        }
        
        // Ensure minimum loading duration for smooth skeleton effect
        let elapsedTime = Date().timeIntervalSince(startTime)
        let minimumLoadingDuration: TimeInterval = 0.8 // 800ms
        
        if elapsedTime < minimumLoadingDuration {
            let remainingTime = minimumLoadingDuration - elapsedTime
            try? await Task.sleep(nanoseconds: UInt64(remainingTime * 1_000_000_000))
        }
        
        isLoading = false
    }
    
    func requestPermissions() async {
        do {
            // Use the permissions use case instead of direct repository access
            try await requestPermissionsUseCase.execute()
            await fetchHealthMetrics()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func retryFetch() async {
        await fetchHealthMetrics(for: selectedDate)
    }
    
    // MARK: - Computed Properties
    
    var formattedSleepDuration: String {
        guard let sleepDuration = healthMetrics?.sleepDuration else { return "N/A" }
        return HealthMetricsFormatter.formatSleepDuration(sleepDuration)
    }
    
    var formattedDate: String {
        return HealthMetricsFormatter.formatDate(selectedDate)
    }
    
    var isHealthDataAvailable: Bool {
        return requestPermissionsUseCase.isHealthDataAvailable()
    }
    
    var hasValidationWarnings: Bool {
        return validationResult?.warnings.isEmpty == false
    }
    
    var validationWarnings: [String] {
        return validationResult?.warnings ?? []
    }
    
    var metricsCompletionPercentage: Double {
        guard let metrics = healthMetrics else { return 0.0 }
        return Double(metrics.completedMetricsCount) / 5.0
    }
}
