//
//  OnboardingTwoView.swift
//  WPIX
//
//  Created by Purvi Sancheti on 27/10/25.
//

import Foundation
import SwiftUI


struct OnboardingTwoView: View {
    @State private var textOffset: CGFloat = -UIScreen.main.bounds.width
    @State private var textOpacity: Double = 0
    @State private var imageScale: CGFloat = 0.3
    @Binding var isAppears: Bool 
    var isActive: Bool
    
    var body: some View {
        ZStack(alignment: .center) {
            
            // MARK: - Background with inverted gradient
            LinearGradient(
                colors: [Color(hex: "0C0F1A"), Color(hex: "050510")], // Reversed order
                startPoint: .bottom,  // Changed from .topLeading
                endPoint: .top        // Changed to .top
            )
            .overlay(
                RadialGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.2), .clear]),
                    center: .bottomTrailing, startRadius: 40, endRadius: 600)
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                if isAppears {
                    
                    Image(.intro3)
                        .resizable()
                        .frame(height: isIPad ? ScaleUtility.scaledValue(669) : isSmallDevice ? ScaleUtility.scaledValue(534.59) : ScaleUtility.scaledValue(466))
                        .frame(maxWidth: .infinity,alignment: .top)
                        .ignoresSafeArea(.all)
                        .transition(.opacity)
                    
                    
                }
                else {
                    Spacer()
                        .frame(height: isIPad ? ScaleUtility.scaledValue(669) : isSmallDevice ? ScaleUtility.scaledValue(534.59) : ScaleUtility.scaledValue(466))
                }
                
                Spacer()
            }
            
            
            VStack(spacing: ScaleUtility.scaledSpacing(10)) {
                
                Spacer()
                    .frame(height: isIPad ? ScaleUtility.scaledValue(500) : ScaleUtility.scaledValue(250))
                
              
                   VStack(spacing: ScaleUtility.scaledSpacing(16)) {
                       Text("Transform photos\n into any format")
                           .font(FontManager.instrumentSansRegularFont(size: .scaledFontSize(32)))
                           .multilineTextAlignment(.center)
                           .foregroundColor(.secondaryApp)
                       
                       
                       Text("Save or share your images in seconds,\n ready for every app and every device.")
                           .font(FontManager.instrumentSansRegularFont(size: .scaledFontSize(16)))
                           .foregroundColor(.secondaryApp.opacity(0.6))
                       
                   }
                   .offset(x: textOffset)
                   .opacity(textOpacity)
                
            }
  
        }
        .frame(maxWidth: .infinity,maxHeight: .infinity)
        .onChange(of: isActive) { oldValue, newValue in
            if newValue {
                print("OnboardingTwo is now ACTIVE")
                performAnimation()
            }
        }
        .onAppear {
            // Only animate if already active on first appear
            if isActive {
                print("OnboardingTwo appeared while active")
                performAnimation()
            }
        }
    }
    
    private func performAnimation() {
        
//        self.isAppears = false
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//            withAnimation(.interpolatingSpring(stiffness: 100, damping: 13)) {
//                self.isAppears = true
//            }
//        }
        
        self.isAppears = false
           DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
               withAnimation(.easeInOut(duration: 0.6)) {
                   self.isAppears = true
               }
           }
        
        // Reset to initial state WITHOUT animation
        textOffset = -UIScreen.main.bounds.width
        textOpacity = 0
        imageScale = 0.3
        
        // Wait a tiny bit, then animate
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            // Text slide-in animation from left
            withAnimation(.spring(response: 1.5, dampingFraction: 0.7, blendDuration: 0)) {
                textOffset = 0
                textOpacity = 1
            }
            
            // Image bounce animation with delay
            withAnimation(.spring(response: 1.0, dampingFraction: 0.5, blendDuration: 0).delay(0.3)) {
                imageScale = 1.0
            }
        }
    }
}
