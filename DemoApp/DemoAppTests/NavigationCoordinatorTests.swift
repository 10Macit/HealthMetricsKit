//
//  NavigationCoordinatorTests.swift
//  DemoAppTests
//
//  Created by Claude on 16/07/2025.
//

import XCTest
import SwiftUI
@testable import DemoApp

@MainActor
final class NavigationCoordinatorTests: XCTestCase {
    
    var coordinator: NavigationCoordinator!
    
    override func setUp() {
        super.setUp()
        coordinator = NavigationCoordinator()
    }
    
    override func tearDown() {
        coordinator = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialState() {
        XCTAssertEqual(coordinator.navigationPath.count, 0)
        XCTAssertEqual(coordinator.selectedTab, 0)
    }
    
    // MARK: - Navigation Tests
    
    func testNavigateToDestination() {
        let destination = NavigationDestination.settings
        coordinator.navigate(to: destination)
        
        XCTAssertEqual(coordinator.navigationPath.count, 1)
    }
    
    
    func testNavigateToSettings() {
        coordinator.navigateToSettings()
        
        XCTAssertEqual(coordinator.navigationPath.count, 1)
    }
    
    func testNavigateToAbout() {
        coordinator.navigateToAbout()
        
        XCTAssertEqual(coordinator.navigationPath.count, 1)
    }
    
    func testMultipleNavigations() {
        coordinator.navigate(to: .settings)
        coordinator.navigate(to: .about)
        
        XCTAssertEqual(coordinator.navigationPath.count, 2)
    }
    
    // MARK: - Navigation Back Tests
    
    func testNavigateBack() {
        coordinator.navigate(to: .settings)
        coordinator.navigate(to: .about)
        XCTAssertEqual(coordinator.navigationPath.count, 2)
        
        coordinator.navigateBack()
        XCTAssertEqual(coordinator.navigationPath.count, 1)
    }
    
    func testNavigateBackFromEmptyPath() {
        XCTAssertEqual(coordinator.navigationPath.count, 0)
        
        // This should not crash
        coordinator.navigateBack()
        XCTAssertEqual(coordinator.navigationPath.count, 0)
    }
    
    // MARK: - Navigation Root Tests
    
    func testNavigateToRoot() {
        coordinator.navigate(to: .settings)
        coordinator.navigate(to: .about)
        XCTAssertEqual(coordinator.navigationPath.count, 2)
        
        coordinator.navigateToRoot()
        XCTAssertEqual(coordinator.navigationPath.count, 0)
    }
    
    func testNavigateToRootFromEmptyPath() {
        XCTAssertEqual(coordinator.navigationPath.count, 0)
        
        coordinator.navigateToRoot()
        XCTAssertEqual(coordinator.navigationPath.count, 0)
    }
    
    // MARK: - Tab Management Tests
    
    func testSwitchToTab() {
        coordinator.switchToTab(2)
        
        XCTAssertEqual(coordinator.selectedTab, 2)
    }
    
    func testSwitchToTabClearsNavigationStack() {
        coordinator.navigate(to: .settings)
        coordinator.navigate(to: .about)
        XCTAssertEqual(coordinator.navigationPath.count, 2)
        
        coordinator.switchToTab(1)
        
        XCTAssertEqual(coordinator.selectedTab, 1)
        XCTAssertEqual(coordinator.navigationPath.count, 0)
    }
    
    func testSwitchToSameTab() {
        coordinator.switchToTab(0)
        
        XCTAssertEqual(coordinator.selectedTab, 0)
        XCTAssertEqual(coordinator.navigationPath.count, 0)
    }
    
    // MARK: - MetricType Tests
    
    func testMetricTypeProperties() {
        // Test Steps
        XCTAssertEqual(MetricType.steps.rawValue, "Steps")
        XCTAssertEqual(MetricType.steps.iconName, "figure.walk")
        XCTAssertEqual(MetricType.steps.color, .blue)
        
        // Test Heart Rate
        XCTAssertEqual(MetricType.heartRate.rawValue, "Heart Rate")
        XCTAssertEqual(MetricType.heartRate.iconName, "heart.fill")
        XCTAssertEqual(MetricType.heartRate.color, .red)
        
        // Test Heart Rate Variability
        XCTAssertEqual(MetricType.heartRateVariability.rawValue, "Heart Rate Variability")
        XCTAssertEqual(MetricType.heartRateVariability.iconName, "waveform.path.ecg")
        XCTAssertEqual(MetricType.heartRateVariability.color, .green)
        
        // Test VO2 Max
        XCTAssertEqual(MetricType.vo2Max.rawValue, "VO₂ Max")
        XCTAssertEqual(MetricType.vo2Max.iconName, "lungs.fill")
        XCTAssertEqual(MetricType.vo2Max.color, .purple)
        
        // Test Sleep
        XCTAssertEqual(MetricType.sleep.rawValue, "Sleep")
        XCTAssertEqual(MetricType.sleep.iconName, "bed.double.fill")
        XCTAssertEqual(MetricType.sleep.color, .indigo)
    }
    
    func testMetricTypeAllCases() {
        let allCases = MetricType.allCases
        
        XCTAssertEqual(allCases.count, 5)
        XCTAssertTrue(allCases.contains(.steps))
        XCTAssertTrue(allCases.contains(.heartRate))
        XCTAssertTrue(allCases.contains(.heartRateVariability))
        XCTAssertTrue(allCases.contains(.vo2Max))
        XCTAssertTrue(allCases.contains(.sleep))
    }
    
    // MARK: - NavigationDestination Tests
    
    func testNavigationDestinationEquality() {
        let destination1 = NavigationDestination.settings
        let destination2 = NavigationDestination.settings
        let destination3 = NavigationDestination.about
        
        XCTAssertEqual(destination1, destination2)
        XCTAssertNotEqual(destination1, destination3)
    }
    
    // MARK: - Environment Key Tests
    
    func testEnvironmentKeyDefaultValue() {
        let defaultCoordinator = NavigationCoordinatorKey.defaultValue
        
        XCTAssertEqual(defaultCoordinator.selectedTab, 0)
        XCTAssertEqual(defaultCoordinator.navigationPath.count, 0)
    }
    
    // MARK: - Integration Tests
    
    func testNavigationFlow() {
        // Simulate user navigation flow
        
        // Start on Dashboard (tab 0)
        XCTAssertEqual(coordinator.selectedTab, 0)
        
        // Navigate to a metric detail
        coordinator.switchToTab(2)
        XCTAssertEqual(coordinator.selectedTab, 2)
        XCTAssertEqual(coordinator.navigationPath.count, 0)
        coordinator.navigateToAbout()
        XCTAssertEqual(coordinator.navigationPath.count, 1)

        // Navigate back
        coordinator.navigateBack()
        XCTAssertEqual(coordinator.selectedTab, 2)
        XCTAssertEqual(coordinator.navigationPath.count, 0)
    }
    
    func testComplexNavigationScenario() {
        // Test a complex navigation scenario
        
        // Navigate deep into the stack
        coordinator.navigate(to: .settings)
        coordinator.navigate(to: .about)
        coordinator.navigateToSettings()
        
        XCTAssertEqual(coordinator.navigationPath.count, 3)
        
        // Navigate back a few times
        coordinator.navigateBack()
        coordinator.navigateBack()
        
        XCTAssertEqual(coordinator.navigationPath.count, 1)
        
        // Switch tabs (should clear remaining navigation)
        coordinator.switchToTab(2)
        
        XCTAssertEqual(coordinator.selectedTab, 2)
        XCTAssertEqual(coordinator.navigationPath.count, 0)
    }
}
