import Foundation

import SwiftUI


struct LifeTimeGiftOfferBannerView: View {
    
    @EnvironmentObject var timerManager: TimerManager
    @EnvironmentObject var purchaseManager: PurchaseManager
    @EnvironmentObject var remoteConfigManager: RemoteConfigManager
    @EnvironmentObject var userDefaultSetting: UserSettings
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isPressed = false
    
    let notificationfeedback = UINotificationFeedbackGenerator()
    let impactfeedback = UIImpactFeedbackGenerator(style: .medium)
    let selectionfeedback = UISelectionFeedbackGenerator()
    
    var body: some View {
        
        if let product = purchaseManager.products.first(where: { $0.id == SubscriptionPlan.lifetime.productId }),
           let lifetimePlan = purchaseManager.products.first(where: { $0.id == SubscriptionPlan.yearly.productId }) {
            
            let discountPrice = product.displayPrice
            let originalPrice = lifetimePlan.displayPrice
            
            let discountedPriceValue = Double(discountPrice.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)) ?? 0
            let originalPriceValue = Double(originalPrice.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)) ?? 0
            
            let discountPercentage = originalPriceValue > 0 ? round((originalPriceValue - discountedPriceValue) / originalPriceValue * 100) : 0
            
            ZStack(alignment: .trailing) {
                HStack {
                    
                    VStack(alignment: .leading, spacing: ScaleUtility.scaledSpacing(0)) {
                        
                        Text("\(Int(discountPercentage))% off")
                            .font(FontManager.instrumentSansSemiBoldFont(size: .scaledFontSize(32)))
                            .foregroundColor(Color.secondaryApp)
                        
                        
                        Text("on Lifetime plan")
                            .font(FontManager.instrumentSansRegularFont(size: .scaledFontSize(18)))
                            .foregroundColor(Color.secondaryApp)
                        
                    }
                    .padding(.leading, ScaleUtility.scaledSpacing(25))
                    
                    Spacer()
               
                }
                
                VStack {
                    
                    Text("\(timerManager.hours) : \(String(format: "%02d", timerManager.minutes)) : \(String(format: "%02d", timerManager.seconds))")
                        .font(FontManager.instrumentSansMediumFont(size: .scaledFontSize(14)))
                        .foregroundColor(Color.secondaryApp)
                        .frame(width: isIPad ? ScaleUtility.scaledValue(130) :  90 , height: ScaleUtility.scaledValue(14))
                        .padding(.vertical, ScaleUtility.scaledValue(8))
                        .padding(.horizontal, ScaleUtility.scaledValue(14))
                        .background {
                            UnevenRoundedRectangle(
                                cornerRadii: RectangleCornerRadii(
                                    bottomLeading: ScaleUtility.scaledSpacing(10),
                                    bottomTrailing: ScaleUtility.scaledSpacing(10)
                                ),
                                style: .circular
                            )
                            .fill(Color.black.opacity(0.3))  // Changed from Color.accent.opacity(0.2)
                        }
                        .overlay(
                            UnevenRoundedRectangle(
                                cornerRadii: RectangleCornerRadii(
                                    bottomLeading: ScaleUtility.scaledSpacing(10),
                                    bottomTrailing: ScaleUtility.scaledSpacing(10)
                                ),
                                style: .circular
                            )
                            .stroke(Color.white.opacity(0.4), lineWidth: 1)  // Changed from Color.accent
                        )
                        .padding(.trailing, ScaleUtility.scaledSpacing(33))
                        .padding(.bottom, isIPad ? ScaleUtility.scaledSpacing(15) : 0)
                        .opacity(remoteConfigManager.showLifeTimeBannerAtHome ? 1 : 0)
                    
                    
                    Spacer()
                    
                    
                    Button {
                        impactfeedback.impactOccurred()
                        Task {
                            do {
                                try await purchaseManager.purchase(product)
                                //                                AnalyticsManager.shared.log(.giftBannerPlanPurchase)
                                
                            } catch {
                                print("Purchase failed: \(error)")
                                purchaseManager.isInProgress = false
                                purchaseManager.alertMessage = "Purchase Failed! Please try again or check your payment method."
                                purchaseManager.showAlert = true
                            }
                        }
                    }
                    label: {
                        
                        VStack {
                            if purchaseManager.isInProgress {
                                ProgressView()
                                    .tint(Color.primaryApp)
                            }
                            else{
                                HStack(spacing: ScaleUtility.scaledSpacing(10)) {
                                    Text(originalPrice)
                                        .font(FontManager.instrumentSansMediumFont(size: .scaledFontSize(14)))
                                        .foregroundColor(.primaryApp.opacity(0.5))
                                        .strikethrough()
                                    
                                    Text(discountPrice)
                                        .font(FontManager.instrumentSansMediumFont(size: .scaledFontSize(16)))
                                        .foregroundColor(.primaryApp)
                                    
                                }
                            }
                        }
                        .frame(width: isIPad ?  ScaleUtility.scaledValue(156.32716)  : ScaleUtility.scaledValue(133.77429), height: ScaleUtility.scaledValue(36))
                        .background(Color.white)
                        .cornerRadius(25)
                        .zIndex(1)
                        .shadow(
                            color: isPressed ? Color.black.opacity(0.1) : Color.black.opacity(0.3),
                            radius: isPressed ? 4 : 10,
                            x: 0,
                            y: isPressed ? 2 : 6
                        )
                        .scaleEffect(isPressed ? 0.96 : 1.0)
                        .offset(y: isPressed ? 2 : 0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
                        
                    }
                    .buttonStyle(PressButtonStyle(isPressed: $isPressed))
                    .zIndex(1)
                    .disabled(purchaseManager.isInProgress)
                    .padding(.bottom, isIPad ?  ScaleUtility.scaledSpacing(20)  : ScaleUtility.scaledSpacing(15))
                    .padding(.trailing, ScaleUtility.scaledSpacing(20))
                }
                
            }
            .alert(isPresented: $purchaseManager.showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(purchaseManager.alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .frame(maxWidth:.infinity)
            .frame(height: isIPad ?  ScaleUtility.scaledValue(131) * ipadHeightRation  : ScaleUtility.scaledValue(100) )
            .background(
                LinearGradient(
                    colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.7)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .cornerRadius(18)
                .shadow(color: .blue.opacity(0.4), radius: 8, x: 0, y: 4)
            )
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.secondaryApp, lineWidth: 1)
            )
            .padding(.horizontal, ScaleUtility.scaledSpacing(20))
           
        }
    }
}

