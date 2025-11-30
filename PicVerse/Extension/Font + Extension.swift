//
//  ScaleFont.swift
//  iOS-Picture-Converter
//
//  Created by Darsh Viroja on 02/05/25.
//

import Foundation
import SwiftUI

extension CGFloat {
    
    
  // Calculate scaled font size
  static func scaledFontSize(_ baseSize: CGFloat) -> CGFloat {
    let screenWidth = UIScreen.main.bounds.width
    let scaleFactor = screenWidth / 375
    if isIPad {
      // Use a different scaling approach for iPads
      return baseSize * scaleFactor * 0.7 // Adjust the multiplier as needed
    } else {
      return baseSize * scaleFactor
    }
  }
}
