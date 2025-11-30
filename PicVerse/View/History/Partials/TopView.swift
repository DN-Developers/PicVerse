//
//  TopView.swift
//  iOS-Picture-Converter
//
//  Created by Darsh Viroja on 02/05/25.
//

import Foundation
import SwiftUI


struct TopView: View {
    @ObservedObject var viewModel: ImageListViewModel
    @Binding  var searchText: String // 🔍 Search query
    @Binding  var selectedFilerName: Bool
    @StateObject private var keyboard = KeyboardObserver()
    
    let notificationfeedback = UINotificationFeedbackGenerator()
    let impactfeedback = UIImpactFeedbackGenerator(style: .light)
    let selectionfeedback = UISelectionFeedbackGenerator()
    
    @FocusState.Binding var isSearchFocused: Bool
    
    var body: some View {
        
        HStack(spacing: ScaleUtility.scaledSpacing(15)) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.appSoftGrey)
                    .frame(height: ScaleUtility.scaledValue(42) * heightRatio)
                    .frame(maxWidth: ScaleUtility.scaledValue(.infinity) * widthRatio)
                    .overlay {
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    }
                
                HStack {
                    
                   if isIPad {
                        Image(.magnifyingglass)
                            .resizable(size: CGSize(
                                width:  ScaleUtility.scaledValue(24),
                                height: ScaleUtility.scaledValue(22)))
                            .foregroundColor(.black)
                    }
                    
                    else {
                        Image(.magnifyingglass)
                            .foregroundColor(.white)
                            .opacity(0.55)
                    }
                      

                    ZStack(alignment: .leading) {
                        if !keyboard.isKeyboardVisible && searchText == "" {
                            Text("Search your file")
                                .font(FontManager.instrumentSansRegularFont(size: .scaledFontSize(17)))
                                .foregroundColor(.white)
                                .opacity(0.25)
                            
                        }

                        TextField("", text: $searchText)
                            .focused($isSearchFocused)
                            .foregroundColor(.white) // Keep typed text white
                            .font(FontManager.instrumentSansRegularFont(size: .scaledFontSize(17)))
                            .padding(.vertical, ScaleUtility.scaledSpacing(8))
                            .padding(.trailing, ScaleUtility.scaledSpacing(6.3))
                            .onTapGesture {
                                impactfeedback.impactOccurred()
                            }
                    }

                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            impactfeedback.impactOccurred()
                          
                        }) {
                            Image(.crossIcon2)
                                .resizable()
                                .frame(width: isIPad ? ScaleUtility.scaledValue(18) : ScaleUtility.scaledValue(12) ,
                                       height: isIPad ? ScaleUtility.scaledValue(18) : ScaleUtility.scaledValue(12))
                                .padding(.all, ScaleUtility.scaledSpacing(5))
                                .background(Color.secondaryApp.opacity(0.3))
                                .clipShape(Circle())
                                
                        }
                    }


                }
                .padding(.horizontal, ScaleUtility.scaledSpacing(8))
            }
           
           
            
            if !keyboard.isKeyboardVisible {
                Button {
                    selectedFilerName.toggle()
                    impactfeedback.impactOccurred()
                } label: {
                    Image("sortIcon")
                        .resizable(size: CGSize(
                            width:  isIPad ? ScaleUtility.scaledValue(34) :  ScaleUtility.scaledValue(24),
                            height: isIPad ? ScaleUtility.scaledValue(34) :  ScaleUtility.scaledValue(24)))
                        .padding(.all, ScaleUtility.scaledSpacing(10.9))
                        .background(Color.appGrey)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .overlay {
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        }
                }
                .disabled(viewModel.filteredFiles.isEmpty)
            
            }
          else {
                Text("Cancel")
                  .font(FontManager.instrumentSansRegularFont(size: .scaledFontSize(13)))
                  .multilineTextAlignment(.center)
                  .foregroundColor(.white)
                  .onTapGesture {
                      impactfeedback.impactOccurred()
                      searchText = ""
                      isSearchFocused.toggle()
                  }
            }
            
        }
        .padding(.horizontal, ScaleUtility.scaledSpacing(20))
    
    }
}



import SwiftUI
import Combine

class KeyboardObserver: ObservableObject {
    @Published var isKeyboardVisible = false
    private var cancellables: Set<AnyCancellable> = []

    init() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map { _ in true }
            .merge(with:
                NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
                    .map { _ in false }
            )
            .receive(on: RunLoop.main)
            .assign(to: \.isKeyboardVisible, on: self)
            .store(in: &cancellables)
    }
}
