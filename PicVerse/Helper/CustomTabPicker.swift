//
//  CustomTabPicker.swift
//  PicVerse
//
//  Created by Neel Kalariya on 04/10/25.
//

import Foundation
import Foundation
import SwiftUI

struct CustomTabPicker: View {
    @Binding var selectedTab:Int
    var tabs: [String]  // This is now a parameter for dynamic tabs.
    var isInside:Bool = false
    var body: some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width - 32 // padding adjustment
            let tabWidth = totalWidth / CGFloat(tabs.count) // dynamically calculating tab width
            let activeRectanglePadding: CGFloat = 4  // added padding for active rectangle
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 500)
                    .fill(Color.appSoftGrey)
                    .scaledFrame(baseHeight: ScaleUtility.scaledValue(41))
             

                RoundedRectangle(cornerRadius: 500)
                    .foregroundColor(Color.clear)
                    .background {
                        if isInside {
                            Color.appSoftGrey
                                .clipShape(RoundedRectangle(cornerRadius: 500))
                        }
                        else {
                         
                            Image(.selectedTab)
                                .resizable()
                                .frame(width: tabWidth - 2 * activeRectanglePadding)
                            
                        }
                    }
                    .frame(width: tabWidth - 2 * activeRectanglePadding)
                    .scaledFrame(baseHeight: ScaleUtility.scaledValue(41))
                // reducing width
                    .offset(x: CGFloat(selectedTab) * tabWidth + activeRectanglePadding) // shifting the active rect
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: selectedTab)
                   
                
                HStack(spacing: 0) {
                    ForEach(tabs.indices, id: \.self) { index in
                        Button(action: {
                            withAnimation {
                                selectedTab = index
                                
                            }
                        }) {
                            HStack(spacing: 8) {
                               
                                Text(tabs[index])
                                    .font(selectedTab == index
                                          ? FontManager.instrumentSansMediumFont(size: .scaledFontSize(14))
                                          : FontManager.instrumentSansMediumFont(size: .scaledFontSize(14)))
                                
                                    .kerning(0.42)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(Color.secondaryApp)

                            }
                            .frame(width: tabWidth)
                            .scaledFrame(baseHeight: ScaleUtility.scaledValue(41))
                            .foregroundColor(Color.secondaryApp)
                 
                        }
                    }
                }
            }
            .padding(.horizontal, ScaleUtility.scaledValue(20))  // 16px padding around the whole tab picker
        }
        .scaledFrame(baseHeight: ScaleUtility.scaledValue(41))
    }
}
