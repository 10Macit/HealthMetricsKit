//
//  ContentView.swift
//  DemoApp
//
//  Created by Samet Macit on 16/07/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        MainNavigationView()
    }
}

#Preview {
    ContentView()
        .environment(\.viewModelFactory, ViewModelFactory())
}
