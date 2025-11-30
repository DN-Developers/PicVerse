//
//  RemoteConfigManager.swift
//  PicMate
//
//  Created by Darsh Viroja on 12/05/25.
//

import Foundation
import Firebase
import FirebaseRemoteConfig

class RemoteConfigManager: ObservableObject {
    static var shared = RemoteConfigManager()
    
    @Published var minimumAppVersion: String = "1.0"
    
    @Published var giftAfterOnBoarding:Bool = false
    @Published var paywallAfterOnBoarding:Bool = true

    @Published var isForceUpdateRequired: Bool = true
    @Published var showForceUpdateAlert: Bool = false
    
    @Published var isApproved: Bool = false
    @Published var isShowPaywallCloseButton: Bool = false
    @Published var isShowDelayPaywallCloseButton: Bool = false
    @Published var freeTrialPlan: Bool = false
    @Published var newPaywall: Bool = false
    @Published var showLifeTimeBannerAtHome: Bool = false
    
    
    
    @Published var freeConvertion:Int = 2
    @Published var closeButtonDelayTime: Int = 5
    @Published var defaultSubscriptionPlan: Int = 2

    
    
    init() {
        fetchConfig { success in
            if success {
                print("RemoteConfigManager initialized and data loaded successfully")
            } else {
                print("RemoteConfigManager failed to load initial data")
            }
        }
    }

    func fetchConfig(completion: @escaping (Bool) -> Void) {
        let remoteConfig = RemoteConfig.remoteConfig()
        
        remoteConfig.fetch(withExpirationDuration: 3600) { status, error in
            if status == .success {
                print("Remote Config fetch succeeded")
                remoteConfig.activate { change, error in
                    if let error = error {
                        print("Failed to activate Remote Config: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("Remote Config activated successfully")
                        self.updateValues()
                        completion(true)
                    }
                }
            } else {
                print("Failed to fetch Remote Config: \(error?.localizedDescription ?? "Unknown error")")
                completion(false)
            }
        }
    }
    
    func updateValues() {
        let remoteConfig = RemoteConfig.remoteConfig()
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        
        DispatchQueue.main.async {
            self.giftAfterOnBoarding = remoteConfig.configValue(forKey: "giftAfterOnBoarding").boolValue
            self.paywallAfterOnBoarding = remoteConfig.configValue(forKey: "paywallAfterOnBoarding").boolValue
            self.defaultSubscriptionPlan = remoteConfig.configValue(forKey: "defaultSubscriptionPlan").numberValue.intValue
  
            self.minimumAppVersion = remoteConfig.configValue(forKey: "minimumAppVersion").stringValue
            self.isForceUpdateRequired = remoteConfig.configValue(forKey: "isForceUpdateRequired").boolValue
            self.isApproved = remoteConfig.configValue(forKey: "isApproved").boolValue
            self.showLifeTimeBannerAtHome = remoteConfig.configValue(forKey: "showLifetimeBannerAtHome").boolValue
            self.isShowPaywallCloseButton = remoteConfig.configValue(forKey: "isShowPaywallCloseButton").boolValue
            self.isShowDelayPaywallCloseButton = remoteConfig.configValue(forKey: "isShowDelayPaywallCloseButton").boolValue
            self.freeTrialPlan = remoteConfig.configValue(forKey: "freeTrialPlan").boolValue
            self.newPaywall = remoteConfig.configValue(forKey: "newPaywall").boolValue
            
            self.closeButtonDelayTime = remoteConfig.configValue(forKey: "closeButtonDelayTime").numberValue.intValue
            
                  if self.isForceUpdateRequired && (currentVersion != self.minimumAppVersion) {
                      self.showForceUpdateAlert = true
                  }
            self.freeConvertion = remoteConfig.configValue(forKey: "freeConvertion").numberValue.intValue
        }
    }
}


