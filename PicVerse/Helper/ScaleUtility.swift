//
//  ScaleUtility.swift
//  iOS-Picture-Converter
//
//  Created by Darsh Viroja on 02/05/25.
//

import Foundation
import UIKit
import SwiftUI

struct ScaleUtility {
  static let width = UIScreen.main.bounds.width
  static let height = UIScreen.main.bounds.height
  static let designWidth: CGFloat = 375 // Width from your Figma design
  static let designHeight: CGFloat = 825 // Height from your Figma design (if needed)
  static func isPad() -> Bool {
    return UIDevice.current.userInterfaceIdiom == .pad
  }
  static func scaledValue(_ value: CGFloat) -> CGFloat {
    if isPad() {
      // Use a different scaling approach for iPads
//      return (width / designWidth) * value * 0.6 // Adjust the multiplier as needed
      return (width / (designWidth * 2)) * value// Adjust the multiplier as needed
    } else {
      return (width / designWidth) * value
    }
  }
    
    static func scaledSpacing(_ baseValue: CGFloat) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let scaleFactor = screenWidth / (isIPad ? designWidth * 2 : designWidth)
        if isPad() {
            // Adjust the spacing scale factor for iPads
            return baseValue * scaleFactor // Adjust the multiplier as needed
        } else {
            return baseValue * scaleFactor
        }
    }
}

extension View {
    func scaledFrame(baseWidth: CGFloat? = nil, baseHeight: CGFloat? = nil, alignment: Alignment? = nil) -> some View {
        let scaledWidth = baseWidth.flatMap { ScaleUtility.scaledValue($0) }.flatMap { $0 > 0 ? $0 : nil }
        let scaledHeight = baseHeight.flatMap { ScaleUtility.scaledValue($0) }.flatMap { $0 > 0 ? $0 : nil }
        
        return self.frame(width: scaledWidth, height: scaledHeight, alignment: alignment ?? .center)
    }
}


