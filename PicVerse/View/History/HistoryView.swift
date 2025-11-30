//
//  HistoryView.swift
//  PicVerse
//
//  Created by Neel Kalariya on 28/09/25.
//

import Foundation
import SwiftUI

enum MainAlertType: Identifiable {
    case delete
    case conversionLimitExceeded

    var id: Int {
        switch self {
        case .delete: return 0
        case .conversionLimitExceeded: return 1
        }
    }
}


enum FileViewMode: String {
    case input = "Input Files"
    case output = "Output Files"
    case all = "all"
}

struct HistoryView: View {
    @EnvironmentObject var purchaseManager: PurchaseManager
    @ObservedObject var viewModel: ImageListViewModel
    
    let notificationfeedback = UINotificationFeedbackGenerator()
    let impactfeedback = UIImpactFeedbackGenerator(style: .medium)
    let selectionfeedback = UISelectionFeedbackGenerator()
    
    @State var selectedTab: Int = 0
    @State private var isNameAscending: Bool = true
    @State private var isSizeAscending: Bool = true
  
    @State var selectedFilerName: Bool = false
    @State private var searchText: String = ""

    @State private var selectedIndexForPopover: Int? = nil
    @State private var fileToShare: URL?
    @State private var showShareSheet: Bool = false
    @State private var fileToDelete: CompressedFile?
    @State private var showDeleteConfirmation: Bool = false
    @State var isPaywallOn = false
    
    
    @State private var deleteTargetURL: URL? = nil
    @State private var deleteTargetUUIDs: Set<UUID> = []
    @State private var activeAlert: MainAlertType? = nil
    @State private var shareWrapper: ShareWrapper? = nil
    
    @FocusState private var isSearchFocused: Bool
  
   
    @Binding  var selectedPDFURL: URL?
    @Binding  var outputFormatScreen: Bool
    @Binding  var navigateToPDFPreview: Bool
    @Binding  var selectedFiles: Set<UUID>
    @Binding var showOverlay: Bool
    @Binding  var fileMode: FileViewMode
    @Binding  var imageURLs: [URL]
    @Binding var selectedImageURLs: [URL] // <- bind to MainView
    @Binding var allFileUUIDs: [UUID]
    @Binding  var showFilePopup: Bool
    @Binding  var showPreviewScreen: Bool
    @Binding  var selectedPreviewIndex: Int?

    
    var body: some View {
        ZStack {
            
            // Background: subtle radial glow
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
            
            VStack {
                
                if showOverlay
                {
                    overlayHeader
                      
                }
                else {
                
                    VStack(spacing: ScaleUtility.scaledSpacing(34)) {
                        
                        HStack {
                         
                            HStack {
               
                                Text("History")
                                    .font(FontManager.instrumentSansMediumFont(size: .scaledFontSize(21)))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white)
                              
                                
                                Spacer()
                                
                                
                                Button {
                                    impactfeedback.impactOccurred()
                                    isPaywallOn.toggle()
                                    
                                } label:{
                                    Image(.crownIcon)
                                        .resizable(size: CGSize(
                                            width: isIPad ? ScaleUtility.scaledValue(34) :  ScaleUtility.scaledValue(24),
                                            height: isIPad ?  ScaleUtility.scaledValue(34) : ScaleUtility.scaledValue(24)))
                                        .opacity(purchaseManager.hasPro ? 0 : 1)
                                }
                                
                                
                            }
                            .padding(.horizontal, ScaleUtility.scaledSpacing(20))
                            
                            
                        }
                        .padding(.top, ScaleUtility.scaledSpacing(63))
                        
                        VStack(spacing: ScaleUtility.scaledSpacing(20)) {
                            
                            CustomTabPicker(selectedTab: $selectedTab, tabs: ["Input Files","Output Files"])
                            
                           
                                TopView(
                                    viewModel: viewModel,
                                    searchText: $searchText,
                                    selectedFilerName: $selectedFilerName,
                                    isSearchFocused: $isSearchFocused)
                                .popoverView(
                                    isPresented: $selectedFilerName,
                                    popOverTopPadding: 0,
                                    popOverSize: CGSize(width: isIPad ? 187  : 167, height:  isIPad ? 187.08545 : 157.08545)
                                ) {
                                    FilterPopUp(
                                        onDate: {
                                            viewModel.sortByDate(ascending: false)
                                            selectedFilerName = false
                                        },
                                        AToZ: {
                                            viewModel.sortByName(ascending: true)
                                            selectedFilerName = false
                                        },
                                        ZToA: {
                                            viewModel.sortByName(ascending: false)
                                            selectedFilerName = false
                                        },
                                        lowSize: {
                                            viewModel.sortBySize(ascending: true)
                                            selectedFilerName = false
                                        },
                                        highSize: {
                                            viewModel.sortBySize(ascending: false)
                                            selectedFilerName = false
                                        },
                                        isNameAscending: $isNameAscending,
                                        isSizeAscending: $isSizeAscending
                                    )
                                }
                            
                        }
                        
                        
                    }
                    
                    
                }

                // Display ImageListView based on the selected mode
                ImageListView(
                    fileMode: $fileMode,
                    selectedFiles: $selectedFiles,
                    showOverlay: $showOverlay,
                    allFileUUIDs: $allFileUUIDs,
                    viewModel: viewModel,                           // ✅ ObservedObject (no $)
                    onPreviewTap: { index in                        // ✅ Closure
                        selectedPreviewIndex = index
                        withAnimation {
                            showPreviewScreen = true
                        }
                    },
                    imageURLs: $imageURLs,                          // ✅ Binding
                    showPreviewScreen: $showPreviewScreen,          // ✅ Binding
                    selectedImageURLs: $selectedImageURLs,          // ✅ Binding
                    outputFormatScreen: $outputFormatScreen,        // ✅ Binding
                    showFilePopup: $showFilePopup,                  // ✅ Binding
                    navigateToPDFPreview: $navigateToPDFPreview,    // ✅ Binding
                    selectedPDFURL: $selectedPDFURL,                // ✅ Binding
                    searchText: $searchText                         // ✅ Binding
                )
                .padding(.top, showOverlay ? 0 : ScaleUtility.scaledSpacing(14))
                
                Spacer()
            }
            .onChange(of: searchText) { newValue in
                viewModel.filterFiles(searchText: newValue)
            }
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
            .onChange(of: fileMode) { _ in
                searchText = ""            // Clear the text
                isSearchFocused = false    // Dismiss the keyboard
            }
        }
        .onAppear {
            if selectedTab == 0 {
                fileMode = .input
            }
            else {
                fileMode = .output
            }
        }
        .onChange(of: selectedTab) {
            if selectedTab == 0 {
                fileMode = .input
            }
            else {
                fileMode = .output
            }
        }
        .sheet(item: $shareWrapper) { wrapper in
            ActivityViewController(activityItems: wrapper.urls)
        }
        .alert(item: $activeAlert) { alertType in
            switch alertType {
            case .delete:
                return Alert(
                    title: Text("Delete"),
                    message: Text("Are you sure you want to delete the selected file(s) from the app?"),
                    primaryButton: .destructive(Text("Delete")) {
                        if let url = deleteTargetURL {
                            notificationfeedback.notificationOccurred(.success)
                            deleteFileAndRemoveFromCoreData(url)
                            showPreviewScreen = false
                            selectedPreviewIndex = 0
                            imageURLs.removeAll()
                            deleteTargetURL = nil
                            navigateToPDFPreview = false
                        } else if !deleteTargetUUIDs.isEmpty {
                            notificationfeedback.notificationOccurred(.success)
                            CoreDataManager.shared.deleteCompressedFiles(with: deleteTargetUUIDs)
                            selectedFiles.removeAll()
                            deleteTargetUUIDs = []
                            showOverlay = false
                            viewModel.fetch(for: fileMode)
                            navigateToPDFPreview = false
                        }
                        AnalyticsManager.shared.log(.delete)
                    },
                    secondaryButton: .cancel {
                        deleteTargetURL = nil
                        deleteTargetUUIDs = []
                    }
                )
                
            case .conversionLimitExceeded:
                return Alert(
                    title: Text("Limit Reached!"),
                    message: Text("A maximum of 30 images can be converted at once."),
                    dismissButton: .default(Text("Got It")) {
                        // Optional: reset state
                    }
                )
            }
        }

    }
    
    
    private var overlayHeader: some View {
        VStack {
            let allImageOnlyUUIDs: [UUID] = viewModel.filteredFiles.compactMap { file in
                guard let id = file.id,
                      let url = getFileURL(for: file),
                      url.pathExtension.lowercased() != "pdf" else {
                    return nil
                }
                return id
            }
            
            // Check if there are images in the viewModel or not
            let hasImages = viewModel.filteredFiles.contains { file in
                guard let url = getFileURL(for: file) else { return false }
                return url.pathExtension.lowercased() != "pdf"
            }
            
            HStack {
                Text("Cancel")
                    .font(FontManager.instrumentSansRegularFont(size: .scaledFontSize(16)))
                    .foregroundColor(.white)
                    .onTapGesture {
                        showOverlay = false
                        selectedFiles.removeAll()
                        selectionfeedback.selectionChanged()
                    }

                Spacer()

                Text("Selected (\(selectedFiles.count))")
                    .font(FontManager.instrumentSansSemiBoldFont(size: .scaledFontSize(21)))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .offset(x: ScaleUtility.scaledSpacing(15))

                Spacer()

                Text(hasImages ?
                     (allImageOnlyUUIDs.allSatisfy { selectedFiles.contains($0) } ? "Deselect All" : "Select All") :
                     (viewModel.filteredFiles.map { $0.id ?? UUID() }.allSatisfy { selectedFiles.contains($0) } ? "Deselect All" : "Select All"))
                    .font(FontManager.instrumentSansRegularFont(size: .scaledFontSize(16)))
                    .foregroundColor(.white)
                    .onTapGesture {
                        selectionfeedback.selectionChanged()
                        if hasImages {
                            // Handle Select All/Deselect All for images
                            if allImageOnlyUUIDs.allSatisfy({ selectedFiles.contains($0) }) {
                                // Deselect all image-only items
                                allImageOnlyUUIDs.forEach { selectedFiles.remove($0) }
                            } else {
                                var imageOnlyUUIDs: [UUID] = []

                                for file in viewModel.filteredFiles {
                                    if let id = file.id,
                                       let url = getFileURL(for: file),
                                       url.pathExtension.lowercased() != "pdf" {
                                        imageOnlyUUIDs.append(id)
                                    }
                                }

                                selectedFiles = Set(imageOnlyUUIDs)
                            }
                        } else {
                            // Handle Select All/Deselect All for PDFs
                            if viewModel.filteredFiles.map({ $0.id ?? UUID() }).allSatisfy({ selectedFiles.contains($0) }) {
                                // Deselect all PDFs
                                viewModel.filteredFiles.forEach { file in
                                    if let id = file.id {
                                        selectedFiles.remove(id)
                                    }
                                }
                            } else {
                                var pdfUUIDs: [UUID] = []

                                for file in viewModel.filteredFiles {
                                    if let id = file.id,
                                       let url = getFileURL(for: file),
                                       url.pathExtension.lowercased() == "pdf" {
                                        pdfUUIDs.append(id)
                                    }
                                }

                                selectedFiles = Set(pdfUUIDs)
                            }
                        }

                      
                    }
                    .offset(x: ScaleUtility.scaledSpacing(-3))

            }
            .padding(.horizontal, ScaleUtility.scaledSpacing(20))
            .padding(.top, ScaleUtility.scaledSpacing(30))
        }
        .frame(height: isIPad ?  ScaleUtility.scaledValue(104) :  ScaleUtility.scaledValue(104))
        .background(Color.appGrey)
        .shadow(radius: 5)
        .transition(.move(edge: .top).combined(with: .opacity))
        .animation(.easeOut(duration: 0.3), value: showOverlay)
    }

    
    func getFileURL(for file: CompressedFile) -> URL? {
        guard let name = file.fileName else { return nil }
        let manager = FileManager.default
        let docURL = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        return docURL?.appendingPathComponent(name)
    }
    
    
    func deleteFileAndRemoveFromCoreData(_ url: URL) {
        // Delete the file from disk
        try? FileManager.default.removeItem(at: url)

        // Delete the record from Core Data
        CoreDataManager.shared.deleteCompressedFile(for: url)
   

        // Remove from list shown in UI
        if let index = imageURLs.firstIndex(of: url) {
            imageURLs.remove(at: index)
        }
    }
    
}
