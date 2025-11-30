//
//  ProContainerView.swift
//  H2JPG
//
//  Created by Purvi Sancheti on 20/08/25.
//

import Foundation
import SwiftUI

struct TryProContainerView: View {
    
    @State var isShowPayWall: Bool = false
    let notificationfeedback = UINotificationFeedbackGenerator()
    let impactfeedback = UIImpactFeedbackGenerator(style: .heavy)
    let selectionfeedback = UISelectionFeedbackGenerator()
    @EnvironmentObject var purchaseManager: PurchaseManager
    @State private var isProContainerButtonPressed = false
    
    var body: some View {
        VStack(spacing: 0) {
            Button {
                impactfeedback.impactOccurred()
            
                    isShowPayWall = true
                
            } label: {
                HStack {
                    VStack(alignment: .leading,spacing:ScaleUtility.scaledSpacing(3)) {
                        Text("Access all features")
                            .font(FontManager.instrumentSansSemiBoldFont(size: isIPad ? .scaledFontSize(14) : .scaledFontSize(16)))
                            .foregroundColor(Color.secondaryApp)
                        
                        Text("Upgrade to pro")
                            .font(FontManager.instrumentSansSemiBoldFont(size: .scaledFontSize(12)))
                            .foregroundColor(Color.secondaryApp.opacity(0.6))
                        
                    }
                    .padding(.leading,ScaleUtility.scaledSpacing(17.48))
                    
                    Spacer()
                
                        Image(.tryProIcon)
                            .resizable()
                            .frame(width: ScaleUtility.scaledValue(104), height: ScaleUtility.scaledValue(35))
                            .padding(.trailing,ScaleUtility.scaledSpacing(16))
          
                    
                }
                .frame(maxWidth: .infinity)
                .frame(height: ScaleUtility.scaledValue(82))
                .background {
                        LinearGradient(
                            colors: [
                                Color.blue.opacity(0.15),
                                Color.purple.opacity(0.15),
                                Color.black.opacity(0.4)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .cornerRadius(20)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.blue.opacity(0.5),
                                    Color.purple.opacity(0.5)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                        .shadow(color: Color.blue.opacity(0.35), radius: 10, x: 0, y: 5)
                )
                .shadow(color: Color.black.opacity(0.3), radius: 12, x: 0, y: 6)
                .padding(.horizontal,ScaleUtility.scaledSpacing(20))
                
            }
            .buttonStyle(PlainButtonStyle())
            .scaleEffect(isProContainerButtonPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isProContainerButtonPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        withAnimation {
                            isProContainerButtonPressed = true
                        }
                    }
                    .onEnded { _ in
                        withAnimation {
                            isProContainerButtonPressed = false
                        }
                    }
            )
            .fullScreenCover(isPresented: $isShowPayWall) {
                
                PaywallView(dismissAction: {
                    isShowPayWall = false
                },
                            isInternalOpen: true,
                            purchaseCompletSuccessfullyAction: {
                    isShowPayWall = false
                })
                
            }
        }
    
    }
}

