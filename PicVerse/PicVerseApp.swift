//
//  PicVerseApp.swift
//  PicVerse
//
//  Created by Neel Kalariya on 21/09/25.
//

import SwiftUI
import SDWebImage
import SDWebImageWebPCoder
import Photos
import Firebase

@main
struct PicVerseApp: App {
    let persistenceController = PersistenceController.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var userSettings = UserSettings()
    @StateObject private var purchaseManager = PurchaseManager()
    @StateObject private var timerManager = TimerManager()
    @StateObject var remoteConfigManager = RemoteConfigManager()
    
    init() {
        registerAllCoders()
        
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(userSettings)  // ✅ Inject UserSettings
                .environmentObject(purchaseManager)
                .environmentObject(timerManager)
                .environmentObject(remoteConfigManager)
        }
    }
    
    func registerAllCoders() {
        let manager = SDImageCodersManager.shared
        manager.addCoder(SDImageWebPCoder.shared)
    }

}
