//
//  OutputView.swift
//  PicVerse
//
//  Created by Neel Kalariya on 28/09/25.
//

import Foundation
import SwiftUI
import CoreData
import SDWebImage
import UniformTypeIdentifiers
import PDFKit
import SwiftUI
import Photos
import UIKit

struct OutputView: View {
    @State private var showPermissionDeniedAlert = false

    @Binding var convertedFilesURLs: [URL]
    var onBack: () -> Void
    var onClose: () -> Void
    @State private var showShareSheet = false
    @State private var saveStatusMessage: String?
    @State var showSheet: Bool = false
    @State var navToPreviewScreen: Bool = false
    
    @State private var selectedIndex: Int = 0
    
    @Binding var outputFormatScreen: Bool
    
    @State private var navigateToPDFPreview = false
    @State private var selectedPDFFile: URL? = nil
    @State private var showDocumentPicker = false
    
    let notificationfeedback = UINotificationFeedbackGenerator()
    let impactfeedback = UIImpactFeedbackGenerator(style: .medium)
    let selectionfeedback = UISelectionFeedbackGenerator()
  
    @State private var showsavedfromlibrarypopup = false
    @EnvironmentObject var purchaseManager: PurchaseManager
    @State var isPaywallOn = false
    
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
            
            if navigateToPDFPreview {
                PDFPreview(pdfURL: selectedPDFFile!,
                           previewScreen: $navigateToPDFPreview,
                           onback: {
                    withAnimation {
                        navToPreviewScreen = false
                    }
                }, istrue: false)
                .transition(.asymmetric(insertion: .scale, removal: .scale))
                .animation(.easeInOut(duration: 0.3), value: navigateToPDFPreview)
            } else if navToPreviewScreen {
                PreviewScreen(imageURLs: $convertedFilesURLs,
                              initialIndex: selectedIndex,
                              onBack: {
                    navToPreviewScreen = false
                    selectedIndex = 0
                },
                              onDelete: {_ in },
                              onShare: {_ in},
                              isappear: false,
                              onConvert: { _ in
                    
                })
            } else {
                mainContentView
            }
        }
        .alert("Photos Access Required", isPresented: $showPermissionDeniedAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please grant photo library access to save your converted images.")
        }

    }
    
    // MARK: - Main Content View
    private var mainContentView: some View {
        ZStack(alignment: .top) {

            
            VStack(spacing: 0) {
                
                Spacer()
                    .frame(height: isIPad ? ScaleUtility.scaledSpacing(159) : ScaleUtility.scaledSpacing(79))
                
                imageContentView
                    .contentShape(RoundedRectangle(cornerRadius: 12))
                    .clipped()
                
                
                Spacer()
                    .frame(height: ScaleUtility.scaledSpacing(40))
                
                actionButtonsView
                    .padding(.horizontal, ScaleUtility.scaledSpacing(20))
                
                Spacer()
            }
            
            
            headerView
                .padding(.top, isIPad ? ScaleUtility.scaledSpacing(29) : ScaleUtility.scaledSpacing(19))
                .padding(.horizontal, isIPad ? ScaleUtility.scaledSpacing(40) : ScaleUtility.scaledSpacing(20))
        }
        .frame(maxWidth: .infinity)
        .navigationBarHidden(true)
        .overlay(alignment: .bottom) {
            saveConfirmationPopup
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: convertedFilesURLs)
        }
        .sheet(isPresented: $showSheet) {
            ImageGridSheet(
                imageURLs: convertedFilesURLs,
                onTapImage: { index in
                    selectedIndex = index
                    withAnimation {
                        impactfeedback.impactOccurred()
                        navToPreviewScreen.toggle()
                    }
                },
                navigateToPDFPreview: $navigateToPDFPreview,
                selectedPDFFile: $selectedPDFFile,
                onBack: {
                    showSheet = false
                })
            .frame(height: isIPad ? 676.65668 : 576.65668)
            .presentationDragIndicator(.visible)
            .presentationDetents([.height(isIPad ? 676.65668 : 576.65668)])
        }
        .sheet(isPresented: $showDocumentPicker) {
            DocumentSaver(urls: convertedFilesURLs)
        }
        .fullScreenCover(isPresented: $isPaywallOn) {
            PaywallView(dismissAction: {
                withAnimation {
                    isPaywallOn = false
                }
            }, isInternalOpen: true,
                        purchaseCompletSuccessfullyAction: {
                isPaywallOn = false
            })
        }
        .onChange(of: showsavedfromlibrarypopup) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showsavedfromlibrarypopup = false
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack(spacing: ScaleUtility.scaledSpacing(93)) {
            Button(action: {
                impactfeedback.impactOccurred()
                onBack()
                print("output screen screen")
            }) {
                Image("backIcon")
                    .resizable()
                    .frame(width: isIPad ? ScaleUtility.scaledValue(34) : ScaleUtility.scaledValue(24),
                           height: isIPad ? ScaleUtility.scaledValue(34) : ScaleUtility.scaledValue(24))
            }
            
            if isIPad {
                Spacer()
            }
            
            Text("Converted")
                .font(FontManager.instrumentSansSemiBoldFont(size: .scaledFontSize(20)))
                .foregroundColor(.white)
            
            if isIPad {
                Spacer()
            }
            
            Button(action: {
                isPaywallOn.toggle()
            }) {
                Image(.crownIcon)
                    .resizable(size: CGSize(
                        width: isIPad ? ScaleUtility.scaledValue(34) : ScaleUtility.scaledValue(24),
                        height: isIPad ? ScaleUtility.scaledValue(34) : ScaleUtility.scaledValue(24)))
                    .opacity(purchaseManager.hasPro ? 0 : 1)
            }
        }
    }
    
    // MARK: - Image Content View
    private var imageContentView: some View {
        Group {
            if convertedFilesURLs.count == 1 {
                HStack {
                    Spacer()
                    imageCell(url: convertedFilesURLs[0])
                    Spacer()
                }
                .frame(maxWidth: .infinity,
                       minHeight: isIPad ? ScaleUtility.scaledValue(700) : ScaleUtility.scaledValue(400),
                       alignment: .top)
            } else {
                imageGrid
                    .frame(maxWidth: .infinity,
                           minHeight: isIPad ? ScaleUtility.scaledValue(700) : ScaleUtility.scaledValue(400),
                           alignment: .top)
                    .padding(.horizontal, ScaleUtility.scaledSpacing(20))
            }
        }
    }
    
    // MARK: - Action Buttons View
    private var actionButtonsView: some View {
        let containsPDF = convertedFilesURLs.contains { $0.pathExtension.lowercased() == "pdf" }
        
        return VStack(spacing: ScaleUtility.scaledSpacing(16)) {
            // Horizontal row for Add to Photos/Files and Share
            HStack(spacing: ScaleUtility.scaledSpacing(12)) {
                // Add to Photos/Files Button
                Button(action: {
                    if containsPDF {
                        showDocumentPicker = true
                        impactfeedback.impactOccurred()
                        AnalyticsManager.shared.log(.addToFiles)
                    } else {
                        saveAllToPhotos()
                        impactfeedback.impactOccurred()
                        AnalyticsManager.shared.log(.addToPhotos)
                    }
                }) {
                    HStack(spacing: ScaleUtility.scaledSpacing(6)) {
                        Image("addtolibrary")
                            .resizable()
                            .frame(width: isIPad ? ScaleUtility.scaledValue(24) : ScaleUtility.scaledValue(20),
                                   height: isIPad ? ScaleUtility.scaledValue(24) : ScaleUtility.scaledValue(20))
                        
                        Text(containsPDF ? "Save to Files" : "Add to Photos")
                            .font(FontManager.instrumentSansMediumFont(size: .scaledFontSize(14)))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: isIPad ? ScaleUtility.scaledValue(62) : ScaleUtility.scaledValue(52))
                    .background(Color.appGrey)
                    .cornerRadius(500)
                    .overlay(
                        RoundedRectangle(cornerRadius: 500)
                            .stroke(Color.white.opacity(0.4), lineWidth: 1)
                    )
                }
                
                // Share Button
                Button(action: {
                    impactfeedback.impactOccurred()
                    showShareSheet = true
                    AnalyticsManager.shared.log(.shareAnywhere)
                }) {
                    HStack(spacing: ScaleUtility.scaledSpacing(6)) {
                        Image("shareall")
                            .resizable()
                            .frame(width: isIPad ? ScaleUtility.scaledValue(24) : ScaleUtility.scaledValue(20),
                                   height: isIPad ? ScaleUtility.scaledValue(24) : ScaleUtility.scaledValue(20))
                        
                        Text("Share")
                            .font(FontManager.instrumentSansMediumFont(size: .scaledFontSize(14)))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: isIPad ? ScaleUtility.scaledValue(62) : ScaleUtility.scaledValue(52))
                    .background(Color.appGrey)
                    .cornerRadius(500)
                    .overlay(
                        RoundedRectangle(cornerRadius: 500)
                            .stroke(Color.white.opacity(0.4), lineWidth: 1)
                    )
                }
            }
            
            // Convert More Button (Full Width)
            Button(action: {
                impactfeedback.impactOccurred()
                onClose()
                AnalyticsManager.shared.log(.convertMore)
            }) {
                ZStack {
                    Image(.buttonBg)
                        .resizable()
                        .frame(height: isIPad ? ScaleUtility.scaledValue(62) :  ScaleUtility.scaledValue(52))
                        .frame(maxWidth: .infinity)
                  
                    Text("Convert More")
                        .font(FontManager.instrumentSansMediumFont(size: .scaledFontSize(16)))
                        .foregroundColor(Color.secondaryApp)
                }
            }
        }
    }
    
    // MARK: - Save Confirmation Popup
    private var saveConfirmationPopup: some View {
        Group {
            if showsavedfromlibrarypopup {
                VStack {
                    Text("Images Saved!")
                        .font(FontManager.instrumentSansRegularFont(size: .scaledFontSize(14)))
                        .fontWeight(.medium)
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .transition(.scale)
                }
                .offset(y: ScaleUtility.scaledSpacing(-350))
            }
        }
    }
    
    // MARK: - Image Grid
    private var imageGrid: some View {
        let firstRow = Array(convertedFilesURLs.prefix(3))
        let secondRow = Array(convertedFilesURLs.dropFirst(3).prefix(3))
        let thirdRow = Array(convertedFilesURLs.dropFirst(6).prefix(3))
        let hasCover = convertedFilesURLs.count > 9
        let extraCount = convertedFilesURLs.count - 9

        return VStack(alignment: .leading, spacing: ScaleUtility.scaledSpacing(18)) {
            HStack(spacing: ScaleUtility.scaledSpacing(18)) {
                ForEach(firstRow, id: \.self) { url in
                    imageCell(url: url)
                }
            }

            HStack(spacing: ScaleUtility.scaledSpacing(18)) {
                ForEach(secondRow, id: \.self) { url in
                    imageCell(url: url)
                }
            }
            
            HStack(spacing: ScaleUtility.scaledSpacing(18)) {
                ForEach(0..<thirdRow.count, id: \.self) { index in
                    let url = thirdRow[index]

                    if hasCover && index == thirdRow.count - 1 {
                        // last item should show +X overlay
                        imageCellWithOverlay(url: url, extraCount: extraCount)
                    } else {
                        imageCell(url: url)
                    }
                }
            }

        }
    }
    
    // MARK: - Image Cell
    @ViewBuilder
    private func imageCell(url: URL) -> some View {
        let ext = url.pathExtension.lowercased()
        let image: UIImage? = {
            if ext == "pdf" {
                return renderFirstPageOfPDF(url: url)
            } else {
                return UIImage(contentsOfFile: url.path)
            }
        }()

        if let image = image {
            
            if convertedFilesURLs.count == 1  {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: isIPad ? ScaleUtility.scaledValue(535) :  ScaleUtility.scaledValue(335)
                           ,height: isIPad ? ScaleUtility.scaledValue(535) :  ScaleUtility.scaledValue(345))
                    .cornerRadius(12)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .onTapGesture {
                        handleImageTap(url: url)
                    }
            }
            else {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: isIPad ? ScaleUtility.scaledValue(120) :  ScaleUtility.scaledValue(70),
                           height: isIPad ? ScaleUtility.scaledValue(120) : ScaleUtility.scaledValue(70))
                    .cornerRadius(12)
                    .clipped()
                    .onTapGesture {
                        handleImageTap(url: url)
                    }
            }
         
 
        } else {
            Color.gray
                .frame(width: isIPad ? ScaleUtility.scaledValue(120) : ScaleUtility.scaledValue(70),
                       height: isIPad ? ScaleUtility.scaledValue(120) : ScaleUtility.scaledValue(70))
                .cornerRadius(12)
        }
    }

    // MARK: - Image Cell With Overlay
    @ViewBuilder
    private func imageCellWithOverlay(url: URL, extraCount: Int) -> some View {
        ZStack {
            let ext = url.pathExtension.lowercased()
            let image: UIImage? = {
                if ext == "pdf" {
                    return renderFirstPageOfPDF(url: url)
                } else {
                    return UIImage(contentsOfFile: url.path)
                }
            }()
     
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: isIPad ? ScaleUtility.scaledValue(120) : ScaleUtility.scaledValue(70),
                           height: isIPad ? ScaleUtility.scaledValue(120) : ScaleUtility.scaledValue(70))
                    .cornerRadius(12)
                    .clipped()
                    .onTapGesture {
                        impactfeedback.impactOccurred()
                        showSheet.toggle()
                    }
            } else {
                Color.gray
                    .frame(width: isIPad ? ScaleUtility.scaledValue(120) : ScaleUtility.scaledValue(70),
                           height: isIPad ? ScaleUtility.scaledValue(120) : ScaleUtility.scaledValue(70))
                    .cornerRadius(12)
            }

            Text("+\(extraCount)")
                .foregroundColor(.white)
                .font(FontManager.instrumentSansBoldFont(size: .scaledFontSize(18)))
        }
    }
    
    // MARK: - Helper Functions
    
    private func handleImageTap(url: URL) {
        if url.pathExtension.lowercased() == "pdf" {
            impactfeedback.impactOccurred()
            selectedPDFFile = url
            AnalyticsManager.shared.log(.pdfPreviewOpen)
            withAnimation {
                navigateToPDFPreview = true
            }
        } else {
            if let index = convertedFilesURLs.firstIndex(of: url) {
                selectedIndex = index
                withAnimation {
                    impactfeedback.impactOccurred()
                    navToPreviewScreen = true
                    AnalyticsManager.shared.log(.previewScreenOpen)
                }
            }
        }
    }
    
    func presentSaveToFilesSheet() {
        let items = convertedFilesURLs
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityVC.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact,
            .postToFacebook,
            .postToTwitter,
            .message,
            .mail,
            .copyToPasteboard,
            .markupAsPDF,
            .openInIBooks,
            .print,
            .saveToCameraRoll
        ]
        UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true)
    }

    func renderImage(from url: URL) -> UIImage? {
        let ext = url.pathExtension.lowercased()
        if ext == "pdf" {
            guard let pdfDocument = PDFDocument(url: url),
                  let pdfPage = pdfDocument.page(at: 0) else { return nil }

            let pageRect = pdfPage.bounds(for: .mediaBox)
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: 70, height: 70))
            return renderer.image { ctx in
                UIColor.white.set()
                ctx.fill(CGRect(origin: .zero, size: CGSize(width: 70, height: 70)))

                let scale = min(70 / pageRect.width, 70 / pageRect.height)
                let scaledRect = CGRect(
                    x: (70 - pageRect.width * scale) / 2,
                    y: (70 - pageRect.height * scale) / 2,
                    width: pageRect.width * scale,
                    height: pageRect.height * scale
                )

                ctx.cgContext.saveGState()
                ctx.cgContext.translateBy(x: 0, y: 70)
                ctx.cgContext.scaleBy(x: 2.0, y: -1.0)
                ctx.cgContext.concatenate(CGAffineTransform(scaleX: scale, y: scale))

                pdfPage.draw(with: .mediaBox, to: ctx.cgContext)
                ctx.cgContext.restoreGState()
            }
        } else {
            return UIImage(contentsOfFile: url.path)
        }
    }

    func renderFirstPageOfPDF(url: URL, size: CGSize = CGSize(width: 70, height: 70)) -> UIImage? {
        guard let pdfDocument = PDFDocument(url: url),
              let pdfPage = pdfDocument.page(at: 0) else { return nil }

        let pageRect = pdfPage.bounds(for: .mediaBox)
        let rendererFormat = UIGraphicsImageRendererFormat.default()
        rendererFormat.scale = UIScreen.main.scale

        let renderer = UIGraphicsImageRenderer(size: size, format: rendererFormat)
        let img = renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(CGRect(origin: .zero, size: size))

            let scale = max(size.width / pageRect.width, size.height / pageRect.height)

            let scaledRect = CGRect(
                x: (size.width - pageRect.width * scale) / 2,
                y: (size.height - pageRect.height * scale) / 2,
                width: pageRect.width * scale,
                height: pageRect.height * scale
            )

            ctx.cgContext.saveGState()
            ctx.cgContext.translateBy(x: 0, y: size.height)
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
            ctx.cgContext.concatenate(CGAffineTransform(scaleX: scale, y: scale))

            pdfPage.draw(with: .mediaBox, to: ctx.cgContext)
            ctx.cgContext.restoreGState()
        }

        return img
    }
    
    func deleteFileAndRemoveFromCoreData(_ url: URL) {
        try? FileManager.default.removeItem(at: url)
        CoreDataManager.shared.deleteCompressedFile(for: url)
        if let index = convertedFilesURLs.firstIndex(of: url) {
            convertedFilesURLs.remove(at: index)
        }
    }
    
    func share(_ url: URL) {
        let av = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true)
    }
    
    func getCompressedFile(for url: URL) -> CompressedFile? {
        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<CompressedFile> = CompressedFile.fetchRequest()
        let fileName = url.lastPathComponent
        request.predicate = NSPredicate(format: "fileName == %@", fileName)

        do {
            let result = try context.fetch(request)
            if result.isEmpty {
                print("No file found in Core Data for URL: \(url)")
                return nil
            }
            return result.first
        } catch {
            print("Failed to fetch compressed file: \(error)")
            return nil
        }
    }
    
    private func saveAllToPhotos() {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            
            if status == .denied || status == .restricted {
                DispatchQueue.main.async {
                    showPermissionDeniedAlert = true   // 👈 show alert
                }
                return
            }
            
            guard status == .authorized else {
                DispatchQueue.main.async {
                    saveStatusMessage = "Permission denied."
                }
                return
            }

            // --- your existing save code ---
            PHPhotoLibrary.shared().performChanges({
                for url in convertedFilesURLs {
                    guard let fileData = try? Data(contentsOf: url) else { continue }

                    let creationRequest = PHAssetCreationRequest.forAsset()
                    let options = PHAssetResourceCreationOptions()
                    options.originalFilename = url.lastPathComponent
                    creationRequest.addResource(with: .photo, data: fileData, options: options)
                }
            }) { success, error in
                DispatchQueue.main.async {
                    if success {
                        showsavedfromlibrarypopup = true
                    } else {
                        saveStatusMessage = "Failed to save images."
                    }
                }
            }
        }
    }

}
