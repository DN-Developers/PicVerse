//
// Paywall.swift
// GuidedMeditation
//
// Created by Radha Apps on 25/04/25.
//
import Foundation
import SwiftUI
import StoreKit

struct PaywallView: View {
    @StateObject private var userSettings = UserSettings()
    @EnvironmentObject var purchaseManager: PurchaseManager
    @EnvironmentObject var remoteConfigManager: RemoteConfigManager
    
    @State var selectedPlan = SubscriptionPlan.weekly
    @State var isShowCloseButton: Bool = false
    let dismissAction: () -> Void
    var isInternalOpen: Bool = false
    let purchaseCompletSuccessfullyAction: () -> Void

    let notificationfeedback = UINotificationFeedbackGenerator()
    let impactfeedback = UIImpactFeedbackGenerator(style: .medium)
    let selectionfeedback = UISelectionFeedbackGenerator()

    var body: some View {
  
        ZStack(alignment: .top) {

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
            .ignoresSafeArea(.all)
            .frame(maxWidth: .infinity,maxHeight: .infinity)
            
            ScrollView {
                Spacer()
                    .frame(height: ScaleUtility.scaledValue(15))
                
                VStack(alignment: .leading,spacing: ScaleUtility.scaledSpacing(24)) {
                    PaywallHeaderView(
                        isShowCloseButton: $isShowCloseButton,
                        isDisable: $purchaseManager.isInProgress,
                        restoreAction: {
                            purchaseManager.isInProgress = false
                            AnalyticsManager.shared.log(isInternalOpen ? .internalPaywallRestoreClicked : .firstPaywallRestoreClicked)
                            Task {
                                defer {
                                    purchaseManager.isInProgress = false
                                }
                                do {
                                    notificationfeedback.notificationOccurred(.success)
                                    purchaseManager.isInProgress = true
                                    try await AppStore.sync()
                                    await purchaseManager.updatePurchaseProducts(isRestore: true)
                                    AnalyticsManager.shared.log(isInternalOpen ? .internalPaywallPlanRestore(PlanDetails(planName: userSettings.planType)) : .firstPaywallPlanRestore(PlanDetails(planName: userSettings.planType)))
                                    if purchaseManager.hasPro {
                                        purchaseCompletSuccessfullyAction()
                                    }
                                } catch {
                                    notificationfeedback.notificationOccurred(.error)
                                    purchaseManager.showAlert = true
                                    purchaseManager.alertMessage = "Subscription Restore Failed!"
                                    purchaseManager.isInProgress = false
                                }
                                
                            }
                        }, closeAction: {
                            dismissAction()
                            if isInternalOpen {
                                AnalyticsManager.shared.log(.internalPaywallXClicked)
                            }
                            else {
                                AnalyticsManager.shared.log(.firstPaywallXClicked)
                            }
                        },
                        delayCloseButton: remoteConfigManager.isShowDelayPaywallCloseButton,
                        delaySeconds: Double(remoteConfigManager.closeButtonDelayTime))
                    
                    
                    
                    
                    VStack(alignment: .leading,spacing: ScaleUtility.scaledValue(22)) {
                        
                        VStack(alignment: .leading,spacing: ScaleUtility.scaledSpacing(15))
                        {
                            
                            SubscriptionOption(purchaseManager: _purchaseManager, selectedPlan: $selectedPlan, plan: .weekly)
                            
                            SubscriptionOption(purchaseManager: _purchaseManager, selectedPlan: $selectedPlan, plan: .yearly)
                            
                            SubscriptionOption(purchaseManager: _purchaseManager, selectedPlan: $selectedPlan, plan: .lifetime)
                            
                        }
                        
                        PayWallBottomView(
                            plan: selectedPlan,
                            isProcess: purchaseManager.isInProgress,
                            isDisable: purchaseManager.isInProgress,
                            isYearly:  selectedPlan == .yearly,
                            tryForFreeAction: {
                                AnalyticsManager.shared.log(isInternalOpen ? .internalPaywallPayButtonClicked(PlanDetails(planName: userSettings.planType)) : .firstPaywallPayButtonClicked(PlanDetails(planName: userSettings.planType)) )
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                Task {
                                    do {
                                        if let product = purchaseManager.products.first(where: {
                                            $0.id == selectedPlan.productId
                                        }) {
                                            notificationfeedback.notificationOccurred(.success)
                                            try await purchaseManager.purchase(product)
                                            if purchaseManager.hasPro {
                                                purchaseCompletSuccessfullyAction()
                                                AnalyticsManager.shared.log(isInternalOpen ? .internalPaywallPlanPurchase(PlanDetails(planName: userSettings.planType)) : .firstPaywallPlanPurchase(PlanDetails(planName: userSettings.planType)) )
                                            }
                                            
                                            
                                        } else {
                                            notificationfeedback.notificationOccurred(.error)
                                            print("No product")
                                            
                                        }
                                    } catch {
                                        notificationfeedback.notificationOccurred(.error)
                                        print("Purchase failed: \(error)")
                                        purchaseManager.isInProgress = false
                                        
                                    }
                                }
                            })
                        
                    }
                }
                .padding(.top, ScaleUtility.scaledSpacing(52))
                .padding(.horizontal, ScaleUtility.scaledSpacing(20))
                
                
                Spacer()
                    .frame(height: ScaleUtility.scaledValue(50))
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollIndicators(.hidden)
        }
        .ignoresSafeArea(.all)
        .frame(maxWidth: .infinity,maxHeight: .infinity)
        .onAppear {
            
            self.selectPlan(of: remoteConfigManager.defaultSubscriptionPlan)
            
            paywallLoading()
        }
        .alert(isPresented: $purchaseManager.showAlert) {
            Alert(title: Text("Restore Failed"), message: Text(purchaseManager.alertMessage), dismissButton: .default(Text("OK")))
        }
        
    }
        
    func selectPlan(of type: Int) {
        switch type {
        case 1:
            self.selectedPlan = SubscriptionPlan.weekly
        case 2:
            self.selectedPlan = SubscriptionPlan.yearly
        case 3:
            self.selectedPlan = SubscriptionPlan.lifetime
        default:
            self.selectedPlan = SubscriptionPlan.weekly
        }
    }
    func paywallLoading() {
        if remoteConfigManager.isShowPaywallCloseButton {
              self.isShowCloseButton = true
          } else {
              self.isShowCloseButton = false
          }
    }
}
