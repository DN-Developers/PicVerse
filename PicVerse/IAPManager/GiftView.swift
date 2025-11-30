//
//  GiftScreen.swift
//  PicMate
//
//  Created by Darsh Viroja on 12/05/25.
//

import Foundation
import SwiftUI

struct GiftView: View {
    
    @EnvironmentObject var timerManager: TimerManager
    @EnvironmentObject var purchaseManager: PurchaseManager
    @Binding var isCollectGift: Bool
    @State var plan = SubscriptionPlan.lifetime
    let closeGift: () -> Void
    let giftPurchaseComplete: () -> Void
    
    @State var isShowImage: Bool = false
    
    let notificationfeedback = UINotificationFeedbackGenerator()
    let impactfeedback = UIImpactFeedbackGenerator(style: .medium)
    let selectionfeedback = UISelectionFeedbackGenerator()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
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
         
            VStack(spacing: ScaleUtility.scaledSpacing(103)) {
                
                VStack(spacing: ScaleUtility.scaledSpacing(15)) {
                    
                    HStack{
                        Spacer()
                        
                        Button {
                            withAnimation(.easeOut(duration: 0.1)) {
                                impactfeedback.impactOccurred()
                                closeGift()
                                
                            }
                        } label: {
                            Image(.closeIcon)
                                .resizable()
                                .frame(width: isIPad ? ScaleUtility.scaledValue(30) : ScaleUtility.scaledValue(23), height: isIPad ? ScaleUtility.scaledValue(30) : ScaleUtility.scaledValue(23)) //
                                .opacity(0.8)
                                .padding(.trailing, ScaleUtility.scaledSpacing(20))
                        }
                    }
                    
                    
                    VStack(spacing: ScaleUtility.scaledSpacing(28)) {
                        Text("Collect Gift!!")
                            .font(FontManager.instrumentSansMediumFont(size: .scaledFontSize(35)))
                            .foregroundColor(Color.white.opacity(0.5))
                        
                        if let product = purchaseManager.products.first(where: { $0.id == SubscriptionPlan.lifetimegiftplan.productId }),
                           let lifetimePlan = purchaseManager.products.first(where: { $0.id == SubscriptionPlan.lifetime.productId }) {
                            
                            let discountPrice = product.displayPrice
                            let originalPrice = lifetimePlan.displayPrice
                            
                            //Extract numerical value from the prices
                            let discountedPriceValue = Double(discountPrice.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)) ?? 0
                            let originalPriceValue = Double(originalPrice.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)) ?? 0
                            
                            //calculate the discount percentage
                            let discountPercentage = originalPriceValue > 0 ? Int(round((originalPriceValue - discountedPriceValue) / originalPriceValue * 100)) : 0
                            
                                
                                Text("\(discountPercentage)% off on\n Yearly Plan")
                                    .font(FontManager.instrumentSansBoldFont(size: .scaledFontSize(44)))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(Color.white)
                            }
                        
                    }
                }
                .padding(.top, isIPad ?  ScaleUtility.scaledSpacing(38) : ScaleUtility.scaledSpacing(8))
                
                Image(.giftIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: isIPad ? ScaleUtility.scaledValue(294) : ScaleUtility.scaledValue(195.65),
                           height: isIPad ? ScaleUtility.scaledValue(282) : ScaleUtility.scaledValue(188.18) )
                    .offset(y:ScaleUtility.scaledSpacing(10))
                    .scaleEffect(isShowImage ? 1.0 : 0.5)
                    .opacity(isShowImage ? 1.0 : 0.0)
                
                Spacer()
                
                
            }
            VStack(spacing: ScaleUtility.scaledSpacing(24)) {
                
                VStack(spacing: ScaleUtility.scaledSpacing(8)) {
                    
                    Text("Expires in")
                        .font(FontManager.instrumentSansRegularFont(size: .scaledFontSize(16)))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.secondaryApp)
                    
                    
                    Text("\(timerManager.hours) : \(String(format: "%02d", timerManager.minutes))")
                        .font(FontManager.instrumentSansSemiBoldFont(size: .scaledFontSize(32)))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.secondaryApp)
                }
                
                Button(action: {
                    impactfeedback.impactOccurred()
                    self.isCollectGift = true
                }) {
                    ZStack {
                        Image(.buttonBg)
                            .resizable()
                            .frame(height: ScaleUtility.scaledValue(52))
                            .frame(maxWidth: .infinity)
                      
                        Text("Collect Gift")
                            .font(.system(size:.scaledFontSize(14)))
                            .fontWeight(.medium)
                            .foregroundColor(.secondaryApp)
                    }
                    .padding(.horizontal, isIPad ? ScaleUtility.scaledSpacing(100) : ScaleUtility.scaledSpacing(50))
                }
                
      
              
            }
            .padding(.bottom,ScaleUtility.scaledSpacing(10))
            
        }
        .frame(maxWidth:.infinity,maxHeight: .infinity)
        .blur(radius: isCollectGift ? 25 : 0 )
        .sheet(isPresented: $isCollectGift) {
          
            GiftPaywallBottomView(
                closeGiftSheet: {
                    self.isCollectGift = false
                    //                        AnalyticsManager.shared.log(.giftBottomSheetXClicked)
                }, purchaseConfirm: giftPurchaseComplete)
            .frame(height: isIPad ? ScaleUtility.scaledValue(422) : ScaleUtility.scaledValue(322) )
            .background {
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
            }
            .presentationDetents([.height( isIPad ? ScaleUtility.scaledValue(422) : ScaleUtility.scaledValue(322))])
            .presentationBackground(Color.black)
            
        }
        .onAppear {
            performAnimation()
        }
    
    }
    
    
    func performAnimation() {
        self.isShowImage = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.interpolatingSpring(stiffness: 100, damping: 15).delay(0.2)) {
                isShowImage = true
            }
        }
        
    }
}

// Paywall Bottom Sheet View

// Countdown Timer Formatter
func formatTime(_ seconds: Int) -> String {
    let hours = seconds / 3600
    let minutes = (seconds % 3600) / 60
    let seconds = seconds % 60
    return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
}



