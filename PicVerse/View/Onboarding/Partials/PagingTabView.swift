//
//  PagingTabView.swift
//  EveCraft
//
//  Created by Purvi Sancheti on 02/09/25.
//


import Foundation
import SwiftUI


struct PagingTabView<Content: View>: View {
    @Binding var selectedIndex: Int
    let tabCount: Int
    let spacing: CGFloat
    let content: () -> Content
    var indicatorRequired: Bool = true
    var buttonAction: () -> Void
    
  
    let impactfeedback = UIImpactFeedbackGenerator(style: .light)
    
    @State private var isPressed = false

    
    var body: some View {
        ZStack(alignment:.bottom) {
            
            // TabView with Paging Style
            TabView(selection: $selectedIndex) {
                content()
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Hide default dots
            
            //Custom Page Indicator
            
            VStack(spacing: ScaleUtility.scaledSpacing(22)) {
                
                HStack {
                    
                    HStack(spacing: ScaleUtility.scaledSpacing(10)) {
                        ForEach(0..<tabCount, id: \.self) { index in
                            Group {
                                if selectedIndex == index {
                                    Rectangle()
                                        .frame(width: isIPad
                                               ? ScaleUtility.scaledValue(24) * widthRatio
                                               : ScaleUtility.scaledValue(24),
                                               height:  isIPad
                                               ? ScaleUtility.scaledValue(9) * heightRatio
                                               : ScaleUtility.scaledValue(9))
                                        .foregroundColor(Color.secondaryApp)
                                        .cornerRadius(30)
                                    
                                } else {
                                    Circle()
                                        .frame(width: isIPad
                                               ? ScaleUtility.scaledValue(9) * widthRatio
                                               :  ScaleUtility.scaledValue(9),
                                               height: isIPad
                                               ? ScaleUtility.scaledValue(9) * heightRatio
                                               :  ScaleUtility.scaledValue(9))
                                        .foregroundColor(Color.secondaryApp)
                                }
                            }
                        }
                    }
                 
                    
                }
                .animation(.easeInOut, value: selectedIndex)
                .frame(maxWidth: .infinity)
                .opacity(indicatorRequired ? 1 : 0)
                
                
                Button(action: {
                   
                    impactfeedback.impactOccurred()
                    buttonAction()
                   
                })
                {
                    Text(selectedIndex == 0 ? "Get Started" : "Continue")
                      .font(FontManager.instrumentSansMediumFont(size: .scaledFontSize(16)))
                      .multilineTextAlignment(.center)
                      .foregroundColor(.white)
                      .frame(height: ScaleUtility.scaledValue(60))
                      .frame(maxWidth: .infinity)
                      .background {
                          Image(.buttonBg)
                              .resizable()
                              .frame(height: ScaleUtility.scaledValue(60))
                              .frame(maxWidth: .infinity)
                      }
                      .cornerRadius(14)
                      .scaleEffect(isPressed ? 0.96 : 1.0)
                      .offset(y: isPressed ? 2 : 0)
                      .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
                      .padding(.horizontal, ScaleUtility.scaledSpacing(20))
                      .zIndex(1)

                }
                .buttonStyle(PressButtonStyle(isPressed: $isPressed))
                .zIndex(1)
                
            }
            .padding(.bottom, isSmallDevice ? ScaleUtility.scaledSpacing(20) : ScaleUtility.scaledSpacing(40))
            

        }
        .background(Color.primaryApp.ignoresSafeArea(.all))
    }
}

