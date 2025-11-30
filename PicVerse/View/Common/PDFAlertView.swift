//
//  PDFAlertView.swift
//  PicVerse
//
//  Created by Neel Kalariya on 28/09/25.

import Foundation
import SwiftUI


enum PDFConversionOption: String {
    case singlePDF
    case multiplePDFs
}


struct PdfAlertView: View {
    @Binding var selectedOption: PDFConversionOption?
    var onCancel: () -> Void
    var onConvert: () -> Void
    let impactfeedback = UIImpactFeedbackGenerator(style: .medium)
    @State private var isConvertButtonPressed = false
    @State private var isCrossButtonPressed = false
    var body: some View {
        ZStack(alignment: .topTrailing) {
            
            // Background: subtle radial glow
            LinearGradient(
                colors: [Color(hex: "050510"), Color(hex: "0C0F1A")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay(
                RadialGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.2), .clear]),
                    center: .topTrailing, startRadius: 40, endRadius: 600)
            )
            .ignoresSafeArea()
            
            
            VStack(spacing: ScaleUtility.scaledSpacing(22)) {
            
                    
                    Text("Choose PDF Output")
                        .font(FontManager.instrumentSansMediumFont(size: .scaledFontSize(18)))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.secondaryApp)
                
                VStack(alignment: .leading,spacing: ScaleUtility.scaledSpacing(12)) {
                   
                    RadioButtonRow(
                      title: "All images in one PDF",
                      isSelected: selectedOption == .singlePDF
                    ) {
                        selectedOption = .singlePDF
                    }
                    
                    RadioButtonRow(
                      title: "Separate PDF for each",
                      isSelected: selectedOption == .multiplePDFs
                    ) {
                        selectedOption = .multiplePDFs
                    }
                }
                
                Button {
                    impactfeedback.impactOccurred()
                    onConvert()
                } label: {
                    ZStack {
                        Image(.buttonBg)
                            .resizable()
                            .frame(height:  ScaleUtility.scaledValue(52))
                            .frame(maxWidth: .infinity)
                      
                        Text("Convert Now")
                            .font(FontManager.instrumentSansMediumFont(size: .scaledFontSize(16)))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, ScaleUtility.scaledSpacing(20))
            
                }
                .buttonStyle(PlainButtonStyle())
          
            }
            .padding(.top, ScaleUtility.scaledSpacing(35))
    
            Button {
                impactfeedback.impactOccurred()
                onCancel()
            } label: {
                Image(.closeIcon)
                    .resizable()
                    .frame(width: isIPad ? ScaleUtility.scaledValue(30) : ScaleUtility.scaledValue(23), height: isIPad ? ScaleUtility.scaledValue(30) : ScaleUtility.scaledValue(23)) //
        
            }
            .buttonStyle(PlainButtonStyle())
            .scaleEffect(isCrossButtonPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isCrossButtonPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        withAnimation {
                            isCrossButtonPressed = true
                        }
                    }
                    .onEnded { _ in
                        withAnimation {
                            isCrossButtonPressed = false
                        }
                    }
            )
            .padding(.trailing, ScaleUtility.scaledSpacing(20))
            .padding(.top, ScaleUtility.scaledSpacing(15))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.5), lineWidth: 1)
        }
        .frame(maxWidth: .infinity)
        .frame(height: isIPad ?  ScaleUtility.scaledValue(253) : ScaleUtility.scaledValue(223))
        .cornerRadius(20)
        .padding(.horizontal, isIPad ? ScaleUtility.scaledSpacing(144) : ScaleUtility.scaledSpacing(24))
    }
}
