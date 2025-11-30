//
//  TimerManager.swift
//  PicMate
//
//  Created by Darsh Viroja on 12/05/25.
//

import Foundation
import Combine

class TimerManager: ObservableObject {
    @Published var hours: Int = 0
    @Published var minutes: Int = 0
    @Published var seconds: Int = 0
    @Published var isExpired: Bool = false
    
    private var cancellable: AnyCancellable?
    
    private let defaults = UserDefaults.standard
    private let countdownDuration: TimeInterval = 24 * 60 * 60
    
    init() {
        setupCountdown()
    }
    
    func setupCountdown() {
        // Check if the countdown has already expired
        if defaults.bool(forKey: "isCountdownExpired") {
            isExpired = true
            resetCountdown()
            return
        }
        
        // Check if we have a saved start date
        if let savedStartDate = defaults.object(forKey: "countdown_start_date") as? Date {
            let elapsed = Date().timeIntervalSince(savedStartDate)
            if elapsed >= countdownDuration {
                // Countdown has expired
                markAsExpired()
            } else {
                // calculate remaining time
                let remainingTime = countdownDuration - elapsed
                startCountdown(from: remainingTime)
            }
        } else {
            // First-time setup: save current date as start date
            let currentDate = Date()
            defaults.set(currentDate, forKey: "countdown_start_date")
            startCountdown(from: countdownDuration)
        }
    }
    
    private func startCountdown(from timeRemaining: TimeInterval) {
        updateTimerComponents(with: timeRemaining)
        
        cancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else {
                    return
                }
                let elapsed = Date().timeIntervalSince(self.defaults.object(forKey: "countdown_start_date") as! Date)
                let remaining = self.countdownDuration - elapsed
                
                if remaining <= 0 {
                    self.markAsExpired()
                    self.cancellable?.cancel()
                } else {
                    self.updateTimerComponents(with: remaining)
                }
            }
    }
    
    private func updateTimerComponents(with timeRemaining: TimeInterval) {
        let time = Int(timeRemaining)
        self.hours = time / 3600
        self.minutes = (time % 3600) / 60
        self.seconds = (time % 3600) % 60
    }
    
    func markAsExpired() {
        isExpired = true
        defaults.set(true, forKey: "isCountdownExpired")
        resetCountdown()
    }
    
    private func resetCountdown() {
        hours = 0
        minutes = 0
        seconds = 0
        cancellable?.cancel()
    }
}
