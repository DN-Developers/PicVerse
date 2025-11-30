//
//  FilterPopUp.swift
//  iOS-Picture-Converter
//
//  Created by Darsh Viroja on 03/05/25.
//

import Foundation
import SwiftUI
struct FilterPopUp: View {
    var onDate: () -> Void
    var AToZ: () -> Void
    var ZToA: () -> Void
    var lowSize: () -> Void
    var highSize: () -> Void

    @Binding var isNameAscending: Bool
    @Binding var isSizeAscending: Bool
    
    let notificationfeedback = UINotificationFeedbackGenerator()
    let impactfeedback = UIImpactFeedbackGenerator(style: .medium)
    let selectionfeedback = UISelectionFeedbackGenerator()

    var body: some View {
        VStack(alignment: .leading,spacing: ScaleUtility.scaledSpacing(14)) {
            // Date
            Text("By Date")
                .font(FontManager.instrumentSansRegularFont(size: .scaledFontSize(14)))
                .foregroundColor(.white)
                .onTapGesture {
                    onDate()
                    selectionfeedback.selectionChanged()
                }

            Rectangle()
                .fill(.white)
                .opacity(0.06)
                .frame(height: ScaleUtility.scaledValue(1))
                .frame(width: ScaleUtility.scaledValue(131))

            // Name
            HStack(spacing: ScaleUtility.scaledSpacing(5)) {
                Text("By Name")
                    .font(FontManager.instrumentSansRegularFont(size: .scaledFontSize(14)))
                    .foregroundColor(.white)
                Image(isNameAscending ? "up" : "down")
                    .resizable()
                    .resizable(size: CGSize(
                        width: isIPad ? ScaleUtility.scaledValue(24.66652) :  ScaleUtility.scaledValue(14.66652),
                        height: isIPad ?  ScaleUtility.scaledValue(24.66652) : ScaleUtility.scaledValue(14.66652)))
            }
            .frame(maxWidth: .infinity,alignment: .leading)
            .onTapGesture {
                if isNameAscending {
                    AToZ()
                    selectionfeedback.selectionChanged()
                } else {
                    ZToA()
                    selectionfeedback.selectionChanged()
                }
                isNameAscending.toggle()
            }

            Rectangle()
                .fill(.white)
                .opacity(0.06)
                .frame(height: ScaleUtility.scaledValue(1))
                .frame(width: ScaleUtility.scaledValue(131))

            // Size
            HStack(spacing: ScaleUtility.scaledSpacing(16)) {
                Text("By Size")
                    .font(FontManager.instrumentSansRegularFont(size: .scaledFontSize(14)))
                    .foregroundColor(.white)
                
                Image(isSizeAscending ? "up" : "down")
                    .resizable()
                    .resizable(size: CGSize(
                        width: isIPad ? ScaleUtility.scaledValue(24.66652) :  ScaleUtility.scaledValue(14.66652),
                        height: isIPad ?  ScaleUtility.scaledValue(24.66652) : ScaleUtility.scaledValue(14.66652)))
            }
            .frame(maxWidth: .infinity,alignment: .leading)
            .onTapGesture {
                if isSizeAscending {
                    lowSize()
                    selectionfeedback.selectionChanged()
                } else {
                    highSize()
                    selectionfeedback.selectionChanged()
                }
                isSizeAscending.toggle()
            }
        }
        .padding(.vertical,ScaleUtility.scaledSpacing(15.05))
        .padding(.leading,ScaleUtility.scaledSpacing(18.27))
        .frame(maxWidth: .infinity, maxHeight: .infinity,alignment: .leading)
        .background(Color.appGrey)
    }
}
