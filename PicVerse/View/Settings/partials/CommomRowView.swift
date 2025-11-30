//
//  CommomRowView.swift
//  H2JPG
//
//  Created by Purvi Sancheti on 20/08/25.
//

import Foundation
import Foundation
import SwiftUI

struct CommonRowView: View {
    // MARK: - PROPERTIES
    @State var rowText: String
    @State var rowImage: String

    var body: some View {
        HStack(spacing: ScaleUtility.scaledSpacing(10)) {

                Image(rowImage)
                .resizable()
                .frame(width: isIPad ? 32 * ipadWidthRatio : 22,  height: isIPad ? 32 * ipadHeightRation : 22)
                .opacity(0.5)
                  

               Text(rowText)
                  .font(FontManager.instrumentSansMediumFont(size: .scaledFontSize(14)))
                  .foregroundColor(Color.secondaryApp)
          
            Spacer()
        }
       
    
    }
}

