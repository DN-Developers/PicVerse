//
//  UserSettings.swift
//  PicVerse
//
//  Created by Neel Kalariya on 21/09/25.
//



import Foundation



class UserSettings: ObservableObject {
    

    private let defaults: UserDefaults
    

    private struct Keys {
        static let lyricsCount = "lyricsCount"
   
        
        static let userId = "user_id"
        static let isPaid = "is_ paid"
        static let isTrial = "is_trial"
        static let planType = "plan_type"
        static let planId = "plan_id"
        static let exportToPhotos = "export_to_photos"
        static let firstPurchaseDate = "firstPurchaseDate"
        static let trialStartDate = "trial_start_date"
        static let userName = "userName"
        static let ratingPopupCount = "ratingPopupCount"
        static let hasMigrated = "hasMigratedCoreDataImages"
        
        static let convertionCount = "convertionCount"
        
        
    }
    
    //Published properties for observing changes
    @Published var lyricsCount: Int {
        didSet {
            defaults.set(lyricsCount, forKey: Keys.lyricsCount) // ✅ Save correct value
        }
    }

    @Published var convertionCount: Int{
        didSet {
            defaults.set(convertionCount, forKey: Keys.convertionCount) // ✅ Save correct value
        }
    }
    
    
    @Published var userId: String {
        didSet {
            defaults.set(userId, forKey: Keys.userId)
        }
    }
    
    @Published var userName: String {
        didSet {
            defaults.set(userName, forKey: Keys.userName)
        }
    }
    
  
    
    @Published var isPaid: Bool {
        didSet {
            defaults.set(isPaid, forKey: Keys.isPaid)
        }
    }
    
    @Published var isTrial: Bool {
        didSet {
            defaults.set(isTrial, forKey: Keys.isTrial)
        }
    }
    
    @Published var planType: String {
        didSet {
            defaults.set(planType, forKey: Keys.planType)
        }
    }
    
    @Published var planId: String {
        didSet {
            defaults.set(planId, forKey: Keys.planId)
        }
    }
    
    @Published var firstPurchaseDate: Date? {
        didSet {
            defaults.set(firstPurchaseDate, forKey: Keys.firstPurchaseDate)
        }
    }
    
    @Published var exportToPhotos: Bool {
        didSet {
            defaults.set(exportToPhotos, forKey: Keys.exportToPhotos)
        }
    }
    
 
    
    @Published var remainingTime: TimeInterval = 0
    
    private var timer: Timer?
    
//    @Published var ratingPopupCount: Int {
//        didSet {
//            defaults.set(ratingPopupCount, forKey: Keys.ratingPopupCount)
//        }
//    }
    
    @Published var birthdayCardCount: Int {
        didSet {
            UserDefaults.standard.set(birthdayCardCount, forKey: "BirthdayCardCount")
        }
    }
    
    @Published var imagecount: Int {
        didSet {
            UserDefaults.standard.set(imagecount, forKey: "imagecount")
        }
    }
    
    
    @Published var avatarcount: Int {
        didSet {
            UserDefaults.standard.set(avatarcount, forKey: "avatarcount")
        }
    }
    
    @Published var cardCreatedcount: Int {
        didSet {
            UserDefaults.standard.set(avatarcount, forKey: "avatarcount")
        }
    }
    
    @Published var ratingPopupCount: Int {
        didSet {
            defaults.set(ratingPopupCount, forKey: Keys.ratingPopupCount)
        }
    }
    
 
    
    
    @Published var hasMigrated: Bool {
        didSet {
            defaults.set(hasMigrated, forKey: Keys.hasMigrated)
        }
    }
    
    
    init() {
        self.defaults = UserDefaults.standard
        
        // Load saved values or defaults
        self.convertionCount = defaults.integer(forKey: Keys.convertionCount) // ✅ Load correct value
        self.lyricsCount = defaults.integer(forKey: Keys.lyricsCount) // ✅ Load correct value
        self.userId = defaults.string(forKey: Keys.userId) ?? UserSettings.generateShortUUID()
        self.isPaid = defaults.bool(forKey: Keys.isPaid)
        self.isTrial = defaults.bool(forKey: Keys.isTrial)
        self.planType = defaults.string(forKey: Keys.planType) ?? ""
        self.planId = defaults.string(forKey: Keys.planId) ?? ""
        self.userName = defaults.string(forKey: Keys.userName) ?? ""
        self.birthdayCardCount = UserDefaults.standard.integer(forKey: "BirthdayCardCount")
        self.imagecount = UserDefaults.standard.integer(forKey: "imagecount")
        self.avatarcount = UserDefaults.standard.integer(forKey: "avatarcount")
        self.cardCreatedcount = UserDefaults.standard.integer(forKey: "cardCreatedcount")
        self.ratingPopupCount = defaults.integer(forKey: Keys.ratingPopupCount)
        self.hasMigrated = defaults.bool(forKey: Keys.hasMigrated)
        self.exportToPhotos = defaults.bool(forKey: Keys.exportToPhotos)

        // Retrieve first purchase date safely
        if let savedDate = defaults.object(forKey: Keys.firstPurchaseDate) as? Date {
            self.firstPurchaseDate = savedDate
        }

        if defaults.object(forKey: Keys.trialStartDate) == nil {
            self.startTrial()
        }

        startCountdownTimer()
    }
    
    /// Start the trial and save the start date in UserDefaults
    func startTrial() {
        let currentDate = Date()
        defaults.set(currentDate, forKey: Keys.trialStartDate)
        startCountdownTimer()
    }
    
    /// Start the countdown timer for 24 hours
    func startCountdownTimer() {
        if let installationDate = defaults.object(forKey: Keys.trialStartDate) as? Date {
            let now = Date()
            let elapsedTime = now.timeIntervalSince(installationDate)
            remainingTime = max(86400 - elapsedTime, 0) // 86400 seconds in 24 hours
            
            if remainingTime > 0 {
                timer?.invalidate()
                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
                    self.updateRemainingTime()
                })
            } else {
                isTrial = false
                defaults.set(false, forKey: Keys.isTrial)
            }
        }
    }
    
    /// Update the remaining time for the countdown every second
    func updateRemainingTime() {
        if remainingTime > 0 {
            remainingTime -= 1
        } else {
            timer?.invalidate()
            isTrial = false
            defaults.set(false, forKey: Keys.isTrial)
        }
    }
    
    static func generateShortUUID(length: Int = 8) -> String {
        let uuid = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        return String(uuid.prefix(length))
    }
  


    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

}


