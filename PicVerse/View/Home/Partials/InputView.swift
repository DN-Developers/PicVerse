//
//  InputView.swift
//  PicVerse
//
//  Refactored for better structure and maintainability
//

import SwiftUI
import SDWebImage
import PDFKit
import SDWebImageWebPCoder


// MARK: - Main View
struct InputView: View {
    @Binding var imageURLs: [URL]
    var onBack: () -> Void
    var onClose: () -> Void  // ✅ Add this
    var onBackAction: (() -> Void)?
    @Binding var outputFormatScreen: Bool
    
    @StateObject private var viewModel = InputViewViewModel()
    
    @EnvironmentObject var userDefaultSetting: UserSettings
    @EnvironmentObject var purchaseManager: PurchaseManager
    @EnvironmentObject var remoteConfigManager: RemoteConfigManager
    
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
            
            VStack(spacing: ScaleUtility.scaledSpacing(16)) {
                VStack(spacing: ScaleUtility.scaledSpacing(26)) {
                    headerSection
                    imagePreviewSection
                }
                formatSelectionSection
                Spacer()
                convertButton
                    .padding(.bottom, ScaleUtility.scaledSpacing(35))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationBarHidden(true)
            .setupNavigationDestinations(
                 viewModel: viewModel,
                 imageURLs: $imageURLs,
                 outputFormatScreen: $outputFormatScreen,
                 onClose: onClose  // ✅ Pass onClose here
             )
            .setupSheets(viewModel: viewModel, imageURLs: imageURLs)
            .fullScreenCover(isPresented: $viewModel.isPaywallOn) {
                PaywallView(
                    dismissAction: { viewModel.isPaywallOn = false },
                    isInternalOpen: true,
                    purchaseCompletSuccessfullyAction: { viewModel.isPaywallOn = false }
                )
            }
        }
        .onChange(of: imageURLs.count) {
            if imageURLs.isEmpty {
                onBack()
            }
        }

    }
}

// MARK: - View Sections
private extension InputView {
    var headerSection: some View {
        ZStack {
            HStack {
                BackButton { onBack() }
                    .offset(x: ScaleUtility.scaledSpacing(-3))
                
                Spacer()
                
                ProButton(isPro: purchaseManager.hasPro) {
                    viewModel.isPaywallOn.toggle()
                }
                .offset(x: ScaleUtility.scaledSpacing(2))
            }
            .padding(.horizontal, isIPad ? ScaleUtility.scaledSpacing(40) : ScaleUtility.scaledSpacing(20))
            
            Text("\(imageURLs.count) Selected")
                .font(FontManager.instrumentSansSemiBoldFont(size: .scaledFontSize(21)))
                .foregroundColor(.white)
            
        }
        .padding(.top, isIPad ? ScaleUtility.scaledSpacing(29) : ScaleUtility.scaledSpacing(19))
    }
    
    @ViewBuilder
    var imagePreviewSection: some View {
        if imageURLs.count == 1 {
            HStack {
                Spacer()
                ImageCell(
                    url: imageURLs[0],
                    isSingle: true,
                    onRemove: { viewModel.removeImage($0, from: $imageURLs) },
                    onTap: { viewModel.openPreview(at: $0, in: imageURLs) }
                )
                Spacer()
            }
        } else {
            ImageGrid(
                imageURLs: imageURLs,
                onRemove: { viewModel.removeImage($0, from: $imageURLs) },
                onTap: { viewModel.openPreview(at: $0, in: imageURLs) },
                onShowMore: { viewModel.showSheet = true }
            )
            .frame(maxWidth: .infinity, alignment: isIPad ? .center : .leading)
            .padding(.horizontal, ScaleUtility.scaledSpacing(20.05))
        }
    }
    
    var formatSelectionSection: some View {
        VStack(alignment: .leading, spacing: ScaleUtility.scaledSpacing(18)) {
            Text("Select Output Format :")
                .font(FontManager.instrumentSansMediumFont(size: .scaledFontSize(18)))
                .kerning(0.5)
                .foregroundColor(.white)
            
            FormatGrid(
                selectedFormat: $viewModel.selectedFormat,
                onPDFTap: { viewModel.showPDFPopup = true },
                onFormatSelect: { format in
                    viewModel.selectFormat(format)
                }
            )
            .padding(.trailing, isIPad ? ScaleUtility.scaledSpacing(130) : ScaleUtility.scaledSpacing(21))
        }
        .padding(.leading, isIPad ? ScaleUtility.scaledSpacing(130) : ScaleUtility.scaledSpacing(20))
        .padding(.top, ScaleUtility.scaledSpacing(17.49))
        .overlay {
            if viewModel.showPDFPopup {
                PDFPopupOverlay(
                    selectedOption: $viewModel.selectedPDFOption,
                    onCancel: { viewModel.cancelPDFSelection() },
                    onConvert: {
                        viewModel.handlePDFConversion(
                            imageURLs: imageURLs,
                            hasPro: purchaseManager.hasPro,
                            conversionCount: userDefaultSetting.convertionCount,
                            freeConversionLimit: remoteConfigManager.freeConvertion,
                            onIncrement: { userDefaultSetting.convertionCount += 1 }
                        )
                    }
                )
            }
        }
    }
    
    var convertButton: some View {
        ConvertButton(
            isEnabled: !viewModel.selectedFormat.isEmpty,
            showPulse: $viewModel.showConvertPulse
        ) {
            viewModel.handleConvert(
                imageURLs: imageURLs,
                hasPro: purchaseManager.hasPro,
                conversionCount: userDefaultSetting.convertionCount,
                freeConversionLimit: remoteConfigManager.freeConvertion,
                onIncrement: { userDefaultSetting.convertionCount += 1 }
            )
        }
        .padding(.horizontal, ScaleUtility.scaledSpacing(20))
    }
}

// MARK: - View Model
@MainActor
class InputViewViewModel: ObservableObject {
    @Published var selectedFormat = ""
    @Published var navigateToConvertingScreen = false
    @Published var showSheet = false
    @Published var navToPreviewScreen = false
    @Published var selectedIndex = 0
    @Published var showConvertPulse = false
    @Published var isPaywallOn = false
    @Published var navigateToPDFPreview = false
    @Published var selectedPDFFile: URL?
    @Published var showPDFPopup = false
    @Published var selectedPDFOption: PDFConversionOption?
    
    private let notificationFeedback = UINotificationFeedbackGenerator()
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    
    func removeImage(_ url: URL, from imageURLs: Binding<[URL]>) {
        let heavyFeedback = UIImpactFeedbackGenerator(style: .heavy)
        heavyFeedback.impactOccurred()
        
        if let index = imageURLs.wrappedValue.firstIndex(of: url) {
            imageURLs.wrappedValue.remove(at: index)
        }
    }
    
    func openPreview(at index: Int, in imageURLs: [URL]) {
        impactFeedback.impactOccurred()
        selectedIndex = index
        navToPreviewScreen = true
        AnalyticsManager.shared.log(.previewScreenOpen)
    }
    
    func selectFormat(_ format: String) {
        selectionFeedback.selectionChanged()
        selectedFormat = format
        showConvertPulse = true
    }
    
    func cancelPDFSelection() {
        selectedFormat = ""
        showPDFPopup = false
    }
    
    func handlePDFConversion(
        imageURLs: [URL],
        hasPro: Bool,
        conversionCount: Int,
        freeConversionLimit: Int,
        onIncrement: () -> Void
    ) {
        if !hasPro && conversionCount >= freeConversionLimit {
            isPaywallOn = true
        } else {
            AnalyticsManager.shared.log(.PDF)
            onIncrement()
            selectedFormat = "PDF"
            saveCompressedFiles(imageURLs)
            navigateToConvertingScreen = true
            showPDFPopup = false
        }
    }
    
    func handleConvert(
        imageURLs: [URL],
        hasPro: Bool,
        conversionCount: Int,
        freeConversionLimit: Int,
        onIncrement: () -> Void
    ) {
        if !hasPro && conversionCount >= freeConversionLimit {
            isPaywallOn = true
        } else if !selectedFormat.isEmpty {
            onIncrement()
            saveCompressedFiles(imageURLs)
            navigateToConvertingScreen = true
            notificationFeedback.notificationOccurred(.success)
            AnalyticsManager.shared.log(.format(selectedFormat))
        }
    }
    
    private func saveCompressedFiles(_ urls: [URL]) {
        urls.forEach { url in
            CoreDataManager.shared.saveCompressedFile(from: url, source: "Input Files")
        }
    }
}

// MARK: - Subviews
struct BackButton: View {
    let action: () -> Void
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        Image("backIcon")
            .resizable(size: CGSize(
                width: isIPad ? ScaleUtility.scaledValue(34) : ScaleUtility.scaledValue(24),
                height: isIPad ? ScaleUtility.scaledValue(34) : ScaleUtility.scaledValue(24)
            ))
            .onTapGesture {
                impactFeedback.impactOccurred()
                action()
            }
    }
}

struct ProButton: View {
    let isPro: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(.crownIcon)
                .resizable(size: CGSize(
                    width: isIPad ? ScaleUtility.scaledValue(34) : ScaleUtility.scaledValue(24),
                    height: isIPad ? ScaleUtility.scaledValue(34) : ScaleUtility.scaledValue(24)
                ))
                .opacity(isPro ? 0 : 1)
        }
    }
}

struct ImageCell: View {
    let url: URL
    var isSingle: Bool = false
    let onRemove: (URL) -> Void
    let onTap: (Int) -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            imageContent
            removeButton
        }
        .onTapGesture {
            onTap(0) // For single image, index is always 0
        }
    }
    
    @ViewBuilder
    private var imageContent: some View {
        if let image = ImageRenderer.render(from: url) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(
                    width: cellSize.width,
                    height: cellSize.height
                )
                .cornerRadius(12)
                .clipped()
                .contentShape(RoundedRectangle(cornerRadius: 12))
        } else {
            Color.gray
                .frame(width: cellSize.width, height: cellSize.height)
                .cornerRadius(12)
        }
    }
    
    private var removeButton: some View {
        Button(action: { onRemove(url) }) {
            Image(systemName: "minus.circle.fill")
                .resizable()
                .frame(
                    width: isIPad ? ScaleUtility.scaledValue(30) : ScaleUtility.scaledValue(20),
                    height: isIPad ? ScaleUtility.scaledValue(30) : ScaleUtility.scaledValue(20)
                )
                .foregroundColor(.white)
                .padding(5)
        }
        .offset(x: ScaleUtility.scaledSpacing(15), y: ScaleUtility.scaledSpacing(-16))
    }
    
    private var cellSize: CGSize {
        let size = isSingle
            ? (isIPad ? ScaleUtility.scaledValue(179) : ScaleUtility.scaledValue(159))
            : (isIPad ? ScaleUtility.scaledValue(90) : ScaleUtility.scaledValue(70))
        return CGSize(width: size, height: size)
    }
}

struct ImageGrid: View {
    let imageURLs: [URL]
    let onRemove: (URL) -> Void
    let onTap: (Int) -> Void
    let onShowMore: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: ScaleUtility.scaledSpacing(18)) {
            HStack(spacing: ScaleUtility.scaledSpacing(18)) {
                ForEach(Array(imageURLs.prefix(4).enumerated()), id: \.element) { index, url in
                    ImageCell(url: url, onRemove: onRemove, onTap: onTap)
                }
            }
            
            HStack(spacing: ScaleUtility.scaledSpacing(18)) {
                ForEach(Array(imageURLs.dropFirst(4).prefix(2).enumerated()), id: \.element) { index, url in
                    ImageCell(url: url, onRemove: onRemove, onTap: onTap)
                }
                
                if imageURLs.count > 6, let seventhImage = imageURLs[safe: 6] {
                    OverlayImageCell(
                        url: seventhImage,
                        extraCount: imageURLs.count - 6
                    )
                    .onTapGesture(perform: onShowMore)
                }
            }
        }
       
    }
}

struct OverlayImageCell: View {
    let url: URL
    let extraCount: Int
    
    var body: some View {
        ZStack {
            if let image = ImageRenderer.render(from: url) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: cellSize, height: cellSize)
                    .cornerRadius(12)
                    .clipped()
            } else {
                Color.gray
                    .frame(width: cellSize, height: cellSize)
                    .cornerRadius(12)
            }
            
            ZStack {
                Color.black.opacity(0.4)
                Text("+ \(extraCount)")
                    .foregroundColor(.white)
                    .font(FontManager.instrumentSansBoldFont(size: .scaledFontSize(18)))
            }
            .frame(width: cellSize, height: cellSize)
            .cornerRadius(12)
        }
    }
    
    private var cellSize: CGFloat {
        isIPad ? ScaleUtility.scaledValue(80) : ScaleUtility.scaledValue(70)
    }
}

struct FormatGrid: View {
    @Binding var selectedFormat: String
    let onPDFTap: () -> Void
    let onFormatSelect: (String) -> Void

    private let formats = ["JPG", "JPEG", "PNG", "PDF", "GIF", "TIFF", "WEBP", "BMP", "HEIC"]

    // Create rows of 3
    private var rows: [[String]] {
        stride(from: 0, to: formats.count, by: 3).map {
            Array(formats[$0..<min($0+3, formats.count)])
        }
    }

    var body: some View {
        VStack(spacing: ScaleUtility.scaledSpacing(15)) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: ScaleUtility.scaledSpacing(10)) {  // spacing between 3 cells
                    ForEach(row, id: \.self) { format in
                        FormatCell(
                            format: format,
                            isSelected: selectedFormat == format,
                            onTap: {
                                if format == "PDF" {
                                    let feedback = UINotificationFeedbackGenerator()
                                    feedback.notificationOccurred(.warning)
                                    onPDFTap()
                                } else {
                                    onFormatSelect(format)
                                }
                            }
                        )
                        .frame(maxWidth: .infinity) // ← 3 equal-width columns
                    }
                }
            }
        }
    }
}


struct FormatCell: View {
    let format: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottom) {
                Image("\(format.lowercased())Icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: isIPad ? ScaleUtility.scaledValue(80) : ScaleUtility.scaledValue(70),
                           height:  isIPad ? ScaleUtility.scaledValue(80) : ScaleUtility.scaledValue(70))
                    .offset(y: isIPad ? ScaleUtility.scaledSpacing(-20) : ScaleUtility.scaledSpacing(-10))
                
                Text(format)
                    .font(FontManager.instrumentSansMediumFont(size: .scaledFontSize(14)))
                    .foregroundColor(.white)
                    .frame(width: isIPad ? ScaleUtility.scaledValue(65) : ScaleUtility.scaledValue(45))

            }
            .padding(.all, isIPad ? ScaleUtility.scaledSpacing(30) : ScaleUtility.scaledSpacing(15))
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.appGrey)
            )
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.secondaryApp,lineWidth: 1)
                }
            }
         
       
        }
        .buttonStyle(.plain)
    }
}


struct PDFPopupOverlay: View {
    @Binding var selectedOption: PDFConversionOption?
    let onCancel: () -> Void
    let onConvert: () -> Void
    
    var body: some View {

            
            PdfAlertView(
                selectedOption: $selectedOption,
                onCancel: onCancel,
                onConvert: onConvert
            )
        

    }
}

struct ConvertButton: View {
    let isEnabled: Bool
    @Binding var showPulse: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Image(.buttonBg)
                    .resizable()
                    .frame(height: isIPad ? ScaleUtility.scaledValue(62) : ScaleUtility.scaledValue(52))
                    .frame(maxWidth: .infinity)
              
                Text("Convert")
                    .font(FontManager.instrumentSansMediumFont(size: .scaledFontSize(16)))
                    .foregroundColor(.white.opacity(isEnabled ? 1 : 0.6))
            }
            .padding(.horizontal, ScaleUtility.scaledSpacing(20))
        }
        .disabled(!isEnabled)
        .onAppear {
            if isEnabled {
                showPulse = true
            }
        }
    }
    
    @ViewBuilder
    private var pulseEffect: some View {
        RoundedRectangle(cornerRadius: 14)
            .stroke(Color.white.opacity(0.06), lineWidth: 0.5)
            .blur(radius: 6)
            .opacity(showPulse ? 1 : 0)
            .scaleEffect(showPulse ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: showPulse)
    }
}

// MARK: - Utilities
enum ImageRenderer {
    static func render(from url: URL) -> UIImage? {
        let ext = url.pathExtension.lowercased()
        if ext == "pdf" {
            return renderFirstPageOfPDF(url: url)
        } else {
            return UIImage(contentsOfFile: url.path)
        }
    }
    
    static func renderFirstPageOfPDF(url: URL, size: CGSize = CGSize(width: 70, height: 70)) -> UIImage? {
        guard let pdfDocument = PDFDocument(url: url),
              let pdfPage = pdfDocument.page(at: 0) else { return nil }
        
        let pageRect = pdfPage.bounds(for: .mediaBox)
        let rendererFormat = UIGraphicsImageRendererFormat.default()
        rendererFormat.scale = UIScreen.main.scale
        
        let renderer = UIGraphicsImageRenderer(size: size, format: rendererFormat)
        return renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(CGRect(origin: .zero, size: size))
            
            let scale = min(size.width / pageRect.width, size.height / pageRect.height)
            
            ctx.cgContext.saveGState()
            ctx.cgContext.translateBy(x: 0, y: size.height)
            ctx.cgContext.scaleBy(x: 2.2, y: -1.0)
            ctx.cgContext.concatenate(CGAffineTransform(scaleX: scale, y: scale))
            
            pdfPage.draw(with: .mediaBox, to: ctx.cgContext)
            ctx.cgContext.restoreGState()
        }
    }
}

// MARK: - View Modifiers
struct NavigationDestinationsModifier: ViewModifier {
    @ObservedObject var viewModel: InputViewViewModel
    @Binding var imageURLs: [URL]
    @Binding var outputFormatScreen: Bool
    var onClose: () -> Void  // ✅ Add this
    
    func body(content: Content) -> some View {
        content
            .navigationDestination(isPresented: $viewModel.navigateToConvertingScreen) {
                ConvertingScreen(
                    imageURLs: $imageURLs,
                    selectedFormat: viewModel.selectedFormat,
                    totalImages: imageURLs.count,
                    onback: {
                        viewModel.navigateToConvertingScreen = false
                    },
                    onClose: {
                        print("🔙 ConvertingScreen onClose called")
                        viewModel.navigateToConvertingScreen = false
                        onClose()  // ✅ Call the parent's onClose
                    },
                    outputFormatScreen: $outputFormatScreen,
                    pdfOption: viewModel.selectedPDFOption
                )
                .background(Color.primaryApp.ignoresSafeArea(.all))
            }
            .navigationDestination(isPresented: $viewModel.navToPreviewScreen) {
                PreviewScreen(
                    imageURLs: $imageURLs,
                    initialIndex: viewModel.selectedIndex,
                    onBack: {
                        viewModel.navToPreviewScreen = false
                        viewModel.selectedIndex = 0
                    },
                    onDelete: { _ in },
                    onShare: { _ in },
                    isappear: false,
                    onConvert: { _ in }
                )
                .transition(.asymmetric(insertion: .scale, removal: .scale))
                .animation(.easeInOut(duration: 0.3), value: viewModel.navToPreviewScreen)
                .background(Color.primaryApp.ignoresSafeArea(.all))
            }
    }
}

struct SheetsModifier: ViewModifier {
    @ObservedObject var viewModel: InputViewViewModel
    let imageURLs: [URL]
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $viewModel.showSheet) {
                ImageGridSheet(
                    imageURLs: imageURLs,
                    onTapImage: { index in
                        let feedback = UIImpactFeedbackGenerator(style: .medium)
                        feedback.impactOccurred()
                        viewModel.selectedIndex = index
                        viewModel.navToPreviewScreen = true
                    },
                    navigateToPDFPreview: $viewModel.navigateToPDFPreview,
                    selectedPDFFile: $viewModel.selectedPDFFile,
                    onBack: { viewModel.showSheet = false }
                )
                .frame(height: isIPad ? 676.65668 : 576.65668)
                .presentationDragIndicator(.visible)
                .presentationDetents([.height(isIPad ? 676.65668 : 576.65668)])
            }
    }
}

extension View {
    func setupNavigationDestinations(
        viewModel: InputViewViewModel,
        imageURLs: Binding<[URL]>,
        outputFormatScreen: Binding<Bool>,
        onClose: @escaping () -> Void  // ✅ Add this
    ) -> some View {
        modifier(NavigationDestinationsModifier(
            viewModel: viewModel,
            imageURLs: imageURLs,
            outputFormatScreen: outputFormatScreen,
            onClose: onClose  // ✅ Pass it to modifier
        ))
    }
    
    func setupSheets(viewModel: InputViewViewModel, imageURLs: [URL]) -> some View {
        modifier(SheetsModifier(viewModel: viewModel, imageURLs: imageURLs))
    }
}

// MARK: - Extensions
extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
