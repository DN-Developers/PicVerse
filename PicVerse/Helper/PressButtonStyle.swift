//
//  PressButtonStyle.swift
//  WPIX
//
//  Created by Purvi Sancheti on 28/10/25.
//

import Foundation
import SwiftUI

// Custom button style for press detection
struct PressButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { oldValue, newValue in
                isPressed = newValue
            }
    }
}

