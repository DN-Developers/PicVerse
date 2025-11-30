import Foundation
import SwiftUI

struct CommentView: View {
    
    @Binding var isAppears: Bool
    var isActive: Bool
    
    @State var isShowTitle: Bool = false
    
    // Animation states
    @State private var leftCommentOffset: CGFloat = -UIScreen.main.bounds.width
    @State private var rightCommentOffset: CGFloat = UIScreen.main.bounds.width
    @State private var leftCommentOpacity: Double = 0
    @State private var rightCommentOpacity: Double = 0
    
    var body: some View {
        
        ZStack {
            // MARK: - Background with inverted gradient
            LinearGradient(
                colors: [Color(hex: "050510"), Color(hex: "0C0F1A")],
                startPoint: .bottom,
                endPoint: .top
            )
            .overlay(
                RadialGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.2), .clear]),
                    center: .bottomTrailing, startRadius: 40, endRadius: 600)
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                VStack(spacing: isIPad ? ScaleUtility.scaledSpacing(36) : ScaleUtility.scaledSpacing(24)) {
                    
                    Text("What our users say")
                        .font(FontManager.instrumentSansRegularFont(size: .scaledFontSize(32)))
                        .foregroundColor(Color.secondaryApp)
                        .padding(.top, ScaleUtility.scaledSpacing(76))
                        .scaleEffect(isShowTitle ? 1.0 : 0.5)
                        .opacity(isShowTitle ? 1.0 : 0.0)
                    
                    // First comment — slides in from LEFT
                    HStack {
                        if isAppears {
                            Image(.comment1)
                                .resizable()
                                .frame(width: isIPad ? ScaleUtility.scaledValue(490) : ScaleUtility.scaledValue(327),
                                       height: isIPad ? ScaleUtility.scaledValue(303) :  ScaleUtility.scaledValue(202))
                                .offset(x: leftCommentOffset)
                                .opacity(leftCommentOpacity)
                                .transition(.move(edge: .leading))
                        }
                        
                        if isIPad {
                            Spacer()
                                .frame(width: 60 * widthRatio)
                        } else {
                            Spacer()
                        }
                    }
                    .padding(.leading, ScaleUtility.scaledSpacing(10))
                    
                    // Second comment — slides in from RIGHT
                    HStack {
                        
                        if isIPad {
                            Spacer()
                                .frame(width: 60 * widthRatio)
                        } else {
                            Spacer()
                        }
                        if isAppears {
                            Image(.comment2)
                                .resizable()
                                .frame(width: isIPad ? ScaleUtility.scaledValue(490) : ScaleUtility.scaledValue(327),
                                       height: isIPad ? ScaleUtility.scaledValue(303) :  ScaleUtility.scaledValue(202))
                                .offset(x: rightCommentOffset)
                                .opacity(rightCommentOpacity)
                                .transition(.move(edge: .trailing))
                        }
                    }
                    .padding(.trailing, ScaleUtility.scaledSpacing(10))
                    
                }
                
                Spacer()
            }
        }
        .background(Color.primaryApp.ignoresSafeArea(.all))
        .onChange(of: isActive) { oldValue, newValue in
            if newValue {
                performAnimation()
            }
        }
        .onAppear {
            if isActive {
                performAnimation()
            }
        }
    }
    
    private func performAnimation() {
        // Reset
        
        self.isShowTitle = false
        self.isAppears = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.interpolatingSpring(stiffness: 100, damping: 15).delay(0.2)) {
                isShowTitle = true
            }
        }
        
     
           DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
               withAnimation(.easeInOut(duration: 0.6)) {
                   self.isAppears = true
               }
           }
        
        leftCommentOffset = -UIScreen.main.bounds.width
        rightCommentOffset = UIScreen.main.bounds.width
        leftCommentOpacity = 0
        rightCommentOpacity = 0
        
        // Animate in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation {
                leftCommentOffset = 0
                leftCommentOpacity = 1
            }
            withAnimation(.easeInOut(duration: 0.6).delay(0.2)) {
                rightCommentOffset = 0
                rightCommentOpacity = 1
            }
        }
    }
}
