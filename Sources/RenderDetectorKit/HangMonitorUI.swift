//
//  HangMonitorUI.swift
//  RenderDetectorKit
//
//  Created by Rathish on 18/05/2025.
//

import SwiftUI

@MainActor
public class HangMonitorUI: ObservableObject {
    public static let shared = HangMonitorUI()
    @Published public var currentBannerData: BannerData?

    public func setBanner(color: Color, message: String) {
        currentBannerData = BannerData(color: color, message: message)
    }

    public func clearBanner() {
        currentBannerData = nil
    }
}
