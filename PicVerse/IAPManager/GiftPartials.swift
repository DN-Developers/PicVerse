//
//  GiftPartials.swift
//  PicVerse
//
//  Created by Neel Kalariya on 28/09/25.
//

import Foundation
import SwiftUI


struct GiftPaywallBottomView: View {
    @EnvironmentObject var purchaseManager: PurchaseManager
    @EnvironmentObject var timerManager: TimerManager
    let closeGiftSheet: () -> Void
    let purchaseConfirm: () -> Void
    
    let notificationfeedback = UINotificationFeedbackGenerator()
    let impactfeedback = UIImpactFeedbackGenerator(style: .medium)
    let selectionfeedback = UISelectionFeedbackGenerator()
    
    var body: some View {
        if let product = purchaseManager.products.first(where: { $0.id == SubscriptionPlan.lifetimegiftplan.productId }),
           let lifetimePlan = purchaseManager.products.first(where: { $0.id == SubscriptionPlan.lifetime.productId }) {
            
            let discountPrice = product.displayPrice
            let originalPrice = lifetimePlan.displayPrice
            
            //Extract numerical value from the prices
            let discountedPriceValue = Double(discountPrice.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)) ?? 0
            let originalPriceValue = Double(originalPrice.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)) ?? 0
            
            //calculate the discount percentage
            let discountPercentage = originalPriceValue > 0 ? Int(round((originalPriceValue - discountedPriceValue) / originalPriceValue * 100)) : 0
            
            ZStack {
                
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
                
                VStack(spacing: ScaleUtility.scaledSpacing(24)) {
                    VStack(spacing: ScaleUtility.scaledSpacing(8)) {
                        HStack(spacing: 0) {
                            Spacer()
                                .frame(width: 24 * widthRatio)
                            Spacer()
                            
                            Text("SPECIAL OFFER")
                                .font(FontManager.instrumentSansMediumFont(size: .scaledFontSize(16)))
                                .foregroundStyle(.white)
                                .frame(height: 19 * heightRatio)
                                .padding(.horizontal, ScaleUtility.scaledSpacing(20))
                                .padding(.vertical, ScaleUtility.scaledSpacing(5))
                                .frame(height: 29 * heightRatio)
                                .background {
                                    RoundedRectangle(cornerRadius: .infinity)
                                        .fill(Color.white.opacity(0.1))
                                }
                            Spacer()
                            
                            Button {
                                closeGiftSheet()
                                //                    AnalyticsManager.shared.log(.giftBottomSheetXClicked)
                                impactfeedback.impactOccurred()
                            } label: {
                                
                                Image(.closeIcon)
                                    .resizeImage()
                                    .frame(width: 24 * widthRatio, height: 24 * heightRatio)
                            }
                            .disabled(purchaseManager.isInProgress)
                            .padding(.trailing,ScaleUtility.scaledSpacing(15))
                        }
                        
                        
                        Text(" Get this exclusive offer \n to gain full app benefits. ")
                            .font(FontManager.instrumentSansRegularFont(size: .scaledFontSize(16)))
                            .foregroundStyle(.white)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(height: 38 * heightRatio)
                        
                        
                        HStack(spacing: ScaleUtility.scaledSpacing(8)) {
                            Image(.collectGiftIcon)
                                .resizeImage()
                                .frame(width: 36 * widthRatio, height: 36 * heightRatio)
                            
                            Text("\(discountPercentage)% OFF")
                                .font(FontManager.instrumentSansRegularFont(size: .scaledFontSize(32)))
                                .foregroundStyle(.white)
                                .frame(height: 55 * heightRatio)
                            
                            Image(.collectGiftIcon)
                                .resizeImage()
                                .frame(width: 36 * widthRatio, height: 36 * heightRatio)
                        }
                        .frame(height: 38 * heightRatio)
                        
                    }
                    .frame(height: 121 * heightRatio)
                    
                    
                    ZStack(alignment: .topTrailing) {
                        HStack {
                            VStack(alignment: .leading, spacing: ScaleUtility.scaledSpacing(5)) {
                                Text("Lifetime")
                                    .font(FontManager.instrumentSansMediumFont(size: .scaledFontSize(16)))
                                    .kerning(0.2)
                                    .foregroundColor(Color.white)
                                
                                Text("One time offer - redeem now")
                                    .font(FontManager.instrumentSansRegularFont(size: .scaledFontSize(14)))
                                    .foregroundColor(Color.white)
                                
                             
                                
                            }
                            Spacer()
                            
                            
                        }
                        
                        Text(discountPrice)
                            .font(FontManager.instrumentSansMediumFont(size: .scaledFontSize(16)))
                            .kerning(0.2)
                            .foregroundColor(.white)
                        
                    }
                    .padding(.horizontal, ScaleUtility.scaledSpacing(20))
                    .frame(height: ScaleUtility.scaledValue(73))
                    .frame(maxWidth: .infinity)
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: ScaleUtility.scaledValue(73))
                            .frame(maxWidth: .infinity)
                        
                        
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white.opacity(0.1),lineWidth: 2)
                    }
                    .padding(.horizontal, ScaleUtility.scaledSpacing(20))
                    
                    
                    Button {
                        impactfeedback.impactOccurred()
                        Task {
                            do {
                                try await purchaseManager.purchase(product)
                                if purchaseManager.hasPro {
                                    purchaseConfirm()
                                    //                                        AnalyticsManager.shared.log(.giftScreenPlanPurchase)
                                    notificationfeedback.notificationOccurred(.success)
                                }
                            } catch {
                                notificationfeedback.notificationOccurred(.error)
                                print("Purchase failed: \(error)")
                                purchaseManager.isInProgress = false
                                purchaseManager.alertMessage = "Purchase Failed! Please try again or check your payment method."
                                purchaseManager.showAlert = true
                            }
                        }
                    } label: {
                        
                        ZStack {
                            Image(.buttonBg2)
                                .resizable()
                                .frame(height: ScaleUtility.scaledValue(52))
                                .frame(maxWidth: .infinity)
                          
                            if purchaseManager.isInProgress {
                            
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                        .tint(.white)
                       
                            } else {
                               
                                Text("Claim Offer")
                                    .font(FontManager.instrumentSansMediumFont(size: .scaledFontSize(16)))
                                    .kerning(0.2)
                                    .foregroundColor(.secondaryApp)
                                   
                            }
                        }
                    }
                    .padding(.horizontal, ScaleUtility.scaledSpacing(20))
                }
                
            }
            .alert(isPresented: $purchaseManager.showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(purchaseManager.alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .ignoresSafeArea(.all)
            .background(.black)
        }
    }
}
