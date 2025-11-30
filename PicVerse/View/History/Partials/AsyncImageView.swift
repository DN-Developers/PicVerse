//
//  AsyncImageView.swift
//  iOS-Picture-Converter
//
//  Created by Darsh Viroja on 09/05/25.
//

import Foundation
import SwiftUI
import PDFKit

struct AsyncImageView: View {
    let url: URL
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .clipped()
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            DispatchQueue.global(qos: .userInitiated).async {
                let img = renderImage(from: url)
                DispatchQueue.main.async {
                    self.image = img
                }
            }
        }
    }

    private func renderImage(from url: URL) -> UIImage? {
        let ext = url.pathExtension.lowercased()
        if ext == "pdf" {
            guard let pdfDocument = PDFDocument(url: url),
                  let pdfPage = pdfDocument.page(at: 0) else { return nil }

            let targetSize = CGSize(width: 33.75, height: 45)
            let renderer = UIGraphicsImageRenderer(size: targetSize)

            return renderer.image { context in
                UIColor.white.set()
                context.fill(CGRect(origin: .zero, size: targetSize))

                let pageRect = pdfPage.bounds(for: .mediaBox)
                let scale = max(targetSize.width / pageRect.width, targetSize.height / pageRect.height)
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

