//
//  ConvertionView.swift
//  PicVerse
//
//  Created by Neel Kalariya on 28/09/25.
//

import SwiftUI
import UIKit
import SDWebImage
import SDWebImageWebPCoder


struct ConvertingScreen: View {
    @State private var decodedImage: UIImage? = nil
    @State private var rotationAngle: Angle = .zero
    @State private var progress: CGFloat = 0
    @State private var imagesConverted: Int = 0
    @State private var cancelConversion = false
    @State private var isComplete = false
    @State private var convertedImages: [UIImage] = []
    @State private var convertedFilesURLs: [URL] = []
    
    @Binding var imageURLs: [URL]
    var selectedFormat: String
    
    let totalImages: Int
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State private var navigateToFileOutput = false
    var onback: () -> Void
    var onClose: () -> Void
    @Binding var outputFormatScreen: Bool
    
    var pdfOption: PDFConversionOption? = nil

    @State private var visualProgress: CGFloat = 0
    @State private var conversionTask: Task<Void, Never>? = nil

    let notificationfeedback = UINotificationFeedbackGenerator()
    let impactfeedback = UIImpactFeedbackGenerator(style: .heavy)
    let selectionfeedback = UISelectionFeedbackGenerator()
  
    
  
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
            
            if navigateToFileOutput {
                OutputView(
                    convertedFilesURLs: $convertedFilesURLs,
                    onBack: {
                        onback()
                    },onClose: {
                        onClose()
                    },
                    outputFormatScreen: $outputFormatScreen
                )
            }
            else {
                VStack(spacing: 0) {
                    
                    Spacer()
                    
                    VStack(spacing: ScaleUtility.scaledSpacing(44))  {
                        
                        VStack(spacing:ScaleUtility.scaledSpacing(8))
                        {
                            Text("Converting")
                                .font(FontManager.instrumentSansSemiBoldFont(size: .scaledFontSize(24)))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                            
                            
                            Text("Please wait for a while")
                                .font(FontManager.instrumentSansRegularFont(size: .scaledFontSize(16)))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                            
                        }
                        
                        VStack(spacing: ScaleUtility.scaledSpacing(14))
                        {
                            // Circular Progress Indicator
                            CircularProgressView(
                                progress: visualProgress,
                                isComplete: isComplete,
                                size: isIPad ? ScaleUtility.scaledValue(90) : ScaleUtility.scaledValue(80)
                            )
                            
                            Text("\(Int(visualProgress * 100))%")
                                .font(FontManager.instrumentSansBoldFont(size: .scaledFontSize(24)))
                                .foregroundColor(.white)
                            
                        }
                        
                        
                        Button(action: {
                            AnalyticsManager.shared.log(.cancel)
                            impactfeedback.impactOccurred()
                            cancelAndCleanUp()
                            onback()
                        }, label: {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: isIPad ?  ScaleUtility.scaledValue(330) : ScaleUtility.scaledValue(230)  ,
                                       height:isIPad ? ScaleUtility.scaledValue(62) :   ScaleUtility.scaledValue(52))
                                .background(.white)
                                .cornerRadius(10)
                                .overlay
                            {
                                Text("Cancel")
                                    .font(FontManager.instrumentSansMediumFont(size: .scaledFontSize(16)))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(Color.primaryApp)
                            }
                        })
                        
                    }
                    
                    
                    Spacer()
                    
                    
                    Text("Don't press back or close the app.")
                        .font(FontManager.instrumentSansRegularFont(size: .scaledFontSize(14)))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding(.bottom,ScaleUtility.scaledSpacing(91))
                    
                }
                .frame(maxWidth:.infinity)
                .navigationBarHidden(true)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        progress = 0
                        visualProgress = 0
                        imagesConverted = 0
                        isComplete = false
                        convertImages()
                    }
                }
                .onReceive(timer) { _ in
                    if isComplete && visualProgress < 1.0 {
                        // Instantly fill to 100% when complete
                        visualProgress = 1.0
                    } else if visualProgress < progress {
                        visualProgress = min(visualProgress + 0.01, progress)
                    }
                }
            }
            
        }
    }

    func cancelAndCleanUp() {
        conversionTask?.cancel()

        for url in convertedFilesURLs {
            try? FileManager.default.removeItem(at: url)
            CoreDataManager.shared.deleteCompressedFile(for: url)
        }

        convertedFilesURLs.removeAll()
    }

    func convertToPDF(image: UIImage) -> Data? {
        let pdfMetaData = [
            kCGPDFContextCreator: "iOS-Picture-Converter",
            kCGPDFContextAuthor: "MoonSpace"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth = image.size.width
        let pageHeight = image.size.height
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let data = renderer.pdfData { (context) in
            context.beginPage()
            image.draw(in: pageRect)
        }

        return data
    }
    
    
    func convertAllImagesToSinglePDF(images: [UIImage]) -> Data? {
        let pdfMetaData = [
            kCGPDFContextCreator: "iOS-Picture-Converter",
            kCGPDFContextAuthor: "Neel-Kalaria"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth: CGFloat = 595.2
        let pageHeight: CGFloat = 841.8
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let data = renderer.pdfData { context in
            for image in images {
                context.beginPage()

                let imageSize = image.size
                let maxWidth = pageRect.width
                let maxHeight = pageRect.height

                let widthRatio = maxWidth / imageSize.width
                let heightRatio = maxHeight / imageSize.height
                let scaleFactor = min(widthRatio, heightRatio)

                let scaledWidth = imageSize.width * scaleFactor
                let scaledHeight = imageSize.height * scaleFactor
                let x = (pageRect.width - scaledWidth) / 2
                let y = (pageRect.height - scaledHeight) / 2

                image.draw(in: CGRect(x: x, y: y, width: scaledWidth, height: scaledHeight))
            }
        }

        return data
    }



    func convertToHEIC(image: UIImage) -> Data? {
        guard let ciImage = CIImage(image: image) else { return nil }
        let context = CIContext()
        return context.heifRepresentation(of: ciImage, format: .RGBA8, colorSpace: CGColorSpaceCreateDeviceRGB(), options: [:])
    }
    
    func generateUniqueRandomNumber() -> Int? {
        let key = "usedImageNumbers"
        var usedNumbers = UserDefaults.standard.array(forKey: key) as? [Int] ?? []

        guard usedNumbers.count < 9000 else {
            print("⚠️ All unique numbers used!")
            return nil
        }

        var newNumber: Int
        repeat {
            newNumber = Int.random(in: 1000...9999)
        } while usedNumbers.contains(newNumber)

        usedNumbers.append(newNumber)
        UserDefaults.standard.set(usedNumbers, forKey: key)

        return newNumber
    }
    
    func saveConvertedFile(data: Data, formatExt: String, originalFileName: String) -> URL? {
        let fileManager = FileManager.default
        let documentsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!

        let formatPrefix = formatExt.uppercased() == "PDF" ? "PDF" : "IMG"
        let key = "outputIndex_\(formatExt.uppercased())"

        var lastIndex = UserDefaults.standard.integer(forKey: key)
        lastIndex += 1
        UserDefaults.standard.set(lastIndex, forKey: key)

        let paddedNumber = String(format: "%03d", lastIndex)
        let fileName = "\(formatExt.uppercased())_Converted_\(paddedNumber).\(formatExt.uppercased())"
        var outputURL = documentsDir.appendingPathComponent(fileName)

        var fallbackIndex = 1
        while fileManager.fileExists(atPath: outputURL.path) {
            let fallbackName = "\(formatExt.uppercased())_Converted_\(paddedNumber)_\(fallbackIndex).\(formatExt.uppercased())"
            outputURL = documentsDir.appendingPathComponent(fallbackName)
            fallbackIndex += 1
        }

        do {
            try data.write(to: outputURL)
            print("✅ Saved converted file:", outputURL.lastPathComponent)
            CoreDataManager.shared.saveCompressedFile(from: outputURL, source: "Output Files", preserveFileName: true)
            return outputURL
        } catch {
            print("❌ Failed to save converted file:", error)
            return nil
        }
    }

    func convertImages() {
        conversionTask = Task {
            if Task.isCancelled { return }

            if selectedFormat == "PDF", pdfOption == .singlePDF {
                let uiImages = imageURLs.compactMap { UIImage(contentsOfFile: $0.path) }

                for (index, _) in uiImages.enumerated() {
                    if Task.isCancelled { return }
                    DispatchQueue.main.async {
                        progress = CGFloat(index + 1) / CGFloat(uiImages.count)
                    }
                    try? await Task.sleep(nanoseconds: 100_000_000)
                }

                if Task.isCancelled { return }

                if let data = convertAllImagesToSinglePDF(images: uiImages),
                   let fileURL = saveConvertedFile(data: data, formatExt: "PDF", originalFileName: "AllInOne.pdf") {
                    DispatchQueue.main.async {
                        convertedFilesURLs.append(fileURL)
                        progress = 1.0
                        isComplete = true
                        // Wait for fill + checkmark animations to complete (0.3s fill + 0.4s checkmark + 0.5s buffer)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            navigateToFileOutput = true
                        }
                    }
                }
                return
            }

            for (index, url) in imageURLs.enumerated() {
                if Task.isCancelled { return }

                guard let uiImage = UIImage(contentsOfFile: url.path) else { continue }

                var data: Data?
                var ext = ""

                switch selectedFormat {
                case "JPEG", "JPG":
                    data = SDImageCodersManager.shared.encodedData(with: uiImage, format: .JPEG, options: nil)
                    ext = selectedFormat
                case "PNG":
                    data = SDImageCodersManager.shared.encodedData(with: uiImage, format: .PNG, options: nil)
                    ext = "PNG"
                case "GIF":
                    data = SDImageCodersManager.shared.encodedData(with: uiImage, format: .GIF, options: nil)
                    ext = "GIF"
                case "HEIC":
                    data = convertToHEIC(image: uiImage)
                    ext = "HEIC"
                case "WEBP":
                    data = SDImageCodersManager.shared.encodedData(with: uiImage, format: .webP, options: nil)
                    ext = "WEBP"
                case "BMP":
                    data = SDImageCodersManager.shared.encodedData(with: uiImage, format: .BMP, options: nil)
                    ext = "BMP"
                case "TIFF":
                    data = SDImageCodersManager.shared.encodedData(with: uiImage, format: .TIFF, options: nil)
                    ext = "TIFF"
                case "PDF":
                    data = convertToPDF(image: uiImage)
                    ext = "PDF"
                default:
                    break
                }

                if Task.isCancelled { return }

                if let data = data,
                   let fileURL = saveConvertedFile(data: data, formatExt: ext, originalFileName: url.lastPathComponent) {

                    if Task.isCancelled {
                        try? FileManager.default.removeItem(at: fileURL)
                        CoreDataManager.shared.deleteCompressedFile(for: fileURL)
                        return
                    }

                    DispatchQueue.main.async {
                        convertedFilesURLs.append(fileURL)
                    }
                }

                try? await Task.sleep(nanoseconds: 300_000_000)

                DispatchQueue.main.async {
                    imagesConverted = index + 1
                    progress = CGFloat(imagesConverted) / CGFloat(totalImages)

                    if imagesConverted == totalImages {
                        isComplete = true
                        // Wait for fill + checkmark animations to complete (0.3s fill + 0.4s checkmark + 0.5s buffer)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            navigateToFileOutput = true
                        }
                    }
                }
            }
        }
    }

}

// MARK: - Circular Progress View
struct CircularProgressView: View {
    let progress: CGFloat
    let isComplete: Bool
    let size: CGFloat
    private let strokeWidth: CGFloat = 5
    @State private var showCheckmark = false
    
    var body: some View {
        ZStack {
            // Background Circle
            Circle()
                .stroke(Color.secondaryApp.opacity(0.2), lineWidth: strokeWidth)
                .frame(width: size, height: size)
            
            // Progress Circle (counter-clockwise)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.secondaryApp,
                    style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(90)) // Changed from -90 to 90 for counter-clockwise
                .rotation3DEffect(.degrees(180), axis: (x: 1, y: 0, z: 0)) // Flip to make it go counter-clockwise
                .animation(.linear(duration: 0.1), value: progress)
            
            if !isComplete {
                ZStack {
                    Circle()
                        .fill(Color.secondaryApp)
                        .frame(width: isIPad ? ScaleUtility.scaledValue(80) : ScaleUtility.scaledValue(70),
                               height: isIPad ? ScaleUtility.scaledValue(80) : ScaleUtility.scaledValue(70))
                    
                    Image(.updownarrowIcon)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.appGrey)
                        .frame(width: isIPad ? ScaleUtility.scaledValue(50) : ScaleUtility.scaledValue(35),
                               height: isIPad ? ScaleUtility.scaledValue(50) : ScaleUtility.scaledValue(35))
                }
            } else {
                // Fill animation when complete
                Circle()
                    .fill(Color.secondaryApp)
                    .frame(width: isIPad ? ScaleUtility.scaledValue(80) : ScaleUtility.scaledValue(70),
                           height:isIPad ? ScaleUtility.scaledValue(80) :  ScaleUtility.scaledValue(70))
                    .scaleEffect(showCheckmark ? 1.0 : 0.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: showCheckmark)
//
                // Checkmark appears after fill
                if showCheckmark {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: isIPad ? ScaleUtility.scaledValue(50) : ScaleUtility.scaledValue(35),
                               height: isIPad ? ScaleUtility.scaledValue(50) : ScaleUtility.scaledValue(35))
                        .foregroundColor(.appGrey)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .onChange(of: isComplete) { newValue in
            if newValue {
                // Delay checkmark appearance to let fill animation complete
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showCheckmark = true
                }
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isComplete)
    }
}
