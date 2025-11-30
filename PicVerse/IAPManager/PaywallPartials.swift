
import Foundation
import SwiftUI
import StoreKit

//MARK: - Paywall Header View

struct PaywallHeaderView: View {
    @EnvironmentObject var purchaseManager: PurchaseManager
    @EnvironmentObject var remoteConfigManager: RemoteConfigManager
    
    @Binding var isShowCloseButton: Bool
    @Binding var isDisable: Bool
    let restoreAction: () -> Void
    let closeAction: () -> Void
    var isInternalOpen: Bool = false
    
    var delayCloseButton: Bool = false
    var delaySeconds: Double
    
    let impactfeedback = UIImpactFeedbackGenerator(style: .medium)
    
    @State private var isRestorePressed = false
    @State private var isCrossPressed = false
    
    @State private var isCountdownFinished = false   // NEW
    @State private var hasStartedCountdown = false   // NEW
    
    @State private var closeProgress: CGFloat = 0
    
    @State private var showXButton = false
    
    var body: some View {
        
        VStack(spacing: ScaleUtility.scaledSpacing(24)) {
            
            HStack(spacing: 0) {
                Button {
                    impactfeedback.impactOccurred()
                    restoreAction()
                } label: {
                    Text("Restore")
                        .font(FontManager.instrumentSansSemiBoldFont(size: .scaledFontSize(14)))
                        .foregroundColor(.secondaryApp)
                    
                }
                .buttonStyle(PlainButtonStyle())
                .scaleEffect(isRestorePressed ? 0.95 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isRestorePressed)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            withAnimation {
                                isRestorePressed = true
                            }
                        }
                        .onEnded { _ in
                            withAnimation {
                                isRestorePressed = false
                            }
                        }
                )
                
                
                
                Spacer()
                
                if remoteConfigManager.isShowPaywallCloseButton {
                    if remoteConfigManager.isShowDelayPaywallCloseButton && showXButton {
                        Button {
                            impactfeedback.impactOccurred()
                            closeAction()
                        } label: {
                            Image(.closeIcon)
                                .resizable()
                                .frame(width: isIPad ? ScaleUtility.scaledValue(30) : ScaleUtility.scaledValue(23), height: isIPad ? ScaleUtility.scaledValue(30) : ScaleUtility.scaledValue(23)) //
                        
                        }
                        
                    }
                    else {
                        Button {
                            
                            impactfeedback.impactOccurred()
                            closeAction()
                        } label: {
                            
                            Image(.closeIcon)
                                .resizable()
                                .frame(width: ScaleUtility.scaledValue(24), height: ScaleUtility.scaledValue(24))
                                .padding(.all,ScaleUtility.scaledSpacing(10))
                            
                        }
                        
                    }
                }
                
            }
            .frame(height: 24 * heightRatio)
            
            
            
            VStack(spacing: ScaleUtility.scaledSpacing(46)) {
                VStack(spacing: ScaleUtility.scaledSpacing(24)) {
                    Text("Unlock PicVerse Pro")
                        .font(FontManager.instrumentSansBoldFont(size: .scaledFontSize(32)))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.secondaryApp)
                        .frame(maxWidth: .infinity)
                    
                    
                    VStack(alignment: .leading, spacing: isIPad ? ScaleUtility.scaledSpacing(26.5) : ScaleUtility.scaledSpacing(16.5)) {
                        ForEach(Array(PremiumFeature.allCases.enumerated()), id: \.element.title) { index, feature in
                            PaywallPremiumFeatureContainerView(feature: feature, index: index)
                        }
                    }
                    
                }
                
            }
            
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
                showXButton = true
            }
        }
    }
}

//MARK: - Paywall Premium Features Container View

struct PaywallPremiumFeatureContainerView: View {
    let feature: PremiumFeature
    let index: Int
    @State private var isVisible = false
    var body: some View {
        HStack(spacing: ScaleUtility.scaledSpacing(10)) {
            Image(feature.image)
                .resizeImage()
                .frame(width: 23.96 * widthRatio,
                       height: 23.96 * heightRatio)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(feature.title)
                    .font(FontManager.instrumentSansMediumFont(size: .scaledFontSize(16)))
                    .kerning(0.2)
                    .foregroundStyle(Color.secondaryApp)
                
                Text(feature.subTitle)
                    .font(FontManager.instrumentSansRegularFont(size: .scaledFontSize(14)))
                    .kerning(0.2)
                    .foregroundStyle(Color.secondaryApp)
      
            }
          
         }
        .opacity(isVisible ? 1 : 0)
        .offset(x: isVisible ? 0 : -20)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(Double(index) * 0.50)) {
                isVisible = true
            }
        }
        .frame(maxWidth: .infinity,alignment: .leading)
        .padding(.leading, ScaleUtility.scaledSpacing(12))
     }
}



struct SubscriptionOption: View {
    @EnvironmentObject var remoteConfigManager: RemoteConfigManager
    @EnvironmentObject var purchaseManager: PurchaseManager
    @Binding var selectedPlan: SubscriptionPlan
    let plan: SubscriptionPlan


    let selectionFeedback = UISelectionFeedbackGenerator()
    
    var body: some View {
        if let product = purchaseManager.products.first(where: { $0.id == plan.productId }) {
        Button {
            withAnimation {
                selectionFeedback.selectionChanged()
                selectedPlan = plan
            }
        } label: {
         
            ZStack(alignment: .topTrailing) {
                
                HStack {
                    
                    VStack(alignment: .leading,spacing: ScaleUtility.scaledSpacing(5))
                    {
                        Text(plan.planName.capitalized)
                            .font(FontManager.instrumentSansMediumFont(size: .scaledFontSize(16)))
                            .foregroundColor(Color.secondaryApp)
                            .kerning(0.2)
                        
                        Text(trialPeriodText(for: plan, product: product))
                            .font(FontManager.instrumentSansRegularFont(size: .scaledFontSize(12)))
                            .foregroundColor(Color.secondaryApp)
                            .kerning(0.2)
                      
                    }
                    
                    Spacer()
                }
                
                Text(displayPriceText(for: plan, product: product) + planSubtitle)
                    .font(FontManager.instrumentSansMediumFont(size: .scaledFontSize(16)))
                    .foregroundColor(Color.secondaryApp)
                    .kerning(0.2)
//                    .padding(.top, ScaleUtility.scaledSpacing(20))
            }
            .padding(.all, ScaleUtility.scaledSpacing(15))
            .frame(height: isIPad ? ScaleUtility.scaledValue(93) : ScaleUtility.scaledValue(73))
            .frame(maxWidth:.infinity)
            .background {
                if selectedPlan == plan  {
                    Image(.selectedBg)
                        .resizable()
                        .frame(height: isIPad ? ScaleUtility.scaledValue(93) : ScaleUtility.scaledValue(73))
                        .frame(maxWidth:.infinity)
                }
                else {
                    Image(.unselectedBg)
                        .resizable()
                        .frame(height: isIPad ? ScaleUtility.scaledValue(93) : ScaleUtility.scaledValue(73))
                        .frame(maxWidth:.infinity)
                }
            }
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: isIPad ? 24 : 16)
                    .stroke(selectedPlan == plan ? Color.appPurple : Color.secondaryApp.opacity(0.1),lineWidth: 2)
            )
            
        }
      }
    }
    
    
    func displayPriceText(for plan: SubscriptionPlan, product: Product) -> String {
        switch plan {
        case .weekly:
          return product.displayPrice
        case .yearly:
          let price = product.price
            if remoteConfigManager.isApproved {
            let weekPrice = price / 52
            return weekPrice.formatted(product.priceFormatStyle)
          } else {
            return product.displayPrice
          }
        case .weekly:
          return product.displayPrice
        case .yearly:
          return product.displayPrice
        case .lifetime:
            return product.displayPrice
        case .lifetimegiftplan:
            return product.displayPrice
        }
      }
    
    var planSubtitle: String {
        switch plan {
        case .weekly:
          return "/week"
        case .lifetime:
          return "/once"
        case .yearly:
          if remoteConfigManager.isApproved {
            return "/week"
          } else {
            return "/year"
          }
        case .lifetimegiftplan:
          return "/once"
        }
      }
    
    func trialPeriodText(for plan: SubscriptionPlan, product: Product) -> String {
        let trialPeriod = product.subscription?.introductoryOffer?.period
         
        switch plan {
        case .weekly:
          if let trialPeriod = trialPeriod {
            return "Free for \(trialPeriod) Days, then only \(product.displayPrice)/week"
          } else {
            return "Start with the cheapest"
          }
        case .yearly:
          if let trialPeriod = trialPeriod {
              return "Free for \(trialPeriod), then only \(product.displayPrice)/year"
          } else {
            return "For Full Year"
          }
        case .lifetime:
          return "One-time offer. Redeem Now"
            
        case .lifetimegiftplan:
          return "Yours forever, No subscription needed!"

        }
      }
    
}



//MARK: - Paywall Bottom View

struct PayWallBottomView: View {
//    @EnvironmentObject var remoteConfigManager: RemoteConfigManager
    @EnvironmentObject var remoteConfigManager: RemoteConfigManager
    @EnvironmentObject var purchaseManager: PurchaseManager
    
    let plan: SubscriptionPlan
    @Environment(\.openURL) var openURL
    let isProcess: Bool
    let isDisable: Bool
    let isYearly: Bool
    let tryForFreeAction: () -> Void

    let impactfeedback = UIImpactFeedbackGenerator(style: .medium)
    @State private var isContinuePressed = false
    @State private var isPrivacyPressed = false
    @State private var isTermsPressed = false
        
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            VStack(spacing: ScaleUtility.scaledSpacing(25)) {
                
                VStack(spacing: ScaleUtility.scaledSpacing(15)) {
                    
                    if let product = purchaseManager.products.first(where: { $0.id == plan.productId }) {
                        
                        Text("\(subText(for: plan, product: product))")
                            .font(FontManager.instrumentSansRegularFont(size: .scaledFontSize(13)))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color.secondaryApp.opacity(0.5))
                    }
                    
                    Button {
                        tryForFreeAction()
                    } label: {
                        
                        ZStack {
                            Image(.buttonBg2)
                                .resizable()
                                .frame(height: ScaleUtility.scaledValue(52))
                                .frame(maxWidth: .infinity)
                          
                            if purchaseManager.isInProgress {
                            
                                ProgressView()
                                    .tint(Color.secondaryApp)
                       
                            } else {
                               
                                HStack(spacing: ScaleUtility.scaledSpacing(5)) {
                                    Text(remoteConfigManager.freeTrialPlan && isYearly ? "Continue for Free" : "Continue")
                                        .font(FontManager.instrumentSansMediumFont(size: .scaledFontSize(16)))
                                        .kerning(0.2)
                                        .foregroundColor(Color.secondaryApp)
                                    
                                    Image(.rightArrowIcon)
                                        .resizable()
                                        .frame(width: ScaleUtility.scaledValue(24),height: ScaleUtility.scaledValue(24))
                                }
                                   
                            }
                        }
                        
          
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(isProcess)
                    .scaleEffect(isContinuePressed ? 0.95 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isContinuePressed)
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                withAnimation {
                                    isContinuePressed = true
                                }
                            }
                            .onEnded { _ in
                                withAnimation {
                                    isContinuePressed = false
                                }
                            }
                    )
               
                    
                    if isYearly {
                        
                        Text("🔥 No Payment now")
                            .font(FontManager.instrumentSansRegularFont(size: .scaledFontSize(14)))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color.secondaryApp)
                        
                    }
                    
                }
                
                HStack {
                    
                    Text("Cancel Anytime")
                        .font(FontManager.instrumentSansSemiBoldFont(size: .scaledFontSize(12)))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.secondaryApp.opacity(0.8))
                    
                    Spacer()
                    
                    Button {
                        impactfeedback.impactOccurred()
                        openURL(URL(string: AppConstant.privacyURL)!)
                    } label: {
                        
                        Text("Privacy Policy")
                            .font(FontManager.instrumentSansSemiBoldFont(size: .scaledFontSize(12)))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color.secondaryApp.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    Button {
                        impactfeedback.impactOccurred()
                        openURL(URL(string: AppConstant.termsAndConditionURL)!)
                    } label: {
                        
                        Text("Terms of use")
                            .font(FontManager.instrumentSansSemiBoldFont(size: .scaledFontSize(12)))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color.secondaryApp.opacity(0.8))
                    }
                    
                }
               
                
                Text("Premium membership unlocks all the packs and content. This is an auto-renew subscription. Subscriptions will automatically renew and you will be charged for renewal within 24 hours prior to end of each period unless auto renew is tuned off at least 24-hours before the end of each period. You can manage your subscription settings and auto-renewal may turned off by going to Apple ID Account Settings after purchase.")
                    .font(FontManager.instrumentSansRegularFont(size: .scaledFontSize(8)))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.secondaryApp)
            }
        }

    }

    
    func subText(for plan: SubscriptionPlan, product: Product) -> String {
        let trialPeriod = product.subscription?.introductoryOffer?.period
         
        switch plan {
        case .weekly:
            return "Auto-renews at \(product.displayPrice)/week"
          
        case .yearly:
            return "Auto-renews at \(product.displayPrice)/year"
        
        case .lifetime:
          return "🔥 One time payment only"
            
        case .lifetimegiftplan:
          return "Yours forever, No subscription needed!"

        }
      }
    
}
