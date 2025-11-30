//
//  MainView.swift
//  PicVerse
//
//  Created by Neel Kalariya on 21/09/25.
//  Refactored for better structure and maintainability
//

import Foundation
import SwiftUI

// MARK: - Models & Enums

enum TabSelection: Hashable {
    case home
    case history
    case setting
}



// MARK: - Main View

struct MainView: View {
    @StateObject private var historyViewModel = ImageListViewModel()
    @StateObject private var mainViewModel = MainViewState()
    
    // SOLUTION: Replace the alert section in MainView body with this combined alert

    var body: some View {
        NavigationStack {
            ZStack {
                if !mainViewModel.showPreviewScreen && !mainViewModel.navigateToPDFPreview {
                    mainContentSection
                }
                if mainViewModel.showPreviewScreen {
                    previewScreenSection
                }
                
                if mainViewModel.navigateToPDFPreview, let pdfURL = mainViewModel.selectedPDFURL {
                    pdfPreviewSection(pdfURL: pdfURL)
                }
                
                
            }
            // ✅ SINGLE COMBINED ALERT HANDLER
            .alert(isPresented: Binding<Bool>(
                get: {
                    mainViewModel.showPermissionAlert || mainViewModel.activeAlert != nil
                },
                set: { newValue in
                    if !newValue {
                        mainViewModel.showPermissionAlert = false
                        mainViewModel.activeAlert = nil
                    }
                }
            )) {
                // Check which alert to show
                if mainViewModel.showPermissionAlert {
                    return Alert(
                        title: Text("Photos Access Required"),
                        message: Text("Enable photo access in Settings to continue."),
                        primaryButton: .default(Text("Open Settings")) {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                            mainViewModel.showPermissionAlert = false
                        },
                        secondaryButton: .cancel {
                            mainViewModel.showPermissionAlert = false
                        }
                    )
                } else if let alertType = mainViewModel.activeAlert {
                    switch alertType {
                    case .delete:
                        return Alert(
                            title: Text("Delete"),
                            message: Text("Are you sure you want to delete the selected file(s) from the app?"),
                            primaryButton: .destructive(Text("Delete")) {
                                mainViewModel.performDeletion(historyViewModel: historyViewModel)
                                mainViewModel.activeAlert = nil
                            },
                            secondaryButton: .cancel {
                                mainViewModel.deleteTargetURL = nil
                                mainViewModel.deleteTargetUUIDs = []
                                mainViewModel.activeAlert = nil
                            }
                        )
                        
                    case .conversionLimitExceeded:
                        return Alert(
                            title: Text("Limit Reached!"),
                            message: Text("A maximum of 30 images can be converted at once."),
                            dismissButton: .default(Text("Got It")) {
                                mainViewModel.activeAlert = nil
                            }
                        )
                    }
                } else {
                    // Fallback (should never happen)
                    return Alert(title: Text("Error"))
                }
            }
            .navigationDestination(isPresented: $mainViewModel.showInputView) {
                InputView(
                    imageURLs: $mainViewModel.selectedImageURLs,
                    onBack: {
                        print("🔙 InputView onBack")
                        mainViewModel.selectedImageURLs.removeAll()
                        mainViewModel.showInputView = false
                    },
                    onClose: {
                        print("🔙 InputView onClose")
                        mainViewModel.selectedImageURLs.removeAll()
                        mainViewModel.showInputView = false
                    },
                    outputFormatScreen: $mainViewModel.showInputView
                )
                .background(Color.primaryApp.ignoresSafeArea(.all))
            }
            .background(Color.primaryApp.ignoresSafeArea(.all))
            .edgesIgnoringSafeArea(.bottom)
        }
    }


}

// MARK: - View Sections

private extension MainView {
    
    
    var previewScreenSection: some View {
        Group {
            if let index = mainViewModel.selectedPreviewIndex {
                PreviewScreen(
                    imageURLs: $mainViewModel.imageURLs,
                    initialIndex: index,
                    onBack: {
                        mainViewModel.showPreviewScreen = false
                    },
                    onDelete: { url in
                        mainViewModel.handlePreviewDelete(url: url)
                    },
                    onShare: { url in
                        mainViewModel.handlePreviewShare(url: url)
                    },
                    isappear: true,
                    onConvert: { url in
                        mainViewModel.handlePreviewConvert(url: url)
                    },
                    shareWrapper: $mainViewModel.shareWrapper
                )
                .transition(.asymmetric(insertion: .scale, removal: .scale))
                .animation(.easeInOut(duration: 0.3), value: mainViewModel.showPreviewScreen)
            }
        }
    }
    
    func pdfPreviewSection(pdfURL: URL) -> some View {
        PDFPreview(
            pdfURL: pdfURL,
            previewScreen: $mainViewModel.navigateToPDFPreview,
            onback: {
                withAnimation {
                    mainViewModel.navigateToPDFPreview = false
                }
            },
            onDelete: {
                if let url = mainViewModel.selectedPDFURL {
                    mainViewModel.deleteTargetURL = url
                    mainViewModel.activeAlert = .delete
                    AnalyticsManager.shared.log(.delete)
                }
            },
            istrue: true
        )
        .transition(.asymmetric(insertion: .scale, removal: .scale))
        .animation(.easeInOut(duration: 0.3), value: mainViewModel.navigateToPDFPreview)
    }
    
    var mainContentSection: some View {
        ZStack(alignment: .bottom) {
            if mainViewModel.showOverlay {
                overlayToolbar
            }
            
            tabContent
            if !mainViewModel.showOverlay {
                bottomTabBarSection
            }
        }
        .ignoresSafeArea(.all)
        .ignoresSafeArea(.keyboard)
        .zIndex(0)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay { loadingOverlay }
        .setupKeyboardObservers(isVisible: $mainViewModel.isKeyboardVisible)
        .setupSheets(viewModel: mainViewModel)
   
    }
    
    var overlayToolbar: some View {
        OverlayToolbar(
            selectedFiles: $mainViewModel.selectedFiles,
            viewModel: mainViewModel,
            historyViewModel: historyViewModel
        )
        .zIndex(1)
    }
    
    @ViewBuilder
    var tabContent: some View {
        Group {
            switch mainViewModel.selectedTab {
            case .home:
                HomeView(
                    isLoading: $mainViewModel.isLoadingImages,
                    showInputView: $mainViewModel.showInputView,
                    selectedImageURLs: $mainViewModel.selectedImageURLs,
                    showPermissionAlert: $mainViewModel.showPermissionAlert
                )
                
                
            case .history:
                HistoryView(
                    viewModel: historyViewModel,
                    selectedPDFURL: $mainViewModel.selectedPDFURL,
                    outputFormatScreen: $mainViewModel.showInputView,
                    navigateToPDFPreview: $mainViewModel.navigateToPDFPreview,
                    selectedFiles: $mainViewModel.selectedFiles,
                    showOverlay: $mainViewModel.showOverlay,
                    fileMode: $mainViewModel.fileMode,
                    imageURLs: $mainViewModel.imageURLs,
                    selectedImageURLs: $mainViewModel.selectedImageURLs,
                    allFileUUIDs: $mainViewModel.allFileUUIDs,
                    showFilePopup: $mainViewModel.showFilePopup,
                    showPreviewScreen: $mainViewModel.showPreviewScreen,
                    selectedPreviewIndex: $mainViewModel.selectedPreviewIndex
                )
                
            case .setting:
                SettingsView()
            }
        }
        .ignoresSafeArea(.all)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .transition(.opacity)
    }
    
    var bottomTabBarSection: some View {
        VStack {
            Spacer()
            if !mainViewModel.isKeyboardVisible {
                BottomTabBar(
                    selectedTab: $mainViewModel.selectedTab,
                    showOverlay: mainViewModel.showOverlay,
                    isKeyboardVisible: mainViewModel.isKeyboardVisible
                )
            }
        }
    }
    
    @ViewBuilder
    var loadingOverlay: some View {
        if mainViewModel.isLoadingImages {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .foregroundColor(.accent)
                .scaleEffect(1.5)
        }
    }
}

// MARK: - View State (ViewModel)

@MainActor
class MainViewState: ObservableObject {
    // Navigation
    @Published var selectedTab: TabSelection = .home
    @Published var showInputView = false
    @Published var showPermissionAlert = false
    @Published var showPreviewScreen = false
    @Published var navigateToPDFPreview = false
    @Published var selectedPreviewIndex: Int?
    @Published var selectedPDFURL: URL?

    
    // File Management
    @Published var selectedFiles: Set<UUID> = []
    @Published var fileMode: FileViewMode = .input
    @Published var imageURLs: [URL] = []
    @Published var selectedImageURLs: [URL] = []
    @Published var allFileUUIDs: [UUID] = []
    
    // UI State
    @Published var showOverlay = false
    @Published var isKeyboardVisible = false
    @Published var isLoadingImages = false
    @Published var showFilePopup = false
    
    // Sharing & Alerts
    @Published var shareWrapper: ShareWrapper?
    @Published var activeAlert: MainAlertType?
    @Published var deleteTargetURL: URL?
    @Published var deleteTargetUUIDs: Set<UUID> = []
    
    // Haptics
    let notificationFeedback = UINotificationFeedbackGenerator()
    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    let selectionFeedback = UISelectionFeedbackGenerator()
    
    // MARK: - Preview Actions
    
    func handlePreviewDelete(url: URL) {
        notificationFeedback.notificationOccurred(.warning)
        deleteTargetURL = url
        activeAlert = .delete
        AnalyticsManager.shared.log(.delete)
    }
    
    func handlePreviewShare(url: URL) {
        shareWrapper = ShareWrapper(urls: [url])
        AnalyticsManager.shared.log(.share)
    }
    
    func handlePreviewConvert(url: URL) {
        AnalyticsManager.shared.log(.convert)
        selectedImageURLs.append(url)
        showInputView = true
    }
    
    // MARK: - Overlay Toolbar Actions
    
    func shareSelectedFiles(from files: [CompressedFile]) {
        guard !selectedFiles.isEmpty else { return }
        AnalyticsManager.shared.log(.share)
        impactFeedback.impactOccurred()
        
        let urls = getURLsFromUUIDs(selectedFiles, files: files)
        if !urls.isEmpty {
            shareWrapper = ShareWrapper(urls: urls)
        }
    }
    
    func convertSelectedFiles(from files: [CompressedFile]) {
        guard !selectedFiles.isEmpty else { return }
        
        AnalyticsManager.shared.log(.convert)
        impactFeedback.impactOccurred()
        
        let urls = getURLsFromUUIDs(selectedFiles, files: files)
        
        if urls.count > 30 {
            notificationFeedback.notificationOccurred(.error)
            activeAlert = .conversionLimitExceeded
        } else {
            selectedImageURLs = urls
            withAnimation {
                showInputView = true
            }
        }
    }
    
    func deleteSelectedFiles() {
        guard !selectedFiles.isEmpty else { return }
        notificationFeedback.notificationOccurred(.warning)
        deleteTargetUUIDs = selectedFiles
        activeAlert = .delete
        AnalyticsManager.shared.log(.delete)
    }
    
    // MARK: - Deletion Execution
    
    func performDeletion(historyViewModel: ImageListViewModel) {
        print("🗑️ performDeletion called")
        
        if let url = deleteTargetURL {
            print("📄 Deleting single file: \(url.lastPathComponent)")
            notificationFeedback.notificationOccurred(.success)
            
            // Delete the file from disk
            if FileManager.default.fileExists(atPath: url.path) {
                print("✅ File exists, deleting from disk")
                try? FileManager.default.removeItem(at: url)
            } else {
                print("⚠️ File doesn't exist on disk")
            }
            
            // Delete from Core Data
            CoreDataManager.shared.deleteCompressedFile(for: url)
            print("✅ Deleted from Core Data")
            
            // Close preview screens
            showPreviewScreen = false
            navigateToPDFPreview = false
            selectedPDFURL = nil
            selectedPreviewIndex = nil
            
            // Clear image URLs
            imageURLs.removeAll()
            
            // Reset delete target
            deleteTargetURL = nil
            
            // Refresh the history view
            historyViewModel.fetch(for: fileMode)
            print("✅ Refreshed history view")
            
        } else if !deleteTargetUUIDs.isEmpty {
            print("📦 Deleting multiple files: \(deleteTargetUUIDs.count)")
            notificationFeedback.notificationOccurred(.success)
            
            // Delete from Core Data
            CoreDataManager.shared.deleteCompressedFiles(with: deleteTargetUUIDs)
            print("✅ Deleted from Core Data")
            
            // Clear selections
            selectedFiles.removeAll()
            deleteTargetUUIDs = []
            showOverlay = false
            
            // Refresh the history view
            historyViewModel.fetch(for: fileMode)
            print("✅ Refreshed history view")
        }
        
        AnalyticsManager.shared.log(.delete)
        print("✅ Delete operation completed")
    }
    
    // MARK: - Helper Methods
    
    private func deleteFileAndRemoveFromCoreData(_ url: URL) {
        try? FileManager.default.removeItem(at: url)
        CoreDataManager.shared.deleteCompressedFile(for: url)
        
        if let index = imageURLs.firstIndex(of: url) {
            imageURLs.remove(at: index)
        }
    }
    
    func getURLsFromUUIDs(_ uuids: Set<UUID>, files: [CompressedFile]) -> [URL] {
        return files
            .filter { file in
                guard let id = file.id else { return false }
                return uuids.contains(id)
            }
            .compactMap { file in
                guard let path = file.filePath else { return nil }
                return FileManager.default
                    .urls(for: .documentDirectory, in: .userDomainMask)
                    .first?
                    .appendingPathComponent(path)
            }
    }
    
    func updateUUIDs(from files: [CompressedFile]) {
        allFileUUIDs = files.compactMap { $0.id }
    }
}

// MARK: - Subviews

struct OverlayToolbar: View {
    @Binding var selectedFiles: Set<UUID>
    @ObservedObject var viewModel: MainViewState
    let historyViewModel: ImageListViewModel
    
    var body: some View {
        VStack {
            HStack {
                // Share Button
                ToolbarButton(
                    imageName: "shareImage",
                    isEnabled: !selectedFiles.isEmpty
                ) {
                    viewModel.shareSelectedFiles(from: historyViewModel.files)
                }
                
                Spacer()
                
                // Convert Button
                ToolbarButton(
                    imageName: "convert",
                    isEnabled: !selectedFiles.isEmpty && !containsPDF,
                    opacity: containsPDF ? 0 : 1
                ) {
                    viewModel.convertSelectedFiles(from: historyViewModel.files)
                }
                .offset(x: ScaleUtility.scaledSpacing(-3))
                
                Spacer()
                
                // Delete Button
                ToolbarButton(
                    imageName: "delete",
                    isEnabled: !selectedFiles.isEmpty
                ) {
                    viewModel.deleteSelectedFiles()
                }
            }
            .padding(.horizontal, ScaleUtility.scaledSpacing(51))
            .padding(.bottom, ScaleUtility.scaledSpacing(20))
        }
        .frame(height: ScaleUtility.scaledValue(90))
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.easeOut(duration: 0.3), value: viewModel.showOverlay)
        .background(Color.appGrey)
    }
    
    private var containsPDF: Bool {
        let urls = viewModel.getURLsFromUUIDs(selectedFiles, files: historyViewModel.files)
        return urls.contains { $0.pathExtension.lowercased() == "pdf" }
    }
}

struct ToolbarButton: View {
    let imageName: String
    let isEnabled: Bool
    var opacity: Double = 1.0
    let action: () -> Void
    
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        Image(imageName)
            .resizable()
            .frame(width: ScaleUtility.scaledValue(45),height: ScaleUtility.scaledValue(45))
            .opacity(isEnabled ? opacity : 0.5)
            .onTapGesture {
                guard isEnabled else { return }
                impactFeedback.impactOccurred()
                action()
            }
    }
}

struct BottomTabBar: View {
    @Binding var selectedTab: TabSelection
    let showOverlay: Bool
    let isKeyboardVisible: Bool
    
    private let selectionFeedback = UISelectionFeedbackGenerator()
    
    var body: some View {
        
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.8),
                            Color.black.opacity(0.4),
                            Color.black.opacity(0.0)
                        ]),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                    
                )
                .ignoresSafeArea(.all)
                .frame(height: isIPad ? ScaleUtility.scaledValue(250) : ScaleUtility.scaledValue(150))
                .allowsHitTesting(true)
                .offset(y: ScaleUtility.scaledSpacing(30))
              
            
            HStack(spacing: ScaleUtility.scaledSpacing(11)) {
                TabBarButton(
                    icon: .homeIcon,
                    isSelected: selectedTab == .home
                ) {
                    selectionFeedback.selectionChanged()
                    selectedTab = .home
                }
                
                TabBarButton(
                    icon:.historyIcon,
                    isSelected: selectedTab == .history
                ) {
                    selectionFeedback.selectionChanged()
                    selectedTab = .history
                }
                
                TabBarButton(
                    icon: .settingsIcon,
                    isSelected: selectedTab == .setting
                ) {
                    selectionFeedback.selectionChanged()
                    selectedTab = .setting
                }
            }
            .padding(.all, ScaleUtility.scaledSpacing(8))
            .background {
                ZStack {
                    Capsule()
                        .fill(.appGrey)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                    Image(.tabBorderIcon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: isIPad ? ScaleUtility.scaledValue(94) : ScaleUtility.scaledValue(74))
                }
            }
            .padding(.bottom, isIPad ? ScaleUtility.scaledSpacing(-15) : ScaleUtility.scaledSpacing(15))
        }
    }
}

struct TabBarButton: View {
    let icon: ImageResource
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(icon)
                .resizable(size: CGSize(
                    width: isIPad ? ScaleUtility.scaledValue(36) : ScaleUtility.scaledValue(24),
                    height:isIPad ? ScaleUtility.scaledValue(36) :  ScaleUtility.scaledValue(24)
                ))
                .frame(width: isIPad ? ScaleUtility.scaledValue(78) : ScaleUtility.scaledValue(58),
                       height: isIPad ? ScaleUtility.scaledValue(78) : ScaleUtility.scaledValue(58))
                .background {
                    if isSelected {
                        LinearGradient(
                            colors: [
                                Color(#colorLiteral(red: 0.60, green: 0.25, blue: 0.90, alpha: 0.35)),
                                Color(#colorLiteral(red: 0.30, green: 0.10, blue: 0.45, alpha: 0.55))
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        
                    }
                    else {
                        Color.appGrey
                    }
                }
                .overlay {
                    if isSelected {
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color(#colorLiteral(red: 0.98, green: 0.45, blue: 0.98, alpha: 1)), // Pink
                                        Color(#colorLiteral(red: 0.55, green: 0.25, blue: 0.90, alpha: 1))  // Purple
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                            .blur(radius: 1.5)     // slight neon glow
                    }
                 }
                .clipShape(Circle())
            
        }
    }
}

// MARK: - View Modifiers

struct KeyboardObserverModifier: ViewModifier {
    @Binding var isVisible: Bool
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                withAnimation {
                    isVisible = true
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                withAnimation {
                    isVisible = false
                }
            }
    }
}

struct SheetsModifiers: ViewModifier {
    @ObservedObject var viewModel: MainViewState
    
    func body(content: Content) -> some View {
        content
            .sheet(item: $viewModel.shareWrapper) { wrapper in
                ActivityViewController(activityItems: wrapper.urls)
            }
    }
}

struct AlertsModifier: ViewModifier {
    @ObservedObject var viewModel: MainViewState
    let historyViewModel: ImageListViewModel
    
    func body(content: Content) -> some View {
        content
            .alert(item: $viewModel.activeAlert) { alertType in
                createAlert(for: alertType)
            }
    }
    
    private func createAlert(for type: MainAlertType) -> Alert {
        switch type {
        case .delete:
            return Alert(
                title: Text("Delete"),
                message: Text("Are you sure you want to delete the selected file(s) from the app?"),
                primaryButton: .destructive(Text("Delete")) {
                    viewModel.performDeletion(historyViewModel: historyViewModel)
                },
                secondaryButton: .cancel {
                    viewModel.deleteTargetURL = nil
                    viewModel.deleteTargetUUIDs = []
                }
            )
            
        case .conversionLimitExceeded:
            return Alert(
                title: Text("Limit Reached!"),
                message: Text("A maximum of 30 images can be converted at once."),
                dismissButton: .default(Text("Got It"))
            )
        }
    }
}

// MARK: - View Extensions

extension View {
    func setupKeyboardObservers(isVisible: Binding<Bool>) -> some View {
        modifier(KeyboardObserverModifier(isVisible: isVisible))
    }
    
    func setupSheets(viewModel: MainViewState) -> some View {
        modifier(SheetsModifiers(viewModel: viewModel))
    }
    
    func setupAlerts(viewModel: MainViewState, historyViewModel: ImageListViewModel) -> some View {
        modifier(AlertsModifier(viewModel: viewModel, historyViewModel: historyViewModel))
    }
}
