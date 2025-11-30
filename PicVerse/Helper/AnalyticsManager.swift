//
//  AnalyticsManager.swift
//  PicMate
//
//  Created by Darsh Viroja on 12/05/25.
//

import Foundation
import FirebaseAnalytics

///Manager to handle firebase app anaytics
final class AnalyticsManager {
    private init() {}
    
    static let shared = AnalyticsManager()
    
    public func log(_ event: AnalyticsEvent) {
        switch event {
        case .firstPaywallPayButtonClicked(let plandDetails), .internalPaywallPayButtonClicked(let plandDetails):
            print("\nEvent Logged\n")
            print("--------------------------------------------------\n")
            let eventName = "\(event.eventName)_Plan_Clicked"
            print("Event: \(eventName)")
            Analytics.logEvent(eventName, parameters: ["Plan":plandDetails.planName])
            break
        case .firstPaywallPlanPurchase(let plandDetails), .internalPaywallPlanPurchase(let plandDetails):
            print("\nEvent Logged\n")
            print("--------------------------------------------------\n")
            let eventName = "\(event.eventName)_Plan_Purchased"
            print("Event: \(eventName)")
            Analytics.logEvent(eventName, parameters: ["Plan":plandDetails.planName])
            break
        case .firstPaywallPlanRestore(let plandDetails),  .internalPaywallPlanRestore(let plandDetails):
            let eventName = "\(event.eventName)"
            print("Event: \(eventName)")
            Analytics.logEvent(eventName, parameters: nil)
            break
        case .format(let format):
            print("\nEvent Logged\n")
            print("--------------------------------------------------\n")
            print("Event: selected_format_\(format.lowercased())")
            Analytics.logEvent("selected_format", parameters: ["format": format.lowercased()])
            break

        case .firstPaywallPlanRestore(let plandDetails),  .internalPaywallPlanRestore(let plandDetails):
            break
        
       
        default:
            print("\nEvent Logged\n")
            print("--------------------------------------------------\n")
            print("Event: \(event.eventName)")
            Analytics.logEvent(event.eventName, parameters: nil)
            break
        }
    }
}

enum AnalyticsEvent {
    //first paywall after on boarding
    case firstPaywallLoaded //
    case firstPaywallXClicked //
    case AdsClicked //
    
    case firstPaywallRestoreClicked //
    case firstPaywallPayButtonClicked(PlanDetails) //
    case firstPaywallPlanPurchase(PlanDetails) //
    case firstPaywallPlanRestore(PlanDetails) //
    
    //Internal paywall from validation and settings
    case internalPaywallLoaded //
    case internalPaywallXLoaded //
    case internalPaywallXClicked //
    case internalPaywallContinueWithAdsClicked //
    
    case internalPaywallRestoreClicked //
    case internalPaywallPayButtonClicked(PlanDetails) //
    case internalPaywallPlanPurchase(PlanDetails) //
    case internalPaywallPlanRestore(PlanDetails) //
    
    //other events
   
    case giftScreenLoaded
    case giftScreenXClicked
    case giftScreenPlanPurchase
    case giftBottomSheetXClicked
    case giftBannerPlanPurchase

    case firstRatingPopupDisplayed
    case secondRatingPopupDisplayed
    case thirdRatingPopupDisplayed
    
    
    case noOfUserUpdatedApp
    //case timerCreatePlusSuccess
    
    case imageSelectedFromFile
    case imageSelectedFromLibrary
    case imagePasted
    case format(String)
    case cancel
    case addToPhotos
    case addToFiles
    case shareAnywhere
    case convertMore
    case share
    case delete
    case convert
    case autoSaveToGallery
    case switchMode
    case previewScreenOpen
    case pdfPreviewOpen
    case JPG
    case JPEG
    case PNG
    case PDF
    case GIF
    case TIFF
    case WEBP
    case BMP
    case HEIC
//    let formats = ["JPG","JPEG","PNG", "PDF", "GIF", "TIFF","WEBP","BMP","HEIC"]
    
    var eventName: String {
        switch self {
        case .firstPaywallLoaded: return "on_boarding_paywall_opened"
        case .firstPaywallXClicked: return "first_paywall_x_clicked"
        case .firstPaywallPayButtonClicked: return "first_paywall_pay_button_clicked"
        case .firstPaywallRestoreClicked: return "first_paywall_restore_clicked"
        case .firstPaywallPlanPurchase: return "on_boarding_paywall_subscribed"
        case .firstPaywallPlanRestore: return "first_paywall_plan_restore"
        case .internalPaywallLoaded: return "internal_paywall_opened"
        case .internalPaywallXLoaded: return "internal_paywall_x_loaded"
        case .internalPaywallXClicked: return "internal_paywall_x_clicked"
        case .internalPaywallPayButtonClicked: return "internal_paywall_pay_button_clicked"
        case .internalPaywallRestoreClicked: return "internal_paywall_restore_clicked"
        case .internalPaywallPlanPurchase: return "internal_paywall_subscribed"
        case .internalPaywallPlanRestore: return "internal_paywall_plan_restore"
            
            
    
            
            
        case .firstRatingPopupDisplayed: return "first_rating_popup_displayed"
        case .secondRatingPopupDisplayed: return "second_rating_popup_displayed"
        case .thirdRatingPopupDisplayed: return "third_rating_popup_displayed"
            
            
        case .giftScreenLoaded: return "giftscreenLoaded"
        case .giftScreenXClicked: return "giftscreen_closed"
        case .giftScreenPlanPurchase: return "giftscreen_planpurchase"
        case .giftBottomSheetXClicked: return "giftscreenbottomsheet_closed"
        case .giftBannerPlanPurchase: return "giftbanner_planpurchase"
        
            
            
        case .AdsClicked: return "ads_clicked"
            
            
        case .internalPaywallContinueWithAdsClicked: return "i_paywall_continue_with_ads_clicked"
           
        case .noOfUserUpdatedApp: return "appupdated"
            
            
        case .imageSelectedFromFile: return "imageSelectedFromFile"
        case .imageSelectedFromLibrary: return "imageSelectedFromLibrary"
        case .imagePasted: return "imagePasted"
        case .format(let format): return "selected_format_\(format.lowercased())"
        case .cancel: return "cancel"
        case .addToPhotos: return "addToPhotos"
        case .addToFiles: return "addToFiles"
        case .shareAnywhere: return "shareAnywhere"
        case .convertMore: return "convertMore"
        case .share: return "share"
        case .delete: return "delete"
        case .convert: return "convert"
        case .autoSaveToGallery: return "autoSaveToGallery"
        case .switchMode: return "switchMode"
        case .previewScreenOpen: return "previewScreenOpen"
        case .pdfPreviewOpen: return "pdfPreviewOpen"
            
        case .JPG: return "JPG"
        case .JPEG: return "JPEG"
        case .PDF: return "PDF"
        case .PNG: return "PNG"
        case .GIF: return "GIF"
        case .TIFF: return "TIFF"
        case .WEBP: return "WEBP"
        case .BMP: return "BMP"
        case .HEIC: return "HEIC"
        }
    }
    
}

