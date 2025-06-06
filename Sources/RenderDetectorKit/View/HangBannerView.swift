//
//  HangBannerView.swift
//  RenderDetectorKit
//
//  Created by Rathish on 18/05/2025.
//

import SwiftUI

public struct HangBannerView: View {
    @StateObject public var ui: HangMonitorUI

    public init(ui: HangMonitorUI = .shared) {
        _ui = StateObject(wrappedValue: ui)
    }

    public var body: some View {
        VStack(spacing: 0) {
            if let bannerData = ui.currentBannerData {
                Rectangle()
                    .fill(bannerData.color)
                    .frame(height: 40)
                    .overlay(
                        Text(bannerData.message)
                            .foregroundColor(.white)
                    )
                    .transition(.move(edge: .top))
            }
            Spacer()
        }
        .animation(.default, value: ui.currentBannerData)
    }
}
