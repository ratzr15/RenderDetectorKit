//
//  HangMonitorViewModelTests.swift
//  RenderDetectorKit
//
//  Created by Rathish on 18/05/2025.
//

import XCTest
import SwiftUI

@testable import RenderDetectorKit

@MainActor
class HangMonitorViewModelTests: XCTestCase {
    
    var viewModel: HangMonitorViewModel!
    var uiModel: HangMonitorUI!
    
    let timeoutThresholdYellow: Int = 100
    let timeoutThresholdRed: Int = 250
    
    override func setUp() async throws {
        viewModel = HangMonitorViewModel.shared
        uiModel = HangMonitorUI.shared
        
        viewModel.stopMonitoring()
        uiModel.clearBanner()
    }
    
    
    override func tearDown() async throws {
        if viewModel != nil {
            viewModel.stopMonitoring()
        }
        if uiModel != nil {
            uiModel.clearBanner()
        }
        
        viewModel = nil
        uiModel = nil
        
    }
    
    // MARK: - Test Public API
    func testStartMonitoring_setsIsMonitoringToTrue() async throws {
        
        //Given
        let initialIsMonitoring = await viewModel.isMonitoring
        XCTAssertFalse(initialIsMonitoring, "ViewModel should not be monitoring after setup.")
        
        //When
        viewModel.startMonitoring()
        let monitoringStartedExpectation = XCTestExpectation(description: "isMonitoring should become true")
        
        for _ in 0..<100 {
            if await viewModel.isMonitoring {
                monitoringStartedExpectation.fulfill()
                break
            }
            try await Task.sleep(for: .milliseconds(10))
        }
        await fulfillment(of: [monitoringStartedExpectation], timeout: 1.5)
        
        //Then
        let finalIsMonitoring = await viewModel.isMonitoring
        XCTAssertTrue(finalIsMonitoring, "isMonitoring should be true after startMonitoring is called and its Task completes.")
    }
    
    func testStopMonitoring_setsIsMonitoringToFalseAndClearsBanner() async throws {
        
        //Given
        viewModel.startMonitoring()
        let monitoringStartedExpectation = XCTestExpectation(description: "Wait for monitoring to start")
        Task {
            while await !viewModel.isMonitoring { try await Task.sleep(for: .milliseconds(10)) }
            monitoringStartedExpectation.fulfill()
        }
        await fulfillment(of: [monitoringStartedExpectation], timeout: 1.0)
        
        let isMonitoringAfterStart = await viewModel.isMonitoring
        XCTAssertTrue(isMonitoringAfterStart, "ViewModel should be monitoring.")

        uiModel.setBanner(color: .red, message: "Test Banner for Stop")
        XCTAssertNotNil(uiModel.currentBannerData, "Banner should be set before stopping.")

        //When
        viewModel.stopMonitoring()
        let monitoringStoppedExpectation = XCTestExpectation(description: "isMonitoring should become false and banner cleared")
        Task {
            while await viewModel.isMonitoring { try await Task.sleep(for: .milliseconds(10)) }
            while uiModel.currentBannerData != nil { try await Task.sleep(for: .milliseconds(10)) }
            monitoringStoppedExpectation.fulfill()
        }
        await fulfillment(of: [monitoringStoppedExpectation], timeout: 2.0)


        //Then
        let isMonitoringAfterStop = await viewModel.isMonitoring
        XCTAssertFalse(isMonitoringAfterStop, "isMonitoring should be false after stopMonitoring.")
        XCTAssertNil(uiModel.currentBannerData, "Banner should be cleared after stopMonitoring.")
    }
    
    // MARK: - Banner Logic - Show
    func testShowBannerIfNeeded_durationAboveYellowThreshold_showsYellowBanner() async throws {
        
        //Given
        await viewModel.showBannerIfNeeded(duration: timeoutThresholdYellow + 1)
        let bannerShownExpectation = XCTestExpectation(description: "Yellow banner should be shown")
        
        // When
        Task {
            for _ in 0..<100 {
                if let bannerData = uiModel.currentBannerData, bannerData.color == .yellow {
                    bannerShownExpectation.fulfill()
                    break
                }
                try await Task.sleep(for: .milliseconds(10))
            }
        }
        await fulfillment(of: [bannerShownExpectation], timeout: 1.5)

        //Then
        XCTAssertNotNil(uiModel.currentBannerData, "Banner data should exist")
        XCTAssertEqual(uiModel.currentBannerData?.color, .yellow, "Banner color should be yellow.")
        XCTAssertEqual(uiModel.currentBannerData?.message, "Potential App Hang (> \(timeoutThresholdYellow)ms)", "Banner message incorrect for yellow.")
    }
    
    // MARK: - Banner Logic - Hide
    func testShowBannerIfNeeded_durationAboveYellowThreshold_BannerAndAutoHides() async throws {
        
        //Given
        await viewModel.showBannerIfNeeded(duration: timeoutThresholdYellow + 1)
        let bannerShownExpectation = XCTestExpectation(description: "Yellow banner is shown")
        
        // When
        Task {
            for _ in 0..<100 {
                if let bannerData = uiModel.currentBannerData, bannerData.color == .yellow {
                    bannerShownExpectation.fulfill()
                    break
                }
                try await Task.sleep(for: .milliseconds(10))
            }
        }
        await fulfillment(of: [bannerShownExpectation], timeout: 1.5)

        //Then
        let bannerHiddenExpectation = XCTestExpectation(description: "Yellow banner should auto-hide")
        Task {
            try await Task.sleep(for: .seconds(2.2))
            if uiModel.currentBannerData == nil {
                bannerHiddenExpectation.fulfill()
            }
        }
        await fulfillment(of: [bannerHiddenExpectation], timeout: 3.0)
        XCTAssertNil(uiModel.currentBannerData, "Yellow banner should have auto-hidden.")
    }
}
