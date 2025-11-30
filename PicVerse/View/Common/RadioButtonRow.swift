//
//  RadioButtonRow.swift
//  PicVerse
//
//  Created by Neel Kalariya on 28/09/25.
//

import Foundation
import SwiftUI


struct RadioButtonRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    let notificationfeedback = UINotificationFeedbackGenerator()
    let impactfeedback = UIImpactFeedbackGenerator(style: .medium)
    let selectionfeedback = UISelectionFeedbackGenerator()
    
    var body: some View {
        HStack(spacing: ScaleUtility.scaledSpacing(12)) {
            
            Spacer()
            
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .resizable()
                .frame(width: isIPad ? ScaleUtility.scaledValue(20) : ScaleUtility.scaledValue(15),
                       height: isIPad ? ScaleUtility.scaledValue(20) : ScaleUtility.scaledValue(15))
                .foregroundColor(isSelected ? Color.white : .white.opacity(0.35))
                .onTapGesture {
                    selectionfeedback.selectionChanged()
                    action()
                }

            Text(title)
                .font(FontManager.instrumentSansRegularFont(size: .scaledFontSize(14)))
                .foregroundColor(.white)
                .onTapGesture { action() }

            Spacer()
        }
        .padding(.horizontal)
        .padding(.trailing,ScaleUtility.scaledSpacing(8))
    }
}
