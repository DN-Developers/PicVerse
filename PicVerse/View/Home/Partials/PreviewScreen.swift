//
//  PreviewScreen.swift
//  PicVerse
//
//  Created by Neel Kalariya on 28/09/25.
//

import Foundation
import SwiftUI
import PDFKit

struct PreviewScreen: View {
    @Binding var imageURLs: [URL]
    var onBack: () -> Void
    @State private var currentIndex: Int
    var onDelete: ((URL) -> Void)?
    var onShare: (URL) -> Void
    var onConvert: (URL) -> Void

    var isappear: Bool

    @Binding var shareWrapper: ShareWrapper?

    init(
        imageURLs: Binding<[URL]>,
        initialIndex: Int,
        onBack: @escaping () -> Void,
        onDelete: @escaping (URL) -> Void,
        onShare: @escaping (URL) -> Void,
        isappear: Bool,
        onConvert: @escaping (URL) -> Void,
        shareWrapper: Binding<ShareWrapper?> = .constant(nil) // 👈 DEFAULT ADDED
    ) {
        _imageURLs = imageURLs
        self._currentIndex = State(initialValue: initialIndex)
        self.onBack = onBack
        self.onDelete = onDelete
        self.onShare = onShare
        self.isappear = isappear
        self.onConvert = onConvert
        _shareWrapper = shareWrapper
    }


    
    let notificationfeedback = UINotificationFeedbackGenerator()
    let impactfeedback = UIImpactFeedbackGenerator(style: .medium)
    let selectionfeedback = UISelectionFeedbackGenerator()
    @State var isPaywallOn = false
    @EnvironmentObject var purchaseManager: PurchaseManager
    
    var body: some View {
        ZStack {
            
            LinearGradient(
                colors: [Color(hex: "050510"), Color(hex: "0C0F1A")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay(
                RadialGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.2), .clear]),
                    center: .topTrailing, startRadius: 40, endRadius: 600)
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar
                HStack(spacing: ScaleUtility.scaledSpacing(105)) {
                    Image("backIcon")
                        .resizable()
                        .frame(width: isIPad ? ScaleUtility.scaledValue(34) :  ScaleUtility.scaledValue(24) ,
                               height:isIPad ? ScaleUtility.scaledValue(34) :   ScaleUtility.scaledValue(24))
                        .onTapGesture {
                            impactfeedback.impactOccurred()
                            onBack()
                            print("preview screen")
                        }
                    
                    if isIPad
                    {
                        Spacer()
                    }
                    
                    Text("Preview")
                        .font(FontManager.instrumentSansMediumFont(size: .scaledFontSize(21)))
                        .foregroundColor(.white)
                    
                    if isIPad
                    {
                        Spacer()
                    }
                    
                    Button {
                        impactfeedback.impactOccurred()
                        isPaywallOn.toggle()
                    } label:
                    {
                        Image("crownIcon")
                            .resizable()
                            .frame(width: isIPad ? ScaleUtility.scaledValue(34) :  ScaleUtility.scaledValue(24) ,
                                   height:isIPad ? ScaleUtility.scaledValue(34) :   ScaleUtility.scaledValue(24))
                            .opacity(purchaseManager.hasPro ? 0 : 1)
                    }
                }
                .padding(.top, ScaleUtility.scaledSpacing(19))
                .padding(.horizontal, isIPad ? ScaleUtility.scaledSpacing(40) : 0)
                
                Spacer()
                
                // Swipeable images
                if imageURLs.isEmpty {
                    Text("No images to display")
                        .foregroundColor(.white)
                } else {
                    if let url = imageURLs[safe: currentIndex], let image = renderImage(from: url) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 6.56))
                            .shadow(radius: 5)
                            .padding()
                    }
                }
                
                Spacer()
                
                // Bottom bar
                if isappear {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(height: ScaleUtility.scaledValue(80) * heightRatio)
                        .frame(maxWidth:.infinity)
                        .background(Color.appGrey)
                        .overlay(
                            HStack(spacing: ScaleUtility.scaledSpacing(68)) {
                                Image("shareImage")
                                    .resizable()
                                    .resizable(size: CGSize(
                                        width: isIPad ? ScaleUtility.scaledValue(55) :  ScaleUtility.scaledValue(45),
                                        height: isIPad ?  ScaleUtility.scaledValue(53) : ScaleUtility.scaledValue(43)))
                                    .onTapGesture {
                                        impactfeedback.impactOccurred()
                                        if let url = imageURLs[safe: currentIndex] {
                                            onShare(url)
                                        }
                                        
                                    }
                                
                                if isIPad
                                {
                                    
                                    Spacer()
                                }
                                
                                Image("convert")
                                    .resizable()
                                    .resizable(size: CGSize(
                                        width: isIPad ? ScaleUtility.scaledValue(55) :  ScaleUtility.scaledValue(45),
                                        height: isIPad ?  ScaleUtility.scaledValue(55) : ScaleUtility.scaledValue(45)))
                                    .onTapGesture {
                                        impactfeedback.impactOccurred()
                                        if !isCurrentFilePDF {
                                            if let url = imageURLs[safe: currentIndex], !isCurrentFilePDF {
                                                onConvert(url)
                                            }
                                        }
                                    }
                                
                                
                                if isIPad
                                {
                                    
                                    Spacer()
                                }
                                
                                Image("delete")
                                    .resizable()
                                    .resizable(size: CGSize(
                                        width: isIPad ? ScaleUtility.scaledValue(55) :  ScaleUtility.scaledValue(45),
                                        height: isIPad ?  ScaleUtility.scaledValue(53) : ScaleUtility.scaledValue(43)))
                                    .onTapGesture {
                                        notificationfeedback.notificationOccurred(.warning)
                                        if let url = imageURLs[safe: currentIndex] {
                                            onDelete?(url)
                                        }
                                    }
                            }
                                .padding(.leading, ScaleUtility.scaledSpacing(50))
                                .padding(.trailing, ScaleUtility.scaledSpacing(51))
                                .padding(.bottom, ScaleUtility.scaledSpacing(15))
                        )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $isPaywallOn)
        {
            PaywallView(dismissAction: {
                withAnimation {
                    isPaywallOn = false
                }
            }, isInternalOpen: true,
                    purchaseCompletSuccessfullyAction:{
                isPaywallOn = false
            })
        }
        .sheet(item: $shareWrapper) { wrapper in
            ActivityViewController(activityItems: wrapper.urls)
        }


    }
    
    private var isCurrentFilePDF: Bool {
        return imageURLs.first?.pathExtension.lowercased() == "pdf"
    }

    private func deleteCurrentImage() {
        guard !imageURLs.isEmpty else { return }
        imageURLs.remove(at: currentIndex)
        if currentIndex >= imageURLs.count {
            currentIndex = max(0, imageURLs.count - 1)
        }
    }

    func renderImage(from url: URL) -> UIImage? {
        let ext = url.pathExtension.lowercased()
        if ext == "pdf" {
            guard let pdfDocument = PDFDocument(url: url),
                  let pdfPage = pdfDocument.page(at: 0) else { return nil }

            let targetSize = CGSize(width: 331, height: 534)
            let renderer = UIGraphicsImageRenderer(size: targetSize)

            return renderer.image { context in
                UIColor.white.set()
                context.fill(CGRect(origin: .zero, size: targetSize))

                let pageRect = pdfPage.bounds(for: .mediaBox)
                let scale = min(targetSize.width / pageRect.width, targetSize.height / pageRect.height)
                let scaledRect = CGRect(
                    x: (targetSize.width - pageRect.width * scale) / 2,
                    y: (targetSize.height - pageRect.height * scale) / 2,
                    width: pageRect.width * scale,
                    height: pageRect.height * scale
                )

                context.cgContext.saveGState()
                context.cgContext.translateBy(x: 0, y: targetSize.height)
                context.cgContext.scaleBy(x: 1.0, y: -1.0)
                context.cgContext.translateBy(x: scaledRect.minX, y: scaledRect.minY)
                context.cgContext.scaleBy(x: scale, y: scale)

                pdfPage.draw(with: .mediaBox, to: context.cgContext)
                context.cgContext.restoreGState()
            }
        } else {
            return UIImage(contentsOfFile: url.path)
        }
    }
}
extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
