# HealthMetricKits

A comprehensive Swift package for accessing HealthKit data with a clean architecture demo application.

## 📋 Overview

HealthMetricKits provides a robust, protocol-oriented solution for querying key health metrics from HealthKit. The package includes both live HealthKit integration and mock data providers, making it perfect for development, testing, and production use.

### Key Features

- 🏥 **Complete HealthKit Integration**: Access steps, HRV, resting heart rate, VO₂Max, and sleep data
- 🎭 **Mock Data Provider**: Deterministic mock data for consistent testing and development
- 🔒 **Permission Management**: Proper HealthKit authorization handling
- 🏗️ **Clean Architecture**: Protocol-oriented design with comprehensive dependency injection
- 📱 **SwiftUI Demo App**: Modern iOS app demonstrating best practices
- ✅ **Comprehensive Testing**: Full test coverage for all components with mocked dependencies
- 🎯 **MVVM + Use Cases**: Clean separation of concerns with business logic isolation
- 🔄 **Dependency Injection**: Centralized DI system for better testability and maintainability
- 📅 **Smart Date Handling**: Future date prevention and contextual UI updates
- 🔍 **Health Validation**: Built-in validation and health insights system

## 🚀 Quick Start

### Swift Package Manager

Add HealthMetricKits to your project:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/HealthMetricKits.git", from: "1.0.0")
]
```

### Basic Usage

```swift
import HealthMetricKits

// Use mock data for development/testing
let mockProvider = MockHealthDataProvider()

// Use real HealthKit data for production
let healthKitProvider = HealthKitDataProvider()

// Fetch today's metrics
do {
    let metrics = try await mockProvider.fetchHealthMetrics(for: Date())
    print("Steps: \\(metrics.steps ?? 0)")
    print("Heart Rate Variability: \\(metrics.heartRateVariability ?? 0) ms")
} catch {
    print("Error: \\(error.localizedDescription)")
}
```

## 🏗️ Architecture

### Package Structure

The HealthMetricKits package is organized into logical modules for better maintainability:

```
Sources/HealthMetricKits/
├── HealthMetricKits.swift           # Main module entry point
├── Protocols/
│   └── HealthDataProvider.swift    # Core protocol interface
├── Models/
│   ├── HealthMetrics.swift         # Health metrics data model
│   └── HealthDataError.swift       # Error definitions
├── Implementations/
│   ├── HealthKitDataProvider.swift # Live HealthKit implementation
│   └── MockHealthDataProvider.swift # Mock data provider
├── Extensions/
│   └── HealthMetrics+Extensions.swift # Convenience extensions
└── Utilities/
    └── HealthMetricsFormatter.swift # Formatting and validation utilities
```

### Core Components

#### HealthDataProvider Protocol
The main interface for accessing health data:

```swift
public protocol HealthDataProvider {
    func requestPermissions() async throws
    func fetchHealthMetrics(for date: Date) async throws -> HealthMetrics
    func isHealthDataAvailable() -> Bool
}
```

#### HealthMetrics Model
Structured representation of daily health data with helpful extensions:

```swift
public struct HealthMetrics {
    public let steps: Int?
    public let heartRateVariability: Double?
    public let restingHeartRate: Double?
    public let vo2Max: Double?
    public let sleepDuration: TimeInterval?
    public let date: Date
    
    // Convenience properties
    public var formattedSleepDuration: String { ... }
    public var isComplete: Bool { ... }
    public var completedMetricsCount: Int { ... }
}
```

#### Implementations

1. **HealthKitDataProvider**: Live HealthKit integration with proper permission handling
2. **MockHealthDataProvider**: Deterministic mock data based on date seeds with improved data generation

#### Utilities

- **HealthMetricsFormatter**: Utility for formatting health metrics into user-friendly strings
- **Validation Methods**: Range validation for all health metrics
- **Extensions**: Convenient methods for working with health data

### Demo App Architecture

The included SwiftUI demo app follows Clean Architecture principles with a comprehensive dependency injection system:

```
DemoApp/
├── Domain/
│   ├── HealthMetricsRepository/          # Data access abstraction
│   │   ├── HealthMetricsRepository.swift
│   │   └── DefaultHealthMetricsRepository.swift
│   ├── UseCases/                         # Business logic layer
│   │   ├── UseCase.swift                 # Base use case protocols
│   │   ├── FetchHealthMetricsUseCase.swift
│   │   ├── RequestPermissionsUseCase.swift
│   │   └── ValidateHealthMetricsUseCase.swift
│   └── DependencyInjection/              # Dependency injection system
│       ├── DIContainer.swift             # Centralized dependency container
│       └── ViewModelFactory.swift       # ViewModel factory with DI
├── Navigation/                           # Navigation coordination
│   ├── NavigationCoordinator.swift       # Centralized navigation state
│   └── MainNavigationView.swift         # TabView-based navigation
├── ViewModels/
│   └── HealthDashboardViewModel.swift    # MVVM presentation layer
├── Views/
│   ├── HealthDashboardView.swift         # Main dashboard view with DI
│   ├── MetricsListView.swift             # List of all metrics
│   ├── SettingsView.swift                # App settings
│   ├── AboutView.swift                   # App information
│   └── Components/                       # Reusable UI components
│       ├── HealthMetricCard.swift
│       ├── LoadingView.swift
│       └── ErrorView.swift
└── Tests/
    ├── HealthDashboardViewModelTests.swift # Comprehensive ViewModel tests
    ├── NavigationCoordinatorTests.swift  # Navigation system tests
    ├── MockUseCases/                     # Mock implementations for testing
    └── DemoAppTests.swift                # Integration tests
```

#### Clean Architecture Benefits

- **Domain Layer (Use Cases)**: Contains business logic and rules, independent of external frameworks
- **Data Layer (Repository)**: Abstracts data sources, allowing easy switching between HealthKit and mock data
- **Presentation Layer (ViewModels)**: Coordinates between Use Cases and Views, handles UI state
- **UI Layer (Views)**: Pure SwiftUI components focused on user interface
- **Dependency Injection**: Centralized dependency management for better testability and maintainability

#### Dependency Injection System

The app uses a sophisticated dependency injection system for better testability and maintainability:

```swift
// DIContainer manages all app dependencies
let container = DIContainer.shared

// ViewModelFactory creates ViewModels with proper DI
let factory = ViewModelFactory(diContainer: container)

// Views receive pre-configured ViewModels
let viewModel = factory.makeHealthDashboardViewModel()
```

**Key Features:**
- **Centralized Management**: All dependencies managed in `DIContainer`
- **SwiftUI Integration**: Environment-based dependency injection
- **Testing Support**: Easy mock injection for unit tests
- **Configuration Flexibility**: Switch between production and test configurations
- **MainActor Compliance**: Proper Swift concurrency support

#### Navigation System

The app features a comprehensive navigation system built with SwiftUI's latest navigation APIs:

```swift
// NavigationCoordinator manages navigation state
class NavigationCoordinator: ObservableObject {
    @Published var navigationPath = NavigationPath()
    @Published var selectedTab: Int = 0
    
    func navigate(to destination: NavigationDestination) {
        navigationPath.append(destination)
    }
    
}
```

**Navigation Features:**
- **TabView-based Architecture**: Three main tabs (Dashboard, Metrics, Settings)
- **Centralized State Management**: All navigation state handled by `NavigationCoordinator`
- **Type-safe Navigation**: `NavigationDestination` enum ensures compile-time safety
- **Deep Linking Support**: Navigate to specific metrics or settings from any tab
- **Stack Management**: Proper navigation stack handling with back/root navigation
- **Environment Integration**: Navigation coordinator available throughout the app

**Available Views:**
- **Dashboard**: Main health metrics overview with date selection
- **Metrics List**: Comprehensive list of all available health metrics
- **Metric Detail**: In-depth view of individual metrics with insights
- **Settings**: App configuration and health data management
- **About**: App information and version details

**MetricType System:**
- **Visual Consistency**: Each metric has dedicated icon and color
- **Comprehensive Coverage**: Steps, Heart Rate, HRV, VO₂Max, Sleep
- **Extensible Design**: Easy to add new metrics with proper styling

## 🚀 Recent Improvements

### Version 2.0 - Enhanced Architecture

**🏗️ Advanced Dependency Injection**
- Centralized `DIContainer` for all app dependencies
- `ViewModelFactory` with environment-based injection
- Support for both production and testing configurations
- MainActor-compliant dependency resolution

**📋 Use Cases Implementation**
- `FetchHealthMetricsUseCase` with business rule validation
- `RequestPermissionsUseCase` with availability checks
- `ValidateHealthMetricsUseCase` with health insights
- Clear separation between data access and business logic

**🎨 Enhanced User Interface**
- Dynamic header titles based on selected date
- Future date prevention in DatePicker
- Metrics completion percentage indicator
- Health validation warnings and insights
- Improved accessibility support

**🧭 Navigation System**
- Comprehensive `NavigationCoordinator` with centralized state management
- TabView-based architecture with Dashboard, Metrics, and Settings tabs
- Type-safe navigation using `NavigationDestination` enum
- New views: `MetricsListView`, `SettingsView`, `AboutView`
- Deep linking support for specific metrics and settings
- Proper navigation stack management with back/root navigation
- Environment-based navigation coordinator injection

**🧪 Comprehensive Testing**
- Full dependency injection testing
- Mock implementations for all use cases
- ViewModel testing with injected dependencies
- Date functionality and validation tests
- Comprehensive error handling scenarios

## 📱 Demo App Features

The SwiftUI demo app demonstrates:

- **Clean Dashboard**: Modern card-based layout showing all health metrics
- **Smart Date Selection**: DatePicker with future date prevention and contextual titles
- **Dynamic Headers**: Shows "Today's Metrics" for current date, "Metrics for:" for other dates
- **TabView Navigation**: Three main tabs for Dashboard, Metrics, and Settings
- **Metrics List**: Comprehensive list of all health metrics with navigation to details
- **Metric Detail Views**: In-depth information for each metric with insights and ranges
- **Settings Panel**: App configuration, health data management, and debug options
- **About Page**: App information, version details, and credits
- **Loading States**: Elegant loading animations during data fetch
- **Error Handling**: User-friendly error messages with retry functionality
- **Pull to Refresh**: Standard iOS refresh gesture support
- **Metrics Completion**: Progress indicator showing data completeness percentage
- **Validation Warnings**: Health insights and warnings for unusual readings
- **Mock Data**: Uses MockHealthDataProvider for consistent demo experience
- **Accessibility**: Full Dynamic Type and VoiceOver support

### Screenshots

The dashboard displays:
- 👣 Daily step count
- ❤️ Resting heart rate (BPM)
- 📊 Heart rate variability (ms)
- 🫁 VO₂Max (ml/kg/min)
- 😴 Sleep duration (hours and minutes)

## 🧪 Testing

### Package Tests

Run the complete test suite:

```bash
swift test
```

### Demo App Tests

The demo app includes comprehensive tests for:
- **ViewModels with dependency injection**: Full ViewModel testing with mocked dependencies
- **Repository pattern implementation**: Data layer abstraction testing
- **Use Cases business logic**: Domain layer rule validation
- **Navigation system**: NavigationCoordinator state management and routing logic
- **MetricType system**: Visual consistency and extensibility testing
- **Error handling scenarios**: Comprehensive error state testing
- **Mock data consistency**: Deterministic test data validation
- **Date functionality**: Date selection and validation logic
- **UI state management**: Loading, error, and success states

```bash
# In Xcode, run tests for DemoApp target
⌘ + U

# Run specific test classes
xcodebuild -project DemoApp.xcodeproj -scheme DemoApp -destination 'platform=iOS Simulator,name=iPhone 16' test -only-testing HealthDashboardViewModelTests
```

### Test Coverage

- ✅ **HealthMetrics model initialization and extensions**
- ✅ **MockHealthDataProvider deterministic behavior**
- ✅ **HealthKitDataProvider permission handling**
- ✅ **Use Cases business logic validation**
- ✅ **Dependency injection system**
- ✅ **ViewModel state management with async operations**
- ✅ **Repository pattern implementation**
- ✅ **NavigationCoordinator state management and routing**
- ✅ **MetricType properties and visual consistency**
- ✅ **Navigation destination handling and tab switching**
- ✅ **Error cases and edge conditions**
- ✅ **Date selection and validation logic**
- ✅ **Metrics completion percentage calculations**
- ✅ **Health validation warnings and insights**

## 🔧 Configuration

### HealthKit Permissions

To use the HealthKitDataProvider in your app, add the following to your `Info.plist`:

```xml
<key>NSHealthShareUsageDescription</key>
<string>This app needs access to your health data to display your daily metrics.</string>
```

### Required HealthKit Capabilities

Ensure your app target has HealthKit capability enabled in Xcode project settings.

## 🎯 Design Decisions

### Why Protocol-Oriented Design?

- **Testability**: Easy to mock dependencies for unit testing
- **Flexibility**: Swap implementations without changing client code
- **Separation of Concerns**: Clear boundaries between data access and business logic

### Why Mock Data Provider?

- **Consistent Development**: Same data across team members and CI/CD
- **Demo Ready**: Perfect for app store screenshots and demos
- **Offline Testing**: No need for real health data during development

### Why MVVM + Use Cases + Repository Pattern?

- **Clean Architecture**: Clear separation between UI, business logic, and data access
- **Testability**: Each layer can be tested independently with full mock support
- **Maintainability**: Changes in one layer don't affect others
- **Business Logic Isolation**: Use Cases encapsulate domain rules independently
- **Dependency Injection**: Centralized dependency management for better testing and flexibility
- **iOS Best Practices**: Follows Apple's recommended patterns with modern Swift concurrency
- **Scalability**: Architecture supports easy addition of new features and use cases

## 📊 Health Metrics Details

### Steps
- **Source**: HealthKit step count data
- **Unit**: Total daily steps
- **Mock Range**: 8,000 - 12,950 steps

### Heart Rate Variability (HRV)
- **Source**: HealthKit SDNN measurements
- **Unit**: Milliseconds (ms)
- **Mock Range**: 30 - 70 ms

### Resting Heart Rate
- **Source**: HealthKit resting heart rate
- **Unit**: Beats per minute (BPM)
- **Mock Range**: 55 - 85 BPM

### VO₂Max
- **Source**: HealthKit cardio fitness
- **Unit**: ml/kg/min
- **Mock Range**: 35 - 65 ml/kg/min

### Sleep Duration
- **Source**: HealthKit sleep analysis
- **Unit**: TimeInterval (seconds)
- **Mock Range**: 6.5 - 9.5 hours

## 🚨 Error Handling

The package provides comprehensive error handling:

```swift
public enum HealthDataError: Error, LocalizedError {
    case permissionDenied
    case healthDataNotAvailable
    case dataFetchFailed(Error)
    case invalidData
}
```

Each error provides localized descriptions for user-friendly error messages.

## 🔮 Future Enhancements

Potential areas for expansion:

- **Additional Metrics**: Blood pressure, blood glucose, weight trends
- **Historical Analysis**: Weekly/monthly trends and averages
- **Export Functionality**: CSV/JSON export of health data
- **Widgets**: iOS widget support for quick health overview
- **WatchOS Companion**: Apple Watch app for quick metrics
- **Advanced Health Insights**: AI-powered health recommendations and trend analysis
- **Multi-User Support**: Family health tracking with privacy controls
- **Integration APIs**: Support for additional health data sources beyond HealthKit
- **Offline Sync**: Local data persistence with sync capabilities

## 📄 Requirements

- iOS 16.0+
- Swift 6.1+
- Xcode 15.0+

## 📜 License

This project is available under the MIT License.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 🙋‍♂️ Support

For questions or issues, please open an issue on GitHub.