//
//  RatingView.swift
//  WPIX
//
//  Created by Purvi Sancheti on 27/10/25.
//

import Foundation
import SwiftUI
import StoreKit

struct RatingView: View {
    var isActive: Bool
    
    @State var isShowImage: Bool = false
    @State var isShowTitle: Bool = false
    @State var isShowSubtitle: Bool = false
    
    var body: some View {
        ZStack {
            
            // MARK: - Background with inverted gradient
            LinearGradient(
                colors: [Color(hex: "050510"), Color(hex: "0C0F1A")],
                startPoint: .bottom,
                endPoint: .top
            )
            .overlay(
                RadialGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.2), .clear]),
                    center: .bottomTrailing, startRadius: 40, endRadius: 600)
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
            
            VStack(spacing: ScaleUtility.scaledSpacing(59)) {
                
                VStack(spacing: ScaleUtility.scaledSpacing(10)) {
                    
                    Text("Thanks for your\n support")
                        .font(FontManager.instrumentSansRegularFont(size: .scaledFontSize(32)))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondaryApp)
                        .scaleEffect(isShowTitle ? 1.0 : 0.5)
                        .opacity(isShowTitle ? 1.0 : 0.0)
                    
                    
                    Text("You're helping the world convert\n images - one rating at a time.")
                        .font(FontManager.instrumentSansRegularFont(size: .scaledFontSize(16)))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondaryApp)
                        .scaleEffect(isShowSubtitle ? 1.0 : 0.5)
                        .opacity(isShowSubtitle ? 1.0 : 0.0)
                }
                .padding(.top, ScaleUtility.scaledSpacing(76))
                
                
                Image(.heartIcon)
                    .resizable()
                    .frame(width: isIPad ? ScaleUtility.scaledValue(603) : ScaleUtility.scaledValue(303),
                           height: isIPad ?  ScaleUtility.scaledValue(603) : ScaleUtility.scaledValue(303))
                    .scaleEffect(isShowImage ? 1.0 : 0.5)
                    .opacity(isShowImage ? 1.0 : 0.0)
                
            }
            
            Spacer()
            
        }
            
        }
        .frame(maxWidth: .infinity,maxHeight: .infinity)
        .onAppear {
            performAnimation()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
            {
                showRatingPopup()
            }
            
        }
    }
    
    func showRatingPopup() {
        let userSettings = UserSettings() // Get user settings instance
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
            if userSettings.ratingPopupCount < 1  {
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                    
                    // Increment the rating count
                    userSettings.ratingPopupCount += 1
                    

                }
            }
        }
    }
    
    func performAnimation() {
        self.isShowTitle = false
        self.isShowSubtitle = false
        self.isShowImage = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.interpolatingSpring(stiffness: 100, damping: 15).delay(0.2)) {
                isShowTitle = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.interpolatingSpring(stiffness: 100, damping: 15).delay(0.2)) {
                isShowSubtitle = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.interpolatingSpring(stiffness: 100, damping: 15).delay(0.2)) {
                isShowImage = true
            }
        }
        
    }
    
}
