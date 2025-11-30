//
//  Image+Extension.swift
//  iOS-Picture-Converter
//
//  Created by Darsh Viroja on 02/05/25.
//

import Foundation
import SwiftUI
import UIKit

extension Image {
    func resizeImage() -> some View {
        self
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
    func resizable(size: CGSize) -> some View {
        self
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size.width, height: size.height)
    }
}

