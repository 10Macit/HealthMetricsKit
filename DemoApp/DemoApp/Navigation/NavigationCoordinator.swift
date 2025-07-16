//
//  NavigationCoordinator.swift
//  DemoApp
//
//  Created by Claude on 16/07/2025.
//

import SwiftUI
import HealthMetricKits

/// Navigation destinations in the app
enum NavigationDestination: Hashable {
    case dashboard
    case settings
    case about
}

/// Types of health metrics that can be viewed in detail
enum MetricType: String, CaseIterable, Hashable {
    case steps = "Steps"
    case heartRate = "Heart Rate"
    case heartRateVariability = "Heart Rate Variability"
    case vo2Max = "VO₂ Max"
    case sleep = "Sleep"
    
    var iconName: String {
        switch self {
        case .steps: return "figure.walk"
        case .heartRate: return "heart.fill"
        case .heartRateVariability: return "waveform.path.ecg"
        case .vo2Max: return "lungs.fill"
        case .sleep: return "bed.double.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .steps: return .blue
        case .heartRate: return .red
        case .heartRateVariability: return .green
        case .vo2Max: return .purple
        case .sleep: return .indigo
        }
    }
}

/// NavigationCoordinator manages the navigation state and routing in the app
class NavigationCoordinator: ObservableObject {
    @Published var navigationPath = NavigationPath()
    @Published var selectedTab: Int = 0
    
    // MARK: - Navigation Methods
    
    /// Navigate to a specific destination
    func navigate(to destination: NavigationDestination) {
        navigationPath.append(destination)
    }
    
    /// Navigate back to the previous screen
    func navigateBack() {
        guard !navigationPath.isEmpty else { return }
        navigationPath.removeLast()
    }
    
    /// Navigate to root (clear all navigation)
    func navigateToRoot() {
        guard !navigationPath.isEmpty else { return }
        navigationPath.removeLast(navigationPath.count)
    }
    
    /// Navigate to settings
    func navigateToSettings() {
        navigate(to: .settings)
    }
    
    /// Navigate to about page
    func navigateToAbout() {
        navigate(to: .about)
    }
    
    // MARK: - Tab Management
    
    /// Switch to a specific tab
    func switchToTab(_ index: Int) {
        selectedTab = index
        // Clear navigation stack when switching tabs
        navigateToRoot()
    }
}

// MARK: - Environment Key for NavigationCoordinator

struct NavigationCoordinatorKey: EnvironmentKey {
    static let defaultValue = NavigationCoordinator()
}

extension EnvironmentValues {
    var navigationCoordinator: NavigationCoordinator {
        get { self[NavigationCoordinatorKey.self] }
        set { self[NavigationCoordinatorKey.self] = newValue }
    }
}
