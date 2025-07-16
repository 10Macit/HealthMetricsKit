import SwiftUI
import Combine
import HealthMetricsKit

/// Testable Health Dashboard View that accepts an injected ViewModel
/// This view is designed for dependency injection and testing
struct HealthDashboardView: View {
    @ObservedObject private var viewModel: HealthDashboardViewModel
    
    // MARK: - Initialization
    
    /// Initializer that accepts a ViewModel - perfect for testing and DI
    init(viewModel: HealthDashboardViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    headerSection
                    
                    if viewModel.isLoading {
                        LoadingView()
                            .frame(maxWidth: .infinity, minHeight: 200)
                    } else if let errorMessage = viewModel.errorMessage {
                        ErrorView(message: errorMessage) {
                            await viewModel.retryFetch()
                        }
                    } else if let metrics = viewModel.healthMetrics {
                        healthMetricsGrid(metrics)
                        
                        if viewModel.hasValidationWarnings {
                            validationWarningsSection
                        }
                    } else {
                        emptyStateView
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Health Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await viewModel.fetchHealthMetrics(for: viewModel.selectedDate)
            }
        }
        .task {
            await viewModel.fetchHealthMetrics()
        }
        .onReceive(NotificationCenter.default.publisher(for: .healthKitPermissionsGranted)) { _ in
            Task {
                await viewModel.fetchHealthMetrics()
            }
        }
    }
    
    private var headerTitle: String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let selectedDay = calendar.startOfDay(for: viewModel.selectedDate)
        
        if selectedDay == today {
            return "Today's Metrics"
        } else {
            return "Metrics for \(viewModel.formattedDate)"
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(headerTitle)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                DatePicker("Select Date", selection: $viewModel.selectedDate, in: ...Date(), displayedComponents: .date)
                    .labelsHidden()
                    .accentColor(.blue)
            }
            
            Text(viewModel.formattedDate)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 4)
    }
    
    private func healthMetricsGrid(_ metrics: HealthMetrics) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
            HealthMetricCard(
                title: "Steps",
                value: metrics.steps?.formatted() ?? "N/A",
                unit: "steps",
                icon: "figure.walk",
                color: .blue
            )
            
            HealthMetricCard(
                title: "Resting Heart Rate",
                value: metrics.restingHeartRate?.formatted(.number.precision(.fractionLength(0))) ?? "N/A",
                unit: "bpm",
                icon: "heart.fill",
                color: .red
            )
            
            HealthMetricCard(
                title: "Heart Rate Variability",
                value: metrics.heartRateVariability?.formatted(.number.precision(.fractionLength(1))) ?? "N/A",
                unit: "ms",
                icon: "waveform.path.ecg",
                color: .green
            )
            
            HealthMetricCard(
                title: "VO₂ Max",
                value: metrics.vo2Max?.formatted(.number.precision(.fractionLength(1))) ?? "N/A",
                unit: "ml/kg/min",
                icon: "lungs.fill",
                color: .purple
            )
            
            HealthMetricCard(
                title: "Sleep Duration",
                value: viewModel.formattedSleepDuration,
                unit: "",
                icon: "bed.double.fill",
                color: .indigo
            )
        }
    }
    
    private var validationWarningsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                Text("Health Insights")
                    .font(.headline)
                    .foregroundColor(.orange)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(viewModel.validationWarnings, id: \.self) { warning in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                            .font(.caption)
                        
                        Text(warning)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.text.square")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("No Health Data")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Pull to refresh or select a different date to load health metrics.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }
}

#Preview {
    let mockFetchUseCase = MockFetchHealthMetricsUseCase(
        mockResult: .success(HealthMetrics(
            steps: 12500,
            heartRateVariability: 45.2,
            restingHeartRate: 68.0,
            vo2Max: 42.8,
            sleepDuration: 27000
        ))
    )
    
    let mockPermissionsUseCase = MockRequestPermissionsUseCase()
    let validateUseCase = ValidateHealthMetricsUseCase()
    
    let viewModel = HealthDashboardViewModel(
        fetchHealthMetricsUseCase: mockFetchUseCase,
        requestPermissionsUseCase: mockPermissionsUseCase,
        validateHealthMetricsUseCase: validateUseCase
    )
    
    HealthDashboardView(viewModel: viewModel)
}
