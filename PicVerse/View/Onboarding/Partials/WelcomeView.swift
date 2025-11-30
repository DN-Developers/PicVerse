//
//  WelcomeView.swift
//  WPIX
//
//  Created by Purvi Sancheti on 27/10/25.
//

import Foundation
import SwiftUI

struct WelcomeView: View {
    @State private var textOffset: CGFloat = -UIScreen.main.bounds.width
    @State private var textOpacity: Double = 0
    @State private var imageScale: CGFloat = 0.3
    @Binding var isAppears: Bool 
    
    var isActive: Bool
    
    var body: some View {
        
        ZStack(alignment: .center) {
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
                if isAppears {
                    
                    Image(.intro1)
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
                    Text("Pick your favorite\n shots with ease")
                        .font(FontManager.instrumentSansRegularFont(size: .scaledFontSize(32)))
                        .foregroundColor(.secondaryApp)
                    
                    
                    Text("Choose from Files or Photos\n and start your photo journey effortlessly.")
                        .font(FontManager.instrumentSansRegularFont(size: .scaledFontSize(16)))
                        .foregroundColor(.secondaryApp.opacity(0.6))
                    
                }
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .offset(x: textOffset)
                .opacity(textOpacity)
                
               
            }
            
            
            
        }
        .frame(maxWidth: .infinity,maxHeight: .infinity)
        .onChange(of: isActive) { oldValue, newValue in
            if newValue {
                performAnimation()
            }
        }
        .onAppear {
            if isActive {
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
//
        self.isAppears = false
           DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
               withAnimation(.easeInOut(duration: 0.6)) {
                   self.isAppears = true
               }
           }
        
        textOffset = -UIScreen.main.bounds.width
        textOpacity = 0
        imageScale = 0.3
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.spring(response: 1.5, dampingFraction: 0.7, blendDuration: 0)) {
                textOffset = 0
                textOpacity = 1
            }
            
            withAnimation(.spring(response: 1.0, dampingFraction: 0.5, blendDuration: 0).delay(0.3)) {
                imageScale = 1.0
            }
        }
    }
}
