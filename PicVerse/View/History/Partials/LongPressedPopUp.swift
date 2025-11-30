//
//  LongPressedPopUp.swift
//  iOS-Picture-Converter
//
//  Created by Darsh Viroja on 03/05/25.
//

import Foundation
import SwiftUI

struct LongPressedPopUp: View {
    
    var onShare: () -> Void
    var onOpen: () -> Void
    var onConvert: () -> Void
    var onDelete: () -> Void
 
    var body: some View
    {
        VStack(spacing: 0)
        {
            VStack(spacing:ScaleUtility.scaledSpacing(14))
            {
                HStack(spacing: ScaleUtility.scaledSpacing(10.6))
                {
                    Image(.sharing)
                        .resizable()
                        .resizable(size: CGSize(
                            width: isIPad ? ScaleUtility.scaledValue(26) :  ScaleUtility.scaledValue(16),
                            height: isIPad ?  ScaleUtility.scaledValue(26) : ScaleUtility.scaledValue(16)))
                    
                    Text("Share")
                        .font(FontManager.instrumentSansRegularFont(size: .scaledFontSize(14)))
                        .foregroundColor(.white)
                }
                .frame(maxWidth:.infinity,maxHeight: .infinity,alignment: .leading)
                .onTapGesture {
                    onShare()
                }
                
                
                
                Rectangle()
                    .fill(.white)
                    .opacity(0.06)
                    .frame(height: ScaleUtility.scaledValue(1))
                    .frame(width: ScaleUtility.scaledValue(131))
                    .offset(x:ScaleUtility.scaledSpacing(-10))
                
                HStack(spacing: ScaleUtility.scaledSpacing(10.6))
                {
                    Image(.open)
                        .resizable()
                        .resizable(size: CGSize(
                            width: isIPad ? ScaleUtility.scaledValue(26) :  ScaleUtility.scaledValue(16),
                            height: isIPad ?  ScaleUtility.scaledValue(26) : ScaleUtility.scaledValue(16)))
                    
                    Text("Open")
                        .font(FontManager.instrumentSansRegularFont(size: .scaledFontSize(14)))
                        .foregroundColor(.white)
                }
                .frame(maxWidth:.infinity,maxHeight: .infinity,alignment: .leading)
                .onTapGesture {
                    onOpen()
                }
                Rectangle()
                    .fill(.white)
                    .opacity(0.06)
                    .frame(height: ScaleUtility.scaledValue(1))
                    .frame(width: ScaleUtility.scaledValue(131))
                    .offset(x:ScaleUtility.scaledSpacing(-10))
                
                HStack(spacing: ScaleUtility.scaledSpacing(10.6))
                {
                    Image(.converted)
                        .resizable()
                        .resizable(size: CGSize(
                            width: isIPad ? ScaleUtility.scaledValue(26) :  ScaleUtility.scaledValue(16),
                            height: isIPad ?  ScaleUtility.scaledValue(26) : ScaleUtility.scaledValue(16)))
                    
                    Text("Convert")
                        .font(FontManager.instrumentSansRegularFont(size: .scaledFontSize(14)))
                        .foregroundColor(.white)
                }
                .frame(maxWidth:.infinity,maxHeight: .infinity,alignment: .leading)
                .onTapGesture {
                    onConvert()
                }
                Rectangle()
                    .fill(.white)
                    .opacity(0.06)
                    .frame(height: ScaleUtility.scaledValue(1))
                    .frame(width: ScaleUtility.scaledValue(131))
                    .offset(x:ScaleUtility.scaledSpacing(-10))
                
                
                HStack(spacing: ScaleUtility.scaledSpacing(10.6))
                {
                    Image(.deleteimage)
                        .resizable()
                        .resizable(size: CGSize(
                            width: isIPad ? ScaleUtility.scaledValue(26) :  ScaleUtility.scaledValue(16),
                            height: isIPad ?  ScaleUtility.scaledValue(26) : ScaleUtility.scaledValue(16)))
                    
                    Text("Delete")
                        .font(FontManager.instrumentSansRegularFont(size: .scaledFontSize(14)))
                        .foregroundColor(.red)
                }
                .frame(maxWidth:.infinity,maxHeight: .infinity,alignment: .leading)
                .offset(y:ScaleUtility.scaledSpacing(-2))
                .onTapGesture {
                    onDelete()
                }
             
                
            }
            .padding(.top,ScaleUtility.scaledSpacing(14.65))
            .padding(.bottom,ScaleUtility.scaledSpacing(11.28))
            .padding(.leading,ScaleUtility.scaledSpacing(18.27))
            
        }
        .frame(maxWidth:.infinity,maxHeight: .infinity,alignment: .leading)
        .background(Color.appGrey)
        
    }
}
