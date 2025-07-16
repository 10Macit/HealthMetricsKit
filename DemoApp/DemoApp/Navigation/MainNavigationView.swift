//
//  MainNavigationView.swift
//  DemoApp
//
//  Created by Claude on 16/07/2025.
//

import SwiftUI

/// Main navigation view that handles routing between different screens
struct MainNavigationView: View {
    @StateObject private var navigationCoordinator = NavigationCoordinator()
    @Environment(\.viewModelFactory) private var viewModelFactory
    
    var body: some View {
        TabView(selection: $navigationCoordinator.selectedTab) {
            // Dashboard Tab
            dashboardTab
                .tabItem {
                    Label("Dashboard", systemImage: "heart.text.square")
                }
                .tag(0)
            
            // Metrics Tab
            metricsTab
                .tabItem {
                    Label("Metrics", systemImage: "chart.bar")
                }
                .tag(1)
            
            // Settings Tab
            settingsTab
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
        .environment(\.navigationCoordinator, navigationCoordinator)
    }
    
    // MARK: - Tab Views
    
    private var dashboardTab: some View {
        NavigationStack(path: $navigationCoordinator.navigationPath) {
            HealthDashboardView(
                viewModel: viewModelFactory.makeHealthDashboardViewModel()
            )
                .navigationDestination(for: NavigationDestination.self) { destination in
                    destinationView(for: destination)
                }
        }
    }
    
    private var metricsTab: some View {
        NavigationStack(path: $navigationCoordinator.navigationPath) {
            MetricsListView()
                .navigationDestination(for: NavigationDestination.self) { destination in
                    destinationView(for: destination)
                }
        }
    }
    
    private var settingsTab: some View {
        NavigationStack(path: $navigationCoordinator.navigationPath) {
            SettingsView()
                .navigationDestination(for: NavigationDestination.self) { destination in
                    destinationView(for: destination)
                }
        }
    }
    
    // MARK: - Destination Views
    
    @ViewBuilder
    private func destinationView(for destination: NavigationDestination) -> some View {
        switch destination {
        case .dashboard:
            HealthDashboardView(
                viewModel: viewModelFactory.makeHealthDashboardViewModel()
            )
        case .settings:
            SettingsView()
            
        case .about:
            AboutView()
        }
    }
}

#Preview {
    MainNavigationView()
        .environment(\.viewModelFactory, ViewModelFactory())
}
