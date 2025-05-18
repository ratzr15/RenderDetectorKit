//
//  HangMonitorUI.swift
//  RenderDetectorKit
//
//  Created by Rathish on 18/05/2025.
//

import SwiftUI

@MainActor
public class HangMonitorUI: ObservableObject {
    public static var shared = HangMonitorUI()
    @Published var currentBannerData: BannerData? = nil
}

public extension HangMonitorUI {
    func setBanner(color: Color, message: String) {
        self.currentBannerData = BannerData(color: color, message: message)
    }
    
    func clearBanner() {
        self.currentBannerData = nil
    }
}
