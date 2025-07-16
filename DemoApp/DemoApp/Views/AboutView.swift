//
//  AboutView.swift
//  DemoApp
//
//  Created by Claude on 16/07/2025.
//

import SwiftUI

/// About view displaying app information and credits
struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.red)
                    
                    Text("HealthMetricKits")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Demo Application")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                // Description
                VStack(alignment: .leading, spacing: 12) {
                    Text("About This App")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("This is a demonstration application showcasing the HealthMetricKits Swift package. The app provides a comprehensive view of your health metrics including steps, heart rate, heart rate variability, VO₂ Max, and sleep data.")
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Text("The app uses Apple's HealthKit framework to securely access your health data with your permission.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                // Features
                VStack(alignment: .leading, spacing: 12) {
                    Text("Features")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    FeatureRow(icon: "heart.text.square", title: "Health Dashboard", description: "View all your health metrics in one place")
                    FeatureRow(icon: "chart.bar", title: "Detailed Metrics", description: "Get comprehensive information about each metric")
                    FeatureRow(icon: "calendar", title: "Date Selection", description: "View metrics for any date")
                    FeatureRow(icon: "exclamationmark.triangle", title: "Health Insights", description: "Receive validation warnings and health tips")
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                // Version Info
                VStack(alignment: .leading, spacing: 12) {
                    Text("Version Information")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    InfoRow(label: "Version", value: "1.0.0")
                    InfoRow(label: "Build", value: "1")
                    InfoRow(label: "iOS Version", value: "18.5+")
                    InfoRow(label: "Swift Version", value: "5.0")
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                // Credits
                VStack(alignment: .leading, spacing: 12) {
                    Text("Credits")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Built with SwiftUI and HealthKit")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Text("Icons by Apple SF Symbols")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Helper Views

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.title2)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}