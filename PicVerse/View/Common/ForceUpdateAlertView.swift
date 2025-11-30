//
//  ForceUpdateAlertView.swift
//  NeoLed
//
//  Created by Purvi Sancheti on 09/10/25.
//


import Foundation
import SwiftUI

struct ForceUpdateAlertView: View {
    @Environment(\.colorScheme) var colorScheme

    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)

    
    var body: some View {
        ZStack {
            // Background: subtle radial glow
            Color.black.ignoresSafeArea()
            
            VStack(spacing: ScaleUtility.scaledSpacing(20) ) {
                // Header
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(FontManager.instrumentSansRegularFont(size: .scaledFontSize(50)))
                    .foregroundColor(Color.white)
                    .padding(.top, ScaleUtility.scaledSpacing(30))
                
                Text("Update Required")
                    .font(FontManager.instrumentSansBoldFont(size:.scaledFontSize(18)))
                    .foregroundColor(Color.secondaryApp)
                
                Text("A new version is available. Please update to continue using the app.")
                    .font(FontManager.instrumentSansRegularFont(size: .scaledFontSize(15)))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, .scaledFontSize(20))
                    .foregroundColor(Color.secondaryApp.opacity(0.8))
                
                Divider()
                    .background(Color.secondaryApp)
                    .offset(y:.scaledFontSize(10))
                
                Button(action: {
                    impactFeedback.impactOccurred()
                    self.openAppInAppStore()
                    AnalyticsManager.shared.log(.noOfUserUpdatedApp)
                })
                {
                    Text("Update Now")
                        .font(FontManager.instrumentSansMediumFont(size: .scaledFontSize(20)))
                        .foregroundColor(Color.secondaryApp)
                }
                .padding(.top, .scaledFontSize(10))
                .padding(.bottom, .scaledFontSize(30))
                .buttonStyle(.plain)
            }
            .frame(width: UIScreen.main.bounds.width - 60)
            .background(
                LinearGradient(
                    colors: [Color(hex: "050510"), Color(hex: "0C0F1A")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .overlay(
                    RadialGradient(
                        gradient: Gradient(colors: [Color.purple.opacity(0.2), .clear]),
                        center: .topTrailing, startRadius: 40, endRadius: 600)
                )
                .ignoresSafeArea()
            )
            .cornerRadius(25)
            .shadow(radius: 10)
        }
        .ignoresSafeArea()
    }
    
    private func openAppInAppStore() {
        if let appStoreUrl = URL(string: AppConstant.shareAppIDURL) {
            UIApplication.shared.open(appStoreUrl)
        }
    }
}

#Preview {
    ForceUpdateAlertView()
}

