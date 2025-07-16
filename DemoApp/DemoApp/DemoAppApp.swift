//
//  DemoAppApp.swift
//  DemoApp
//
//  Created by Samet Macit on 16/07/2025.
//

import SwiftUI

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
        // Configure for development with mock data
        // In a real app, you might check for debug/release builds
        #if DEBUG
        viewModelFactory.configureForTesting()
        #else
        viewModelFactory.configureForProduction()
        #endif
    }
}
