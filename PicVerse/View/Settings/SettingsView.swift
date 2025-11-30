//
//  SettingsView.swift
//  H2JPG
//
//  Created by Purvi Sancheti on 12/08/25.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var purchaseManager: PurchaseManager
    @EnvironmentObject var timerManager: TimerManager
    @EnvironmentObject var remoteConfigManager: RemoteConfigManager
    
    
    var body: some View {
        ZStack {
            // Background: subtle radial glow
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
            VStack(spacing: 0) {
                Text("Settings")
                    .font(FontManager.instrumentSansMediumFont(size: .scaledFontSize(21)))
                    .foregroundColor(Color.secondaryApp)
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .padding(.leading,ScaleUtility.scaledSpacing(20))
                    .padding(.top,ScaleUtility.scaledSpacing(63))
                
                VStack(spacing: ScaleUtility.scaledSpacing(0)) {
                    
                    if !timerManager.isExpired && !purchaseManager.hasPro && !remoteConfigManager.showLifeTimeBannerAtHome {
                        LifeTimeGiftOfferBannerView()
                            .padding(.top,ScaleUtility.scaledSpacing(20))
                    }
                    if !purchaseManager.hasPro {
                        TryProContainerView()
                            .padding(.top,ScaleUtility.scaledSpacing(20))
                    }
                    
                    SettingsCardsView()
                }
             
                
                
                Spacer()
            }
        }
      
    }
}
