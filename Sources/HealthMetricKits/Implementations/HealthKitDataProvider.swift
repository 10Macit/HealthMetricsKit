import Foundation
import HealthKit

/// HealthKit implementation of HealthDataProvider
/// Provides access to real health data from the HealthKit store
@available(iOS 16.0, macOS 13.0, *)
public final class HealthKitDataProvider: HealthDataProvider {
    private let healthStore = HKHealthStore()
    
    /// HealthKit data types that this provider needs to read
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
        
        return try await withCheckedThrowingContinuation { continuation in
            healthStore.requestAuthorization(toShare: [], read: typesToRead) { success, error in
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
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let steps = try await fetchSteps(from: startOfDay, to: endOfDay)
        let hrv = try await fetchHeartRateVariability(from: startOfDay, to: endOfDay)
        let rhr = try await fetchRestingHeartRate(from: startOfDay, to: endOfDay)
        let vo2Max = try await fetchVO2Max(from: startOfDay, to: endOfDay)
        let sleepDuration = try await fetchSleepDuration(from: startOfDay, to: endOfDay)
        
        return HealthMetrics(
            steps: steps,
            heartRateVariability: hrv,
            restingHeartRate: rhr,
            vo2Max: vo2Max,
            sleepDuration: sleepDuration,
            date: date
        )
    }
    
    // MARK: - Private Methods
    
    private func fetchSteps(from startDate: Date, to endDate: Date) async throws -> Int? {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return nil }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: HealthDataError.dataFetchFailed(error))
                } else {
                    let steps = result?.sumQuantity()?.doubleValue(for: HKUnit.count())
                    continuation.resume(returning: steps.map(Int.init))
                }
            }
            healthStore.execute(query)
        }
    }
    
    private func fetchHeartRateVariability(from startDate: Date, to endDate: Date) async throws -> Double? {
        guard let hrvType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else { return nil }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: hrvType, quantitySamplePredicate: predicate, options: .discreteAverage) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: HealthDataError.dataFetchFailed(error))
                } else {
                    let hrv = result?.averageQuantity()?.doubleValue(for: HKUnit.secondUnit(with: .milli))
                    continuation.resume(returning: hrv)
                }
            }
            healthStore.execute(query)
        }
    }
    
    private func fetchRestingHeartRate(from startDate: Date, to endDate: Date) async throws -> Double? {
        guard let rhrType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else { return nil }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: rhrType, quantitySamplePredicate: predicate, options: .discreteAverage) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: HealthDataError.dataFetchFailed(error))
                } else {
                    let rhr = result?.averageQuantity()?.doubleValue(for: HKUnit(from: "count/min"))
                    continuation.resume(returning: rhr)
                }
            }
            healthStore.execute(query)
        }
    }
    
    private func fetchVO2Max(from startDate: Date, to endDate: Date) async throws -> Double? {
        guard let vo2MaxType = HKQuantityType.quantityType(forIdentifier: .vo2Max) else { return nil }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: vo2MaxType, quantitySamplePredicate: predicate, options: .discreteAverage) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: HealthDataError.dataFetchFailed(error))
                } else {
                    let vo2MaxUnit = HKUnit.literUnit(with: .milli).unitDivided(by: HKUnit.gramUnit(with: .kilo).unitMultiplied(by: HKUnit.minute()))
                    let vo2Max = result?.averageQuantity()?.doubleValue(for: vo2MaxUnit)
                    continuation.resume(returning: vo2Max)
                }
            }
            healthStore.execute(query)
        }
    }
    
    private func fetchSleepDuration(from startDate: Date, to endDate: Date) async throws -> TimeInterval? {
        guard let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else { return nil }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: HealthDataError.dataFetchFailed(error))
                    return
                }
                
                guard let sleepSamples = samples as? [HKCategorySample] else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let sleepDuration = sleepSamples
                    .filter { $0.value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue ||
                             $0.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue ||
                             $0.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue ||
                             $0.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue }
                    .reduce(0.0) { total, sample in
                        total + sample.endDate.timeIntervalSince(sample.startDate)
                    }
                
                continuation.resume(returning: sleepDuration > 0 ? sleepDuration : nil)
            }
            
            healthStore.execute(query)
        }
    }
}
