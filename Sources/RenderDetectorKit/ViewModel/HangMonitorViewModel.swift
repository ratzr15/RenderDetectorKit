//
//  HangMonitor.swift
//  RenderDetectorKit
//
//  Created by Rathish on 18/05/2025.
//

import SwiftUI
import UIKit

@MainActor
public final class HangMonitorViewModel: @unchecked Sendable {
    public static let shared = HangMonitorViewModel()

    private var isMonitoringFlag = false
    private var timer: Timer?
    private let lock = DispatchQueue(label: "com.renderdetectorkit.hangmonitor.lock")

    private let timeoutThresholdYellow: Int = 100
    private let timeoutThresholdRed: Int = 250

    private init() {}

    public var isMonitoring: Bool {
        lock.sync { isMonitoringFlag }
    }

    public func startMonitoring() {
        guard !isMonitoring else { return }
        isMonitoringFlag = true
        checkHang()
    }

    public func stopMonitoring() {
        lock.sync {
            isMonitoringFlag = false
            timer?.invalidate()
            timer = nil
        }

        Task { @MainActor in
            HangMonitorUI.shared.clearBanner()
        }
    }

    private func checkHang() {
        let semaphore = DispatchSemaphore(value: 0)
        DispatchQueue.main.async {
            semaphore.signal()
        }

        let result = semaphore.wait(timeout: .now() + 0.3)
        if result == .timedOut {
            reportHang()
        }
    }

    private func reportHang() {
        let start = Date()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let duration = Int(Date().timeIntervalSince(start) * 1000)
            HangMonitorViewModel.shared.showBannerIfNeeded(duration: duration)
        }
    }

    public func showBannerIfNeeded(duration: Int) {
        if duration > timeoutThresholdRed {
            showBanner(color: .red, message: "App Hang Detected (> \(timeoutThresholdRed)ms)")
        } else if duration > timeoutThresholdYellow {
            showBanner(color: .yellow, message: "Potential App Hang (> \(timeoutThresholdYellow)ms)")
        } else {
            Task { @MainActor in
                HangMonitorUI.shared.clearBanner()
            }
        }
    }

    private func showBanner(color: Color, message: String) {
        Task { @MainActor in
            HangMonitorUI.shared.setBanner(color: color, message: message)
        }

        Task {
            try? await Task.sleep(for: .seconds(2))
            await MainActor.run {
                HangMonitorUI.shared.clearBanner()
            }
        }
    }
}
