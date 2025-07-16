# Staging Environment - MockDataWithInjectionProvider

## Overview

The Staging environment provides a realistic testing scenario by injecting controlled mock data directly into HealthKit and then using the real `HealthKitDataProvider` to fetch it. This allows you to test the complete HealthKit integration flow with predictable, controlled data.

## How It Works

1. **MockDataWithInjectionProvider** requests HealthKit read/write permissions
2. **Data Injection**: Clears existing HealthKit data and injects 7 days of realistic mock data
3. **Real Fetching**: Uses `HealthKitDataProvider` internally to fetch the injected data
4. **Complete Flow**: Tests the entire HealthKit pipeline with controlled data

## Scheme Configuration

### Available Schemes:
- **DemoApp-Development**: Uses `MockHealthDataProvider` (pure mock, no HealthKit)
- **DemoApp-Staging**: Uses `MockDataWithInjectionProvider` (HealthKit injection)
- **DemoApp-Production**: Uses `HealthKitDataProvider` (real user data)

### Environment Variables:
- `APP_CONFIGURATION=Development` → MockHealthDataProvider
- `APP_CONFIGURATION=Staging` → MockDataWithInjectionProvider  
- `APP_CONFIGURATION=Production` → HealthKitDataProvider

## Mock Data Generated

The staging environment generates 7 days of realistic health data:

### Data Patterns:
- **Steps**: 8,000-12,000 steps with daily variation
- **VO₂ Max**: 42.0-44.1 ml/kg/min with gradual progression
- **Resting Heart Rate**: 62-65 BPM with natural fluctuation
- **Heart Rate Variability**: 45-58 ms with realistic variation
- **Sleep Duration**: 7.5-8.5 hours with weekend variations

### Data Characteristics:
- **Realistic Ranges**: All values fall within normal health ranges
- **Natural Variation**: Random fluctuations simulate real-world data
- **Temporal Patterns**: Weekend vs weekday differences
- **Consistent Quality**: Reproducible data for testing

## Usage

### Running Staging Environment:

```bash
# Build and run staging
xcodebuild -project DemoApp.xcodeproj -scheme DemoApp-Staging -destination 'platform=iOS Simulator,name=iPhone 16' build

# Or use Xcode
# Select DemoApp-Staging scheme and run
```

### What Happens on Launch:

1. **Permission Request**: App automatically requests HealthKit permissions
2. **Data Injection**: MockDataWithInjectionProvider injects 7 days of data
3. **UI Update**: Dashboard shows the injected data using real HealthKit queries
4. **Console Output**: Detailed logging shows injection progress

### Console Output Example:

```
🔄 MockDataWithInjectionProvider: Starting data injection...
🧹 Cleared existing HealthKit samples
📊 Day 1: Steps: 12000, VO2Max: 42.0, RHR: 65.0, HRV: 45.0, Sleep: 7.5h
📊 Day 2: Steps: 11200, VO2Max: 42.3, RHR: 64.5, HRV: 46.5, Sleep: 8.0h
...
✅ Injected 7 days of mock data to HealthKit
✅ Health data permissions granted successfully
```

## Benefits

### For Testing:
- **Predictable Data**: Consistent results across test runs
- **Real Integration**: Tests actual HealthKit read/write operations
- **Permission Flow**: Tests complete permission request flow
- **Error Handling**: Can test HealthKit error scenarios

### For Development:
- **No Device Dependency**: Works in simulator without real health data
- **Quick Setup**: Instant data availability for UI testing
- **Realistic Scenarios**: Data patterns match real user behavior
- **Debugging**: Console logs show exact injection process

### For QA:
- **Reproducible Tests**: Same data set every time
- **Edge Cases**: Can modify data ranges for edge case testing
- **Performance Testing**: Consistent baseline for performance metrics
- **UI Validation**: Verify UI handles various data values correctly

## Architecture

```
App Launch (Staging)
    ↓
Request HealthKit Permissions
    ↓
MockDataWithInjectionProvider.fetchHealthMetrics()
    ↓
Check if data injected (hasInjectedData flag)
    ↓
If not injected:
    ├── Clear existing HealthKit samples
    ├── Inject 7 days of realistic mock data
    └── Set hasInjectedData = true
    ↓
Use HealthKitDataProvider to fetch injected data
    ↓
Return HealthMetrics to UI
```

## Code Integration

### DIContainer Configuration:

```swift
switch Configuration.current {
case .development:
    provider = MockHealthDataProvider()        // Pure mock
case .staging:
    provider = MockDataWithInjectionProvider() // HealthKit injection
case .production:
    provider = HealthKitDataProvider()         // Real data
}
```

### Data Provider Features:

```swift
// MockDataWithInjectionProvider capabilities:
- Requests HealthKit read/write permissions
- Clears existing samples for clean testing
- Injects 7 days of varied, realistic data
- Uses HealthKitDataProvider internally for fetching
- Handles permission errors gracefully
- Provides detailed console logging
```

## Use Cases

### Perfect for:
- **Integration Testing**: End-to-end HealthKit integration testing
- **UI Testing**: Testing UI with realistic data variations
- **Demo Preparation**: Consistent demo data for presentations
- **Development**: Testing without relying on personal health data
- **CI/CD**: Automated testing with predictable data sets

### Not Suitable for:
- **Unit Testing**: Use MockHealthDataProvider for isolated unit tests
- **Production**: Never use in production builds
- **Performance Benchmarking**: Real data may have different performance characteristics

## Troubleshooting

### Common Issues:

1. **Permission Denied**: Ensure HealthKit entitlements are configured
2. **Data Not Showing**: Check console for injection errors
3. **Stale Data**: Data is injected once per app launch; restart to re-inject
4. **Simulator Issues**: HealthKit may have limitations in older simulators

### Debug Tips:

- Check console output for detailed injection logs
- Verify scheme environment variable is set to "Staging"
- Ensure HealthKit entitlements are enabled in project settings
- Use iOS Simulator with HealthKit support (iOS 16.0+)