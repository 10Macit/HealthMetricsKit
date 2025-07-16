import Foundation
import HealthKit

/// Mock implementation that injects realistic data into HealthKit for testing
/// This provider writes 7 days of mock data to HealthKit and then reads it back using HealthKitDataProvider
/// Perfect for staging/testing environments where you want to test the real HealthKit flow with controlled data
@available(iOS 16.0, macOS 13.0, *)
public final class MockDataWithInjectionProvider: HealthDataProvider {
    private let healthStore = HKHealthStore()
    private let healthKitProvider = HealthKitDataProvider()
    private var hasInjectedData = false
    
    /// HealthKit data types that this provider needs to read and write
    private let typesToShare: Set<HKSampleType> = [
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
        HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
        HKObjectType.quantityType(forIdentifier: .vo2Max)!,
        HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
    ]
    
    private let typesToRead: Set<HKObjectType> = [
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
        HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
        HKObjectType.quantityType(forIdentifier: .vo2Max)!,
        HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
    ]
    
    public init() {}
    
    public func isHealthDataAvailable() -> Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
    
    public func requestPermissions() async throws {
        guard isHealthDataAvailable() else {
            throw HealthDataError.healthDataNotAvailable
        }
        
        // Request both read and write permissions
        return try await withCheckedThrowingContinuation { continuation in
            healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
                if let error = error {
                    continuation.resume(throwing: HealthDataError.dataFetchFailed(error))
                } else if !success {
                    continuation.resume(throwing: HealthDataError.permissionDenied)
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    public func fetchHealthMetrics(for date: Date) async throws -> HealthMetrics {
        // Ensure mock data is injected before fetching
        if !hasInjectedData {
            try await injectMockDataIfNeeded()
            hasInjectedData = true
        }
        
        // Use the real HealthKitDataProvider to fetch the injected data
        return try await healthKitProvider.fetchHealthMetrics(for: date)
    }
    
    // MARK: - Private Methods
    
    /// Clears existing HealthKit samples and injects 7 days of realistic mock data
    private func injectMockDataIfNeeded() async throws {
        print("🔄 MockDataWithInjectionProvider: Starting data injection...")
        
        // Clear existing samples first (ignore errors if no data exists)
        await clearExistingSamplesGracefully()
        print("🧹 Cleared existing HealthKit samples")
        
        // Inject 7 days of mock data
        try await injectSevenDaysOfMockData()
        print("✅ Injected 7 days of mock data to HealthKit")
    }
    
    /// Clears existing HealthKit samples gracefully (ignores errors if no data exists)
    private func clearExistingSamplesGracefully() async {
        let sampleTypes: [HKSampleType] = [
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKQuantityType.quantityType(forIdentifier: .vo2Max)!,
            HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!,
            HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
            HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!
        ]
        
        for sampleType in sampleTypes {
            await clearSamplesForGracefully(sampleType: sampleType)
        }
    }
    
    /// Clears existing HealthKit samples for our data types (throws on errors)
    private func clearExistingSamples() async throws {
        let sampleTypes: [HKSampleType] = [
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKQuantityType.quantityType(forIdentifier: .vo2Max)!,
            HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!,
            HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
            HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!
        ]
        
        for sampleType in sampleTypes {
            try await clearSamplesFor(sampleType: sampleType)
        }
    }
    
    /// Clears samples for a specific HealthKit sample type gracefully (ignores errors)
    private func clearSamplesForGracefully(sampleType: HKSampleType) async {
        do {
            try await clearSamplesFor(sampleType: sampleType)
        } catch {
            // Ignore errors - this is expected when no data exists
            print("ℹ️ No existing \(sampleType.identifier) data to clear (this is normal)")
        }
    }
    
    /// Clears samples for a specific HealthKit sample type
    private func clearSamplesFor(sampleType: HKSampleType) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: [])
            let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let samples = samples, !samples.isEmpty else {
                    continuation.resume()
                    return
                }
                
                self.healthStore.delete(samples) { success, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume()
                    }
                }
            }
            healthStore.execute(query)
        }
    }
    
    /// Injects 7 days of realistic mock data into HealthKit
    private func injectSevenDaysOfMockData() async throws {
        let calendar = Calendar.current
        let now = Date()
        
        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: now) else { continue }
            let startOfDay = calendar.startOfDay(for: date)
            
            // Generate varied but realistic data for each day
            let baseSteps = 8000
            let stepsVariation = dayOffset * 1200 + Int.random(in: -500...500)
            let steps = Double(baseSteps + stepsVariation)
            
            let baseVO2Max = 42.0
            let vo2MaxVariation = Double(dayOffset) * 0.3 + Double.random(in: -1.0...1.0)
            let vo2Max = baseVO2Max + vo2MaxVariation
            
            let baseRHR = 65.0
            let rhrVariation = Double(dayOffset) * -0.5 + Double.random(in: -3.0...3.0)
            let restingHeartRate = baseRHR + rhrVariation
            
            let baseHRV = 45.0
            let hrvVariation = Double(dayOffset) * 1.5 + Double.random(in: -5.0...5.0)
            let heartRateVariability = baseHRV + hrvVariation
            
            let baseSleep = 7.5
            let sleepVariation = Double(dayOffset % 3) * 0.5 + Double.random(in: -0.5...0.5)
            let sleepHours = baseSleep + sleepVariation
            
            // Save the data to HealthKit
            try await saveQuantitySample(.stepCount, value: steps, unit: .count(), date: startOfDay)
            try await saveQuantitySample(.vo2Max, value: vo2Max, unit: HKUnit(from: "mL/kg*min"), date: startOfDay)
            try await saveQuantitySample(.restingHeartRate, value: restingHeartRate, unit: .count().unitDivided(by: .minute()), date: startOfDay)
            try await saveQuantitySample(.heartRateVariabilitySDNN, value: heartRateVariability, unit: .secondUnit(with: .milli), date: startOfDay)
            try await saveSleepSample(hours: sleepHours, date: startOfDay)
            
            print("📊 Day \(dayOffset + 1): Steps: \(Int(steps)), VO2Max: \(String(format: "%.1f", vo2Max)), RHR: \(String(format: "%.1f", restingHeartRate)), HRV: \(String(format: "%.1f", heartRateVariability)), Sleep: \(String(format: "%.1f", sleepHours))h")
        }
    }
    
    /// Saves a quantity sample to HealthKit
    private func saveQuantitySample(_ identifier: HKQuantityTypeIdentifier, value: Double, unit: HKUnit, date: Date) async throws {
        guard let type = HKQuantityType.quantityType(forIdentifier: identifier) else {
            throw HealthDataError.dataFetchFailed(NSError(domain: "HealthKit", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid quantity type"]))
        }
        
        let quantity = HKQuantity(unit: unit, doubleValue: value)
        let sample = HKQuantitySample(type: type, quantity: quantity, start: date, end: date)
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            healthStore.save(sample) { _, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    /// Saves a sleep sample to HealthKit
    private func saveSleepSample(hours: Double, date: Date) async throws {
        guard let type = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else {
            throw HealthDataError.dataFetchFailed(NSError(domain: "HealthKit", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid sleep analysis type"]))
        }
        
        let startDate = Calendar.current.date(byAdding: .hour, value: 22, to: date) ?? date // 10 PM
        let endDate = Calendar.current.date(byAdding: .hour, value: Int(hours), to: startDate) ?? startDate
        
        let sample = HKCategorySample(
            type: type,
            value: HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue,
            start: startDate,
            end: endDate
        )
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            healthStore.save(sample) { _, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}