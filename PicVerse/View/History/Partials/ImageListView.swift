import SwiftUI
import PDFKit

// MARK: - Main View

struct ImageListView: View {
    
    // MARK: - Properties
    
    let notificationfeedback = UINotificationFeedbackGenerator()
    let impactfeedback = UIImpactFeedbackGenerator(style: .medium)
    let selectionfeedback = UISelectionFeedbackGenerator()
    
    @State private var fileToShare: URL?
    @State private var showShareSheet: Bool = false
    @State private var fileToDelete: CompressedFile?
    @State private var showDeleteConfirmation: Bool = false
    @State private var longPressedFileID: UUID?
    @State private var selectedPopupIndex: Int? = nil
    @State private var fileToShowPopup: CompressedFile? = nil
    
    // Bindings
    @Binding var fileMode: FileViewMode
    @Binding var selectedFiles: Set<UUID>
    @Binding var showOverlay: Bool
    @Binding var allFileUUIDs: [UUID]
    @ObservedObject var viewModel: ImageListViewModel
    var onPreviewTap: (Int) -> Void
    @Binding var imageURLs: [URL]
    @Binding var showPreviewScreen: Bool
    @Binding var selectedImageURLs: [URL]
    @Binding var outputFormatScreen: Bool
    @Binding var showFilePopup: Bool
    @Binding var navigateToPDFPreview: Bool
    @Binding var selectedPDFURL: URL?
    @Binding var searchText: String
    
    // MARK: - Body
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            if viewModel.filteredFiles.isEmpty && searchText.isEmpty {
                emptyStateView()
                    .onAppear {
                        showFilePopup = false
                    }
            } else {
                LazyVStack(spacing: ScaleUtility.scaledSpacing(12)) {
                    ForEach(Array(viewModel.filteredFiles.enumerated()), id: \.element.id) { index, file in
                        FileRowWrapper(
                            file: file,
                            index: index,
                            delay: Double(index) * 0.10,
                            fileMode: $fileMode,
                            selectedFiles: $selectedFiles,
                            showOverlay: $showOverlay,
                            viewModel: viewModel,
                            onPreviewTap: onPreviewTap,
                            imageURLs: $imageURLs,
                            showPreviewScreen: $showPreviewScreen,
                            selectedImageURLs: $selectedImageURLs,
                            outputFormatScreen: $outputFormatScreen,
                            showFilePopup: $showFilePopup,
                            navigateToPDFPreview: $navigateToPDFPreview,
                            selectedPDFURL: $selectedPDFURL,
                            selectedPopupIndex: $selectedPopupIndex,
                            fileToShare: $fileToShare,
                            showShareSheet: $showShareSheet,
                            fileToDelete: $fileToDelete,
                            showDeleteConfirmation: $showDeleteConfirmation,
                            notificationfeedback: notificationfeedback,
                            impactfeedback: impactfeedback,
                            getFileURL: getFileURL,
                            renderImage: renderImage,
                            deleteFileAndRemoveFromCoreData: deleteFileAndRemoveFromCoreData
                        )
                    }
                }
                .padding(.horizontal, ScaleUtility.scaledSpacing(16))
               
            }
            
            Spacer()
                .frame(height: ScaleUtility.scaledValue(100))
        }
        .onAppear {
            viewModel.fetch(for: fileMode)
            updateUUIDs()
        }
        .onChange(of: fileMode) { newValue in
            viewModel.fetch(for: newValue)
            updateUUIDs()
        }
        .onChange(of: viewModel.filteredFiles) { _ in
            longPressedFileID = nil
            showFilePopup = false
        }
    }
    
    @ViewBuilder
    func emptyStateView() -> some View {
        VStack {
            Image("emptyimage")
                .resizable()
                .scaledToFit()
                .frame(
                    width: isIPad ? ScaleUtility.scaledValue(228) : ScaleUtility.scaledValue(128),
                    height: isIPad ? ScaleUtility.scaledValue(220) : ScaleUtility.scaledValue(120)
                )
        }
        .padding(.top, ScaleUtility.scaledValue(170))
    }
    
    // MARK: - Helper Methods
    
    private func formattedFileSize(for file: CompressedFile) -> String {
        guard let url = getFileURL(for: file),
              let fileSize = try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int else {
            return "0 KB"
        }
        
        let sizeInKB = Double(fileSize) / 1024.0
        if sizeInKB >= 1024 {
            let sizeInMB = sizeInKB / 1024.0
            return String(format: "%.2f MB", sizeInMB)
        } else {
            return String(format: "%.0f KB", sizeInKB)
        }
    }
    
    private func formattedDateTime(_ date: Date?) -> String {
        guard let date = date else { return "Unknown date" }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy 'at' h:mm a"
        return formatter.string(from: date)
    }
    
    private func deleteFileAndRemoveFromCoreData(_ url: URL) {
        print("🗑️ Attempting to delete file at: \(url.path)")
        print("📄 File name: \(url.lastPathComponent)")
        
        // Check if file exists before deletion
        if FileManager.default.fileExists(atPath: url.path) {
            print("✅ File exists, proceeding with deletion")
            try? FileManager.default.removeItem(at: url)
        } else {
            print("⚠️ File does not exist at path")
        }
        
        CoreDataManager.shared.deleteCompressedFile(for: url)
        viewModel.fetch(for: fileMode)
        
        if let index = imageURLs.firstIndex(of: url) {
            imageURLs.remove(at: index)
            print("✅ Removed from imageURLs array")
        }
    }
    
    private func updateUUIDs() {
        DispatchQueue.main.async {
            self.allFileUUIDs = viewModel.files.compactMap { $0.id }
        }
    }
    
    private func getFileURL(for file: CompressedFile) -> URL? {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(file.filePath ?? "")
    }
    
    func renderImage(from url: URL) -> UIImage? {
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

// MARK: - File Row Wrapper (handles individual row state)

struct FileRowWrapper: View {
    let file: CompressedFile
    let index: Int
    let delay: Double
    
    @Binding var fileMode: FileViewMode
    @Binding var selectedFiles: Set<UUID>
    @Binding var showOverlay: Bool
    @ObservedObject var viewModel: ImageListViewModel
    var onPreviewTap: (Int) -> Void
    @Binding var imageURLs: [URL]
    @Binding var showPreviewScreen: Bool
    @Binding var selectedImageURLs: [URL]
    @Binding var outputFormatScreen: Bool
    @Binding var showFilePopup: Bool
    @Binding var navigateToPDFPreview: Bool
    @Binding var selectedPDFURL: URL?
    @Binding var selectedPopupIndex: Int?
    @Binding var fileToShare: URL?
    @Binding var showShareSheet: Bool
    @Binding var fileToDelete: CompressedFile?
    @Binding var showDeleteConfirmation: Bool
    
    let notificationfeedback: UINotificationFeedbackGenerator
    let impactfeedback: UIImpactFeedbackGenerator
    let getFileURL: (CompressedFile) -> URL?
    let renderImage: (URL) -> UIImage?
    let deleteFileAndRemoveFromCoreData: (URL) -> Void
    
    @State private var isVisible = false
    @State private var showLocalDeleteAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: ScaleUtility.scaledSpacing(12)) {
                // Thumbnail
                if let url = getFileURL(file) {
                    if let image = renderImage(url) {
                        RoundedRectangle(cornerRadius: 100)
                            .fill(Color.clear)
                            .frame(width: ScaleUtility.scaledValue(40), height: ScaleUtility.scaledValue(40))
                            .background {
                                CachedAsyncImageView(url: url, size: CGSize(width: 40, height: 40))
                            }
                            .cornerRadius(100)
                        
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .frame(width: ScaleUtility.scaledValue(40), height: ScaleUtility.scaledValue(40))
                            .clipShape(Circle())
                    }
                }
                
                // File Info
                VStack(alignment: .leading, spacing: ScaleUtility.scaledSpacing(8)) {
                    Text(file.fileName ?? "Unknown")
                        .font(FontManager.instrumentSansSemiBoldFont(size: .scaledFontSize(16)))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text("\(ByteFormat.friendly(bytes: file.size)) | \(DateFormat.friendly(file.createdAt))")
                        .font(FontManager.instrumentSansMediumFont(size: .scaledFontSize(14)))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .opacity(0.6)
                        .minimumScaleFactor(0.2)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Checkbox
                if let fileID = file.id {
                    let url = getFileURL(file)
                    let isPDF = url?.pathExtension.lowercased() == "pdf"
                    
                    Checkbox(
                        selectedFiles: $selectedFiles,
                        showOverlay: $showOverlay,
                        fileID: fileID,
                        isPDF: isPDF
                    )
                    .environmentObject(viewModel)
                }
            }
            .padding(.all, ScaleUtility.scaledSpacing(15))
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.appSoftGrey.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .offset(x: isVisible ? 0 : UIScreen.main.bounds.width)
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                isVisible = true
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            handleTap()
        }
        .gesture(
            LongPressGesture()
                .onEnded { _ in
                    handleLongPress()
                }
        )
        .popoverView(
            isPresented: Binding(
                get: { showFilePopup && selectedPopupIndex == index },
                set: { newValue in
                    if !newValue {
                        showFilePopup = false
                        selectedPopupIndex = nil
                    }
                }
            ),
            popOverTopPadding: 0,
            popOverSize: CGSize(
                width: isIPad ? ScaleUtility.scaledValue(197) : ScaleUtility.scaledValue(167),
                height: isIPad ? ScaleUtility.scaledValue(208) : ScaleUtility.scaledValue(178)
            )
        ) {
            popupContent()
        }
        .alert("Delete", isPresented: $showLocalDeleteAlert) {
            Button("Cancel", role: .cancel) {
                print("❌ Cancel tapped")
            }
            Button("Delete", role: .destructive) {
                print("✅ Delete confirmed")
                notificationfeedback.notificationOccurred(.success)
                if let url = getFileURL(file) {
                    deleteFileAndRemoveFromCoreData(url)
                    AnalyticsManager.shared.log(.delete)
                }
            }
        } message: {
            Text("Are you sure you want to delete the selected file(s) from the app?")
        }
        .sheet(item: $fileToShare) { url in
            ShareSheet(activityItems: [url])
        }
    }
    
    @ViewBuilder
    private func popupContent() -> some View {
        LongPressedPopUp(
            onShare: {
                impactfeedback.impactOccurred()
                showFilePopup = false
                selectedPopupIndex = nil
                
                if let url = getFileURL(file) {
                    fileToShare = url
                    showShareSheet = true
                    AnalyticsManager.shared.log(.share)
                }
            },
            onOpen: {
                impactfeedback.impactOccurred()
                showFilePopup = false
                selectedPopupIndex = nil
                
                if let url = getFileURL(file) {
                    if url.pathExtension.lowercased() == "pdf" {
                        AnalyticsManager.shared.log(.pdfPreviewOpen)
                        imageURLs.append(url)
                        withAnimation {
                            navigateToPDFPreview = true
                        }
                    } else {
                        imageURLs = viewModel.filteredFiles.compactMap { getFileURL($0) }
                        onPreviewTap(index)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            withAnimation {
                                showPreviewScreen = true
                            }
                            AnalyticsManager.shared.log(.previewScreenOpen)
                        }
                    }
                }
            },
            onConvert: {
                impactfeedback.impactOccurred()
                showFilePopup = false
                selectedPopupIndex = nil
                
                if let url = getFileURL(file) {
                    selectedImageURLs.append(url)
                    outputFormatScreen = true
                    AnalyticsManager.shared.log(.convert)
                }
            },
            onDelete: {
                handleDelete()
            }
        )
    }
    
    // MARK: - Actions
    
    private func handleTap() {
        impactfeedback.impactOccurred()
        if let url = getFileURL(file) {
            if url.pathExtension.lowercased() == "pdf" {
                withAnimation {
                    selectedPDFURL = url
                    navigateToPDFPreview = true
                }
                imageURLs = [url]
                AnalyticsManager.shared.log(.pdfPreviewOpen)
            } else {
                imageURLs = viewModel.filteredFiles.compactMap { getFileURL($0) }
                onPreviewTap(index)
                AnalyticsManager.shared.log(.previewScreenOpen)
            }
        }
    }
    
    private func handleLongPress() {
        impactfeedback.impactOccurred()
        selectedPopupIndex = index
        showFilePopup = true
    }
    
    private func handleDelete() {
        print("🔴 handleDelete called for file: \(file.fileName ?? "unknown")")
        notificationfeedback.notificationOccurred(.warning)
        showFilePopup = false
        selectedPopupIndex = nil
        
        print("📱 isIPad: \(isIPad)")
        
        if isIPad {
            print("✅ iPad - Deleting immediately")
            notificationfeedback.notificationOccurred(.success)
            if let url = getFileURL(file) {
                deleteFileAndRemoveFromCoreData(url)
                AnalyticsManager.shared.log(.delete)
            }
        } else {
            print("📱 iPhone - Showing alert")
            showLocalDeleteAlert = true
        }
        
        AnalyticsManager.shared.log(.delete)
    }
}

// MARK: - Checkbox Component

struct Checkbox: View {
    @Binding var selectedFiles: Set<UUID>
    @Binding var showOverlay: Bool
    var fileID: UUID
    var isPDF: Bool
    
    @EnvironmentObject var viewModel: ImageListViewModel
    
    let notificationfeedback = UINotificationFeedbackGenerator()
    let impactfeedback = UIImpactFeedbackGenerator(style: .medium)
    let selectionfeedback = UISelectionFeedbackGenerator()
    
    var body: some View {
        let isChecked = selectedFiles.contains(fileID)
        Image(systemName: isChecked ? "checkmark.circle.fill" : "circle.fill")
            .resizable()
            .frame(
                width: isIPad ? ScaleUtility.scaledValue(20) : ScaleUtility.scaledValue(15),
                height: isIPad ? ScaleUtility.scaledValue(20) : ScaleUtility.scaledValue(15)
            )
            .foregroundColor(isChecked ? Color.white : .white.opacity(0.35))
            .onTapGesture {
                selectionfeedback.selectionChanged()
                handleSelection()
            }
    }
    
    private func handleSelection() {
        let selectedTypes: Set<Bool> = Set(selectedFiles.compactMap { id in
            viewModel.files.first(where: { $0.id == id }).flatMap {
                let url = FileManager.default
                    .urls(for: .documentDirectory, in: .userDomainMask)
                    .first?
                    .appendingPathComponent($0.filePath ?? "")
                return url?.pathExtension.lowercased() == "pdf"
            }
        })
        
        let isCurrentlyChecked = selectedFiles.contains(fileID)
        
        if isCurrentlyChecked {
            selectedFiles.remove(fileID)
            withAnimation {
                showOverlay = !selectedFiles.isEmpty
            }
            return
        }
        
        if selectedTypes.isEmpty || (selectedTypes.count == 1 && selectedTypes.contains(isPDF)) {
            selectedFiles.insert(fileID)
            withAnimation {
                showOverlay = true
            }
        }
    }
}

// MARK: - Extensions

extension URL: Identifiable {
    public var id: String { absoluteString }
}
