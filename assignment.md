# 🎯 Assignment Overview

Create a Swift package named HealthMetricsKit that:
* Queries HealthKit for key daily health metrics:
    - Steps
    - Heart Rate Variability (HRV)
    - Resting Heart Rate (RHR)
    - VO₂Max
    - Sleep duration
* Handles HealthKit permissions.
* Exposes a HealthDataProvider protocol with:
    - A real implementation using live HealthKit data.
    - A mock implementation using static/deterministic values.

# 📱 SwiftUI Demo App

Using your HealthMetricsKit, build a SwiftUI demo app that:
* Displays a simple dashboard summarizing one day’s worth of health
data.
* Uses the mock data provider.
* Focuses on:
    - Clean layout
    - Readable code structure
    - Native iOS UI/UX best practices
    - Good component separation and modularity

# 📦  What to Submit

Please share a GitHub repository (public, or private with access granted) that
includes:
* HealthMetricsKit Swift package
* A SwiftUI demo app using mock data
* A README.md explaining your design, reasoning, and assumptions

You’re welcome to use any tools you’d typically use on the job — including AI code
assistants — but we’re especially interested in your ability to make strong
technical decisions, write clean and understandable code, and align with modern
iOS development patterns.

To help populate your Apple Health app with mock data for the assignment, you can use this helper repo: https://github.com/killerfish/HealthKitInjection
