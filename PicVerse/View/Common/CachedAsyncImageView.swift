//
//  CachedAsyncImageView.swift
//  PicVerse
//
//  Created by Neel Kalariya on 28/09/25.
//

import Foundation
import SwiftUI
import PDFKit


final class ImageRenderCache {
    static let shared = NSCache<NSString, UIImage>()
}



struct CachedAsyncImageView: View {
    let url: URL
    let size: CGSize
    
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: ScaleUtility.scaledValue(size.width), height: ScaleUtility.scaledValue(size.height))
                    .clipped()
                    .cornerRadius(5)
            } else {
                ProgressView()
                    .frame(width: size.width, height: size.height)
            }
        }
        .onAppear {
            loadImage()
        }
    }

    private func loadImage() {
        let cacheKey = NSString(string: url.lastPathComponent)

        // Check cache first
        if let cached = ImageRenderCache.shared.object(forKey: cacheKey) {
            self.image = cached
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let rendered = renderImage(from: url, size: size)
            if let rendered = rendered {
                ImageRenderCache.shared.setObject(rendered, forKey: cacheKey)
            }

            DispatchQueue.main.async {
                self.image = rendered
            }
        }
    }

    private func renderImage(from url: URL, size: CGSize) -> UIImage? {
        let ext = url.pathExtension.lowercased()
        if ext == "pdf" {
            guard let pdfDocument = PDFDocument(url: url),
                  let pdfPage = pdfDocument.page(at: 0) else { return nil }

            let renderer = UIGraphicsImageRenderer(size: size)
            return renderer.image { context in
                UIColor.white.set()
                context.fill(CGRect(origin: .zero, size: size))

                let pageRect = pdfPage.bounds(for: .mediaBox)
                let scale = max(size.width / pageRect.width, size.height / pageRect.height)
                let scaledRect = CGRect(
                    x: (size.width - pageRect.width * scale) / 2,
                    y: (size.height - pageRect.height * scale) / 2,
                    width: pageRect.width * scale,
                    height: pageRect.height * scale
                )

                context.cgContext.saveGState()
                context.cgContext.translateBy(x: 0, y: size.height)
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
