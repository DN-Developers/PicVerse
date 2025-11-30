//
//  View+Extension.swift
//  iOS-Picture-Converter
//
//  Created by Darsh Viroja on 02/05/25.
//

import Foundation
import SwiftUI

let isIPad = UIDevice.current.userInterfaceIdiom == .pad

extension View
{
    var screenSize: CGSize {
        UIScreen.main.bounds.size
    }
    
    var heightRatio: CGFloat
    {
        screenSize.height / 812
    }
    var widthRatio: CGFloat {
        screenSize.width / 375
    }
    
    
    var ipadWidthRatio: CGFloat {
        screenSize.width / 820
    }
    
    var isBigIpadDevice: Bool {
        screenSize.height > 1300
    }
    
    var ipadHeightRation: CGFloat {
        screenSize.height / 1366
        
    }
    var isSmallDevice: Bool {
        screenSize.height < 812
    }
    
    var isBigiphone: Bool {
        screenSize.height > 810
    }
    var isBiggerthaneleven: Bool
    {
        screenSize.height > 812 && screenSize.height <= 852
    }
    var isiPhone16: Bool {
        screenSize.height >= 852 && screenSize.width >= 393
    }
    
    func pushOutWidth(_ alignment: Alignment = .center) -> some View {
        self
            .frame(maxWidth: .infinity, alignment: alignment)
    }
    var elevenandall: Bool
    {
        screenSize.height >= 812 && screenSize.height <= 852
    }
 
    var isipgone16promax: Bool
    {
        screenSize.height >= 920 && screenSize.height <= 940
    }
 
    func popoverView<PopoverContent: View>(
        isPresented: Binding<Bool>,
        popOverTopPadding: CGFloat,
        popOverSize: CGSize,
        cornerRadius: CGFloat = 12, // <-- NEW
        popoverContent: @escaping () -> PopoverContent
    ) -> some View {
        self.modifier(
            PopoverViewModifier(
                isPresented: isPresented,
                popoverSize: popOverSize,
                popoverContent: popoverContent,
                popoverTopPadding: popOverTopPadding,
                cornerRadius: cornerRadius // <-- PASS IT
            )
        )
    }

}


