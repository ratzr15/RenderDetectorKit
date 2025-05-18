//
//  HangMonitor.swift
//  RenderDetectorKit
//
//  Created by Rathish on 18/05/2025.
//

import SwiftUI
import UIKit

public actor HangMonitorViewModel {
    public static let shared = HangMonitorViewModel()
    private init() {}
    
    var isMonitoring = false
    private let timeoutThresholdYellow: Int = 100
    private let timeoutThresholdRed: Int = 250
    private var hangDetectionTimer: Timer?
    
    nonisolated public func startMonitoring() {
        Task { await _startMonitoring() }
    }
    
    private func _startMonitoring() {
        guard !isMonitoring else { return }
        isMonitoring = true
        _startHangDetection()
    }
    
    nonisolated public func stopMonitoring() {
        Task { await _stopMonitoring() }
    }
    
    private func _stopMonitoring() async {
        isMonitoring = false
        _stopHangDetection()
        await _hideBanner()
    }
    
    private func _startHangDetection() {
        hangDetectionTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { await self?._checkMainThreadResponsiveness() }
        }
    }
    
    private func _stopHangDetection() {
        hangDetectionTimer?.invalidate()
        hangDetectionTimer = nil
    }
    
    private func _checkMainThreadResponsiveness() {
        let semaphore = DispatchSemaphore(value: 0)
        DispatchQueue.main.async {
            semaphore.signal()
        }
        let timeoutResult = semaphore.wait(timeout: .now() + 0.3)
        
        if timeoutResult == .timedOut {
            Task { await self._reportHang() }
        }
    }
    
    private func _reportHang() async {
        let currentTime = Date()
        print("App hang detected at: \(currentTime)")
        
        let start = Date()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            Task {
                let duration = Int(Date().timeIntervalSince(start) * 1000)
                await self.showBannerIfNeeded(duration: duration)
            }
        }
    }
    
    func showBannerIfNeeded(duration: Int) {
        Task {
            if duration > timeoutThresholdRed {
                await _showBanner(color: .red, message: "App Hang Detected (> \(timeoutThresholdRed)ms)")
            } else if duration > timeoutThresholdYellow {
                await _showBanner(color: .yellow, message: "Potential App Hang (> \(timeoutThresholdYellow)ms)")
            } else {
                await _hideBanner()
            }
        }
    }
    
    private func _showBanner(color: Color, message: String) async {
        await MainActor.run {
            HangMonitorUI.shared.setBanner(color: color, message: message)
        }
        try? await Task.sleep(for: .seconds(2))
        await _hideBanner()
    }
    
    private func _hideBanner() async {
        await MainActor.run {
            HangMonitorUI.shared.clearBanner()
        }
    }
}
