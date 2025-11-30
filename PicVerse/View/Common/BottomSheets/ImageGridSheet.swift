//
//  ImageGridSheet.swift
//  PicVerse
//
//  Modern Pro style grid sheet for viewing all images (matches InputView look).
//

import SwiftUI
import PDFKit

struct ImageGridSheet: View {
    let imageURLs: [URL]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: ScaleUtility.scaledSpacing(18) ), count: 4)
    var onTapImage: (Int) -> Void
    var showDeleteButton: Bool = false
    var onDeleteImage: ((Int) -> Void)? = nil
    
    let notificationfeedback = UINotificationFeedbackGenerator()
    let impactfeedback = UIImpactFeedbackGenerator(style: .medium)
    let selectionfeedback = UISelectionFeedbackGenerator()
    
    @Binding  var navigateToPDFPreview: Bool
    @Binding  var selectedPDFFile: URL?
    
    var onBack: () -> Void
    
    // animation state
    @State private var animateGrid: Bool = false
    
    var body: some View {
        ZStack {
            
            Color.appGrey.ignoresSafeArea(.all)
            
        VStack {
            topBar
            
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: ScaleUtility.scaledSpacing(22)) {
                    ForEach(Array(imageURLs.enumerated()), id: \.0) { index, url in
                        ZStack(alignment: .topTrailing) {
                            sheetTile(url: url)
                                .onTapGesture {
                                    if url.pathExtension.lowercased() == "pdf" {
                                        impactfeedback.impactOccurred()
                                        selectedPDFFile = url
                                        withAnimation { navigateToPDFPreview = true }
                                    } else {
                                        onTapImage(index)
                                        AnalyticsManager.shared.log(.previewScreenOpen)
                                    }
                                }
                                .scaleEffect(animateGrid ? 1 : 0.98)
                                .opacity(animateGrid ? 1 : 0)
                                .animation(.spring(response: 0.6, dampingFraction: 0.85).delay(0.02 * Double(index)), value: animateGrid)
                            
                            if showDeleteButton {
                                Button(action: {
                                    let heavyfeedback = UIImpactFeedbackGenerator(style: .heavy)
                                    heavyfeedback.impactOccurred()
                                    onDeleteImage?(index)
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                        .background(Color.white.clipShape(Circle()))
                                }
                                .offset(x: ScaleUtility.scaledSpacing(6), y: ScaleUtility.scaledSpacing(-6))
                            }
                        }
                    }
                }
                .padding(.horizontal, ScaleUtility.scaledSpacing(26.5))
                .padding(.top, ScaleUtility.scaledSpacing(30.6))
            }
        }
        .onAppear {
            withAnimation { animateGrid = true }
        }
    }
}

    private var topBar: some View {
        HStack {
            Spacer()
            Text("All Images")
                .font(FontManager.instrumentSansMediumFont(size: .scaledFontSize(18)))
                .foregroundColor(.white)
            Spacer()
            Image("x")
                .resizable()
                .frame(width: isIPad ? ScaleUtility.scaledValue(14) : ScaleUtility.scaledValue(14),
                       height: isIPad ? ScaleUtility.scaledValue(14) : ScaleUtility.scaledValue(14))
                .onTapGesture {
                    impactfeedback.impactOccurred()
                    onBack()
                }
                .padding(.trailing, ScaleUtility.scaledSpacing(20))
        }
        .padding(.top, ScaleUtility.scaledSpacing(33.46))
    }

    @ViewBuilder
    private func sheetTile(url: URL) -> some View {
        if let image = renderImage(from: url) {
            CachedAsyncImageView(url: url, size: CGSize(width: 70, height: 70))
                .frame(width: isIPad ? ScaleUtility.scaledValue(80) : ScaleUtility.scaledValue(70),
                       height: isIPad ? ScaleUtility.scaledValue(80) : ScaleUtility.scaledValue(70))
                .cornerRadius(12)
                .clipped()
                .shadow(color: Color.black.opacity(0.45), radius: 14, x: 0, y: 10)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.02)))
        } else {
            Color.gray
                .frame(width: isIPad ? ScaleUtility.scaledValue(80) : ScaleUtility.scaledValue(70),
                       height: isIPad ? ScaleUtility.scaledValue(80) : ScaleUtility.scaledValue(70))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.45), radius: 14, x: 0, y: 10)
        }
    }

    func renderImage(from url: URL) -> UIImage? {
        let ext = url.pathExtension.lowercased()
        if ext == "pdf" {
            guard let pdfDocument = PDFDocument(url: url), let pdfPage = pdfDocument.page(at: 0) else { return nil }
            let targetSize = CGSize(width: 70, height: 70)
            let renderer = UIGraphicsImageRenderer(size: targetSize)
            return renderer.image { ctx in
                UIColor.white.set()
                ctx.fill(CGRect(origin: .zero, size: targetSize))
                let pageRect = pdfPage.bounds(for: .mediaBox)
                let scale = max(targetSize.width / pageRect.width, targetSize.height / pageRect.height)
                let scaledRect = CGRect(
                    x: (targetSize.width - pageRect.width * scale) / 2,
                    y: (targetSize.height - pageRect.height * scale) / 2,
                    width: pageRect.width * scale,
                    height: pageRect.height * scale
                )
                ctx.cgContext.saveGState()
                ctx.cgContext.translateBy(x: 0, y: targetSize.height)
                ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
                ctx.cgContext.translateBy(x: scaledRect.minX, y: scaledRect.minY)
                ctx.cgContext.scaleBy(x: scale, y: scale)
                pdfPage.draw(with: .mediaBox, to: ctx.cgContext)
                ctx.cgContext.restoreGState()
            }
        } else {
            return UIImage(contentsOfFile: url.path)
        }
    }
}
