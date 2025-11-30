//
//  AppDelegate.swift
//  PicVerse
//
//  Created by Neel Kalariya on 21/09/25.
//

import Foundation
import UIKit
import IQKeyboardManagerSwift
import UserNotifications
import AVFAudio

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        
        // MARK: - Notification Center Delegate Setup
        UNUserNotificationCenter.current().delegate = self
        
        // MARK: - Keyboard Setup
        IQKeyboardManager.shared.isEnabled = false
        IQKeyboardManager.shared.enableAutoToolbar = true // enables "Done" button
        IQKeyboardManager.shared.resignOnTouchOutside = true // tap outside to dismiss
      
        
        do {
          let session = AVAudioSession.sharedInstance()
          try session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
          try session.setActive(true)
        } catch {
          print("Audio session setup failed: \(error)")
        }


        return true
    }
    
}
