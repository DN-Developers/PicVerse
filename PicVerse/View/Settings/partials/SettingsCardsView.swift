//
//  CardView.swift
//  H2JPG
//
//  Created by Purvi Sancheti on 20/08/25.
//


import Foundation
import SwiftUI

struct SettingsCardsView: View {
    @EnvironmentObject var purchaseManager: PurchaseManager
    @Environment(\.openURL) var openURL
    @StateObject private var userSettings = UserSettings()
    
    let notificationfeedback = UINotificationFeedbackGenerator()
    let impactfeedback = UIImpactFeedbackGenerator(style: .medium)
    let selectionfeedback = UISelectionFeedbackGenerator()
    
    @State private var isRateUsPressed = false
    @State private var isShareAppPressed = false
    @State private var isAboutAppPressed = false
    @State var isShowPayWall: Bool = false
    @State private var isContactUsPressed = false
    @State private var isSupportPressed = false
    @State private var isPrivacyPressed = false
    @State private var isTermsPressed = false
    @State private var showDeleteAllAlert = false
    
    var body: some View {
        
        ScrollView {
            
            Spacer()
                .frame(height: ScaleUtility.scaledValue(20))
            
            VStack(spacing: ScaleUtility.scaledSpacing(15)) {
                //MARK: - FIRST CARD
                
                HStack {
                    CommonRowView(rowText: "Auto Save to Gallery", rowImage: "downloadIcon2")
                    
                    Spacer()
                    
                    Rectangle()
                        .foregroundColor(.clear)
                        .background(.clear)
                        .frame(width:ScaleUtility.scaledValue(41), height: ScaleUtility.scaledValue(24))
                        .overlay {
                            Toggle("", isOn: $userSettings.exportToPhotos)
                                .toggleStyle(ModernToggleStyle())
                                .frame(width: ScaleUtility.scaledValue(41))
                                .disabled(!purchaseManager.hasPro)
                                .onChange(of: userSettings.exportToPhotos) { isOn in
                                    selectionfeedback.selectionChanged()
                                    isOn ? UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    : UISelectionFeedbackGenerator().selectionChanged()
                                    
                                    //                                AnalyticsManager.shared.log(.autoSaveToGalleryPressed)
                                }
                        }
                        .onTapGesture {
                            if !purchaseManager.hasPro {
                                self.isShowPayWall = true
                            }
                        }
                    
                }
                .padding(.leading, ScaleUtility.scaledSpacing(14))
                .padding(.trailing, ScaleUtility.scaledSpacing(15))
                .padding(.vertical, ScaleUtility.scaledSpacing(12))
                .background(Color.appGrey)
                .cornerRadius(20)
                .padding(.horizontal, ScaleUtility.scaledSpacing(20))
                
                //MARK: - SECOND CARD
                
                VStack(spacing: ScaleUtility.scaledSpacing(12)) {
                    
                    Button {
                        
                        impactfeedback.impactOccurred()
                        if let url = URL(string: AppConstant.ratingPopupURL) {
                            openURL(url)
                        }
                    } label: {
                        CommonRowView(rowText: "Rate Us", rowImage: "rateUsIcon")
                    }
                    .scaleEffect(isRateUsPressed ? 0.95 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isRateUsPressed)
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                withAnimation {
                                    isRateUsPressed = true
                                }
                            }
                            .onEnded { _ in
                                withAnimation {
                                    isRateUsPressed = false
                                }
                            }
                    )
                    
                    Rectangle()
                        .foregroundColor(Color.secondaryApp.opacity(0.2))
                        .frame(maxWidth: .infinity)
                        .frame(height: ScaleUtility.scaledValue(1.5))
                    
                    ShareLink(item: URL(string: AppConstant.shareAppIDURL)!)
                    {
                        CommonRowView(rowText: "Share App", rowImage: "shareAppIcon")
                    }
                    .scaleEffect(isShareAppPressed ? 0.95 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isShareAppPressed)
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                withAnimation {
                                    isShareAppPressed = true
                                }
                            }
                            .onEnded { _ in
                                withAnimation {
                                    isShareAppPressed = false
                                }
                            }
                    )
                    
                    Rectangle()
                        .foregroundColor(Color.secondaryApp.opacity(0.2))
                        .frame(maxWidth: .infinity)
                        .frame(height: ScaleUtility.scaledValue(1.5))
                    
                    Button(action: {
                        impactfeedback.impactOccurred()
                        let url = URL(string: AppConstant.aboutAppURL)!
                        openURL(url)
                    }) {
                        HStack {
                            
                            CommonRowView(rowText: "About App", rowImage: "aboutIcon")
                            
                            Text("App Version \(Bundle.appVersion)")
                                .font(FontManager.instrumentSansRegularFont(size: .scaledFontSize(12)))
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color.secondaryApp.opacity(0.5))
                            
                        }
                    }
                    .scaleEffect(isAboutAppPressed ? 0.95 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isAboutAppPressed)
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                withAnimation {
                                    isAboutAppPressed = true
                                }
                            }
                            .onEnded { _ in
                                withAnimation {
                                    isAboutAppPressed = false
                                }
                            }
                    )
                    
                }
                .padding(.vertical,ScaleUtility.scaledSpacing(12))
                .padding(.horizontal,ScaleUtility.scaledSpacing(14))
                .background(Color.appGrey)
                .cornerRadius(20)
                .padding(.horizontal, ScaleUtility.scaledSpacing(20))
                
                
                //MARK: - THIRD CARD
                
                VStack(spacing: ScaleUtility.scaledSpacing(12)) {
                    
                    Button(action: {
                        impactfeedback.impactOccurred()
                        let url = URL(string: AppConstant.contactUSURL)!
                        openURL(url)
                    }) {
                        CommonRowView(rowText: "Contact Us", rowImage: "contactIcon")
                    }
                    .scaleEffect(isContactUsPressed ? 0.95 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isContactUsPressed)
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                withAnimation {
                                    isContactUsPressed = true
                                }
                            }
                            .onEnded { _ in
                                withAnimation {
                                    isContactUsPressed = false
                                }
                            }
                    )
                    
                    Rectangle()
                        .foregroundColor(Color.secondaryApp.opacity(0.2))
                        .frame(maxWidth: .infinity)
                        .frame(height: ScaleUtility.scaledValue(1.5))
                    
                    Button(action: {
                        impactfeedback.impactOccurred()
                        let url = URL(string: AppConstant.supportURL)!
                        openURL(url)
                    }) {
                        CommonRowView(rowText: "Support", rowImage: "supportIcon")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .scaleEffect(isSupportPressed ? 0.95 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isSupportPressed)
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                withAnimation {
                                    isSupportPressed = true
                                }
                            }
                            .onEnded { _ in
                                withAnimation {
                                    isSupportPressed = false
                                }
                            }
                    )
                    
                    
                    Rectangle()
                        .foregroundColor(Color.secondaryApp.opacity(0.2))
                        .frame(maxWidth: .infinity)
                        .frame(height: ScaleUtility.scaledValue(1.5))
                    
                    Button(action: {
                        impactfeedback.impactOccurred()
                        let url = URL(string: AppConstant.privacyURL)!
                        openURL(url)
                    }) {
                        
                        CommonRowView(rowText: "Privacy Policies", rowImage: "privacyIcon")
                    }
                    .scaleEffect(isPrivacyPressed ? 0.95 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isPrivacyPressed)
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                withAnimation {
                                    isPrivacyPressed = true
                                }
                            }
                            .onEnded { _ in
                                withAnimation {
                                    isPrivacyPressed = false
                                }
                            }
                    )
                    
                    
                    Rectangle()
                        .foregroundColor(Color.secondaryApp.opacity(0.2))
                        .frame(maxWidth: .infinity)
                        .frame(height: ScaleUtility.scaledValue(1.5))
                    
                    Button(action: {
                        impactfeedback.impactOccurred()
                        let url = URL(string: AppConstant.termsAndConditionURL)!
                        openURL(url)
                    }) {
                        CommonRowView(rowText: "Terms & Conditions", rowImage: "termsIcon")
                    }
                    .scaleEffect(isTermsPressed ? 0.95 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isTermsPressed)
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                withAnimation {
                                    isTermsPressed = true
                                }
                            }
                            .onEnded { _ in
                                withAnimation {
                                    isTermsPressed = false
                                }
                            }
                    )
                    
                }
                .padding(.vertical,ScaleUtility.scaledSpacing(12))
                .padding(.horizontal,ScaleUtility.scaledSpacing(14))
                .background(Color.appGrey)
                .cornerRadius(20)
                .padding(.horizontal, ScaleUtility.scaledSpacing(20))
            }
            .fullScreenCover(isPresented: $isShowPayWall) {
                
                PaywallView(dismissAction: {
                    isShowPayWall = false
                },
                            isInternalOpen: true,
                            purchaseCompletSuccessfullyAction: {
                    isShowPayWall = false
                })
            }
            
            Spacer()
                .frame(height: ScaleUtility.scaledValue(150))
            
        }

    }
}

extension Bundle {
    static var appVersion: String {
        (main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "-"
    }
    static var buildNumber: String {
        (main.infoDictionary?["CFBundleVersion"] as? String) ?? "-"
    }
}
