//
//  ContentView.swift
//  PicVerse
//
//  Created by Neel Kalariya on 21/09/25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasFinishedOnboarding") var hasFinishedOnboarding: Bool = false
    @AppStorage("hasShownGiftPayWall") var hasShownGiftPayWall: Bool = false

    @EnvironmentObject var purchaseManager: PurchaseManager
    @EnvironmentObject var timerManager: TimerManager
    @EnvironmentObject var userDefault: UserSettings
    @EnvironmentObject var remoteConfigManager: RemoteConfigManager
    @State var isShowPayWall: Bool = false
    @State var isCollectGift: Bool = false
    
    var body: some View {
        ZStack {
            if remoteConfigManager.showForceUpdateAlert
            {
                ForceUpdateAlertView()
            }
            else
            {
                
                if hasFinishedOnboarding{
                    
                    MainView()
                        .frame(maxWidth:.infinity,maxHeight: .infinity)
                    
                }
                else if isShowPayWall && !purchaseManager.hasPro && remoteConfigManager.paywallAfterOnBoarding   {
                    PaywallView(dismissAction: {
                        
                        if remoteConfigManager.giftAfterOnBoarding {
                            isShowPayWall = false  // Hide Paywall
                            hasShownGiftPayWall = true   // Show Gift Screen after a short delay
                        }
                        else {
                            self.isShowPayWall = false
                            hasFinishedOnboarding = true
                        }
                        
                    }, isInternalOpen: false,
                                purchaseCompletSuccessfullyAction: {
                        hasFinishedOnboarding = true
                    })
                    
                }
                else if hasShownGiftPayWall && !purchaseManager.hasPro && !userDefault.isPaid && remoteConfigManager.giftAfterOnBoarding {
                    GiftView(isCollectGift: $isCollectGift) {
                        self.hasFinishedOnboarding = true
                    } giftPurchaseComplete: {
                        self.hasFinishedOnboarding = true
                    }
                    
                }
                else {
                    SwipeView(showPaywall: {
                        if purchaseManager.hasPro {
                            hasFinishedOnboarding = true
                        }
                        else{
                            
                            isShowPayWall = true
                        }
                    })
                }
                
            }
        }
        .onAppear {
            remoteConfigManager.fetchConfig { success in
                if success {
                    print("RemoteConfigManager initialized and data loaded successfully")
                } else {
                    print("RemoteConfigManager failed to load initial data")
                }
            }
            timerManager.setupCountdown()
            Task {
                await purchaseManager.fetchProducts()
                
            }
            
           
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            Task {
                await purchaseManager.updatePurchaseProducts()
            }
        }
    }
}
