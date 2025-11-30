//
//  SwipeView.swift
//  WPIX
//
//  Created by Purvi Sancheti on 27/10/25.
//

import Foundation
import SwiftUI

struct SwipeView: View {
    @State private var currentIndex = 0
    
    var showPaywall: () -> Void
    let totalScreens = 5
    
    let notificationFeedback = UINotificationFeedbackGenerator()
    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
    let selectionFeedback = UISelectionFeedbackGenerator()
    @State var isAppears: Bool = false
    @State private var selectedOptions: Set<String> = []
    
    var body: some View {
        PagingTabView(selectedIndex: $currentIndex, tabCount: totalScreens, spacing: 0) {
            Group {
                WelcomeView(isAppears: $isAppears,isActive: currentIndex == 0)
                    .tag(0)
                
                OnboardingOneView(isAppears: $isAppears,isActive: currentIndex == 1)
                    .tag(1)
                
                OnboardingTwoView(isAppears: $isAppears,isActive: currentIndex == 2)
                    .tag(2)
                
                RatingView(isActive: currentIndex == 3)
                    .tag(3)
                
                CommentView(isAppears: $isAppears,isActive: currentIndex == 4)
                    .tag(4)
            }
        } buttonAction: {
            handleButtonPress()
        }
        .animation(.easeInOut(duration: 0.3), value: currentIndex)
        .ignoresSafeArea(.all)
        .frame(maxWidth: .infinity,maxHeight: .infinity)
        
    }
    
    private func handleButtonPress() {
        if currentIndex == 4 {
            showPaywall()
        }
        else {
            self.currentIndex += 1
        }
    }
    
}
