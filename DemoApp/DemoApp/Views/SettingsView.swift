//
//  SettingsView.swift
//  DemoApp
//
//  Created by Claude on 16/07/2025.
//

import SwiftUI

/// Settings view for app configuration and information
struct SettingsView: View {
    @Environment(\.navigationCoordinator) private var navigationCoordinator

    var body: some View {
        List {

            // App Information Section
            Section("App Information") {
                NavigationLink(destination: AboutView()) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                        Text("About")
                    }
                }
                
                HStack {
                    Image(systemName: "number.circle.fill")
                        .foregroundColor(.green)
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Image(systemName: "hammer.fill")
                        .foregroundColor(.orange)
                    Text("Build")
                    Spacer()
                    Text("1")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)

    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environment(\.viewModelFactory, ViewModelFactory())
    .environment(\.navigationCoordinator, NavigationCoordinator())
}
