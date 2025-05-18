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

        // Given
        XCTAssertFalse(viewModel.isMonitoring, "ViewModel should not be monitoring after setup.")

        // When
        viewModel.startMonitoring()
        try await Task.sleep(for: .milliseconds(100)) // allow timer to start

        // Then
        XCTAssertTrue(viewModel.isMonitoring, "isMonitoring should be true after startMonitoring is called.")
    }

    func testStopMonitoring_setsIsMonitoringToFalseAndClearsBanner() async throws {

        // Given
        viewModel.startMonitoring()
        try await Task.sleep(for: .milliseconds(100))
        XCTAssertTrue(viewModel.isMonitoring, "ViewModel should be monitoring.")

        uiModel.setBanner(color: .red, message: "Test Banner for Stop")
        XCTAssertNotNil(uiModel.currentBannerData, "Banner should be set before stopping.")

        // When
        viewModel.stopMonitoring()
        try await Task.sleep(for: .milliseconds(100))

        // Then
        XCTAssertFalse(viewModel.isMonitoring, "isMonitoring should be false after stopMonitoring.")
        XCTAssertNil(uiModel.currentBannerData, "Banner should be cleared after stopMonitoring.")
    }

    // MARK: - Banner Logic - Show
    func testShowBannerIfNeeded_durationAboveYellowThreshold_showsYellowBanner() async throws {

        // Given
        viewModel.showBannerIfNeeded(duration: timeoutThresholdYellow + 10)
        try await Task.sleep(for: .milliseconds(200))

        // Then
        let banner = uiModel.currentBannerData
        XCTAssertNotNil(banner, "Banner data should exist")
        XCTAssertEqual(banner?.color, .yellow, "Banner color should be yellow.")
        XCTAssertEqual(banner?.message, "Potential App Hang (> \(timeoutThresholdYellow)ms)", "Banner message incorrect for yellow.")
    }

    func testShowBannerIfNeeded_durationAboveRedThreshold_showsRedBanner() async throws {

        // Given
        viewModel.showBannerIfNeeded(duration: timeoutThresholdRed + 10)
        try await Task.sleep(for: .milliseconds(200))

        // Then
        let banner = uiModel.currentBannerData
        XCTAssertNotNil(banner, "Banner data should exist")
        XCTAssertEqual(banner?.color, .red, "Banner color should be red.")
        XCTAssertEqual(banner?.message, "App Hang Detected (> \(timeoutThresholdRed)ms)", "Banner message incorrect for red.")
    }

    // MARK: - Banner Logic - Hide
    func testShowBannerIfNeeded_durationAboveYellowThreshold_BannerAutoHides() async throws {

        // Given
        viewModel.showBannerIfNeeded(duration: timeoutThresholdYellow + 1)

        // Wait for it to be set
        try await Task.sleep(for: .milliseconds(200))
        XCTAssertNotNil(uiModel.currentBannerData, "Banner should be shown.")

        // Wait for auto-hide
        try await Task.sleep(for: .seconds(2.5))

        // Then
        XCTAssertNil(uiModel.currentBannerData, "Banner should auto-hide after 2 seconds.")
    }

    func testShowBannerIfNeeded_durationBelowThreshold_clearsBanner() async throws {

        // Given
        uiModel.setBanner(color: .red, message: "Persistent Banner")
        XCTAssertNotNil(uiModel.currentBannerData)

        // When
        viewModel.showBannerIfNeeded(duration: 50) // below any threshold
        try await Task.sleep(for: .milliseconds(300))

        // Then
        XCTAssertNil(uiModel.currentBannerData, "Banner should be cleared for durations below threshold.")
    }
}
