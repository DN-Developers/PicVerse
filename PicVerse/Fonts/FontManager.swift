//
//  FontManager.swift
//  H2JPG
//
//  Created by Purvi Sancheti on 12/08/25.
//

import Foundation
import SwiftUI

struct FontManager {
    static var ceraProBoldFont = "CeraPro-Bold"
    static var instrumentSansMediumFont = "InstrumentSans-Bold"
    static var instrumentSansSemiBoldFont = "InstrumentSans-Medium"
    static var instrumentSansBoldFont = "InstrumentSans-SemiBold"
    static var instrumentSansRegularFont = "InstrumentSans-Regular"
    // MARK: - CeraPro
    
    static func ceraProBoldFont(size: CGFloat) -> Font {
        .custom(ceraProBoldFont, size: size)
    }
    
    // MARK: - InstrumentSans
    
    static func instrumentSansMediumFont(size: CGFloat) -> Font {
        .custom(instrumentSansMediumFont, size: size)
    }
    
    static func instrumentSansSemiBoldFont(size: CGFloat) -> Font {
        .custom(instrumentSansSemiBoldFont, size: size)
    }

    static func instrumentSansBoldFont(size: CGFloat) -> Font {
        .custom(instrumentSansBoldFont, size: size)
    }

    static func instrumentSansRegularFont(size: CGFloat) -> Font {
        .custom(instrumentSansRegularFont, size: size)
    }
 }


