//
//  MetricsListView.swift
//  DemoApp
//
//  Created by Claude on 16/07/2025.
//

import SwiftUI

/// View that displays a list of all available health metrics
struct MetricsListView: View {
    var body: some View {
        Text("Hello World")
            .navigationTitle("Health Metrics")
            .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        MetricsListView()
    }
}
