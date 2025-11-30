//
//  ModernToggleStyle.swift
//  PicVerse
//
//  Created by Neel Kalariya on 13/10/25.
//

import Foundation
import Foundation
import SwiftUI

struct ModernToggleStyle: ToggleStyle {
    var toggleOnColor: Color = .secondaryApp
    var toggleOffColor: Color = .secondaryApp.opacity(0.1)
    var circleOnColor: Color = .accent
    var circleoffColor: Color = .primaryApp
    var size: CGSize = CGSize(width: 41, height: 24)
    var thumbSize: CGFloat = 20
    var cornerRadius: CGFloat = 16
    var thumbOffset: CGFloat = 8

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(configuration.isOn ? toggleOnColor : toggleOffColor)
                .frame(width: size.width, height: size.height)
                .overlay(
                    Circle()
                        .fill(configuration.isOn ? circleOnColor : circleoffColor)
                        .frame(width: thumbSize, height: thumbSize)
                        .offset(x: configuration.isOn ? thumbOffset : -thumbOffset)
                        .animation(.easeInOut(duration: 0.2), value: configuration.isOn)
                )
                .onTapGesture {
                    configuration.isOn.toggle()
                }
        }
        .padding(.trailing, 4)
    }
}
