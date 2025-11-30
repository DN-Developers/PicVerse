//
//  HomeView.swift
//  PicVerse
//
//  Created by Neel Kalariya on 02/11/25.
//

import SwiftUI
import Photos
import UniformTypeIdentifiers

struct HomeView: View {
    // MARK: Environment & Bindings
    @EnvironmentObject var remoteConfigManager: RemoteConfigManager
    @EnvironmentObject var purchaseManager: PurchaseManager
    @EnvironmentObject var timerManager: TimerManager

    @Binding var isLoading: Bool
    @Binding var showInputView: Bool
    @Binding var selectedImageURLs: [URL]
    @Binding var showPermissionAlert: Bool

    // MARK: State (kept same names)
    @State var isPressedFile = false
    @State var isPressedPhoto = false
    @State var isPressedPaste = false

    @State var linkSheet = false
    @State var AnotherApp = false
    @State var Desktop = false
    @State var showDocumentPicker = false
    @State var showMediaPicker = false
    @State var isPaywallOn = false
   
    @State var name = ""

    let impactfeedback = UIImpactFeedbackGenerator(style: .medium)
    @State private var currentInfoPage = 0
    @State private var animateEntry = false
    
    @State private var animateSteps: [Bool] = []
    @State private var animationID = UUID()


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
            
            
            VStack(spacing: 0) {
                
                VStack(spacing: ScaleUtility.scaledSpacing(25)) {
                    
                    HStack {
                        Text("PicVerse")
                            .font(FontManager.instrumentSansMediumFont(size: .scaledFontSize(21)))
                            .foregroundColor(.white)
                        Spacer()
                        Button {
                            impactfeedback.impactOccurred()
                            isPaywallOn.toggle()
                        } label: {
                            Image(.crownIcon)
                                .resizable()
                                .frame(width: isIPad  ? ScaleUtility.scaledValue(36) : ScaleUtility.scaledValue(24),
                                       height:  isIPad  ? ScaleUtility.scaledValue(36) : ScaleUtility.scaledValue(24))
                                .opacity(purchaseManager.hasPro ? 0 : 1)
                        }
                    }
                    .padding(.horizontal, ScaleUtility.scaledSpacing(20))
                    .padding(.top, ScaleUtility.scaledSpacing(63))
                    
                    
                    // MARK: Lifetime Banner – glowing gradient bar
                    if !timerManager.isExpired && !purchaseManager.hasPro && remoteConfigManager.showLifeTimeBannerAtHome {
                        LifeTimeGiftOfferBannerView()
                        
                    }
                }
            ScrollView {
                
                Spacer()
                    .frame(height: isIPad ? ScaleUtility.scaledValue(50) : ScaleUtility.scaledValue(35))
                
                VStack(spacing: isIPad ? ScaleUtility.scaledSpacing(38) : ScaleUtility.scaledSpacing(25)) {
                    
                    // MARK: Glowing Buttons Row
                    HStack(spacing: ScaleUtility.scaledSpacing(30)) {
                        glowButton(title: "Files", icon: .fileIcon, gradient: Gradient(colors: [.blue, .cyan])) {
                            selectedImageURLs.removeAll()
                            showDocumentPicker.toggle()
                            impactfeedback.impactOccurred()
                        }
                        
                        glowButton(title: "Photos", icon: .libraryIcon, gradient: Gradient(colors: [.purple, .blue])) {
                            selectedImageURLs.removeAll()
                            checkPhotoLibraryPermission()
                            impactfeedback.impactOccurred()
                        }
                        
                        glowButton(title: "Paste", icon: .pasteIcon, gradient: Gradient(colors: [.pink, .purple])) {
                            selectedImageURLs.removeAll()
                            handlePasteFromClipboard()
                            impactfeedback.impactOccurred()
                        }
                    }
                    .padding(.horizontal, ScaleUtility.scaledSpacing(20))
                    .scaleEffect(animateEntry ? 1 : 0.9)
                    .opacity(animateEntry ? 1 : 0)
                    .animation(.spring(response: 0.7, dampingFraction: 0.8), value: animateEntry)
                    
                    // MARK: Swipe Info Card
                    
                    
                    ZStack {
                        // New gradient background with glow
                        RoundedRectangle(cornerRadius: 22)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.blue.opacity(0.15),
                                        Color.purple.opacity(0.15),
                                        Color.black.opacity(0.4)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 22)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color.blue.opacity(0.5),
                                                Color.purple.opacity(0.5)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                                    .shadow(color: Color.blue.opacity(0.35), radius: 10, x: 0, y: 5)
                            )
                            .shadow(color: Color.black.opacity(0.3), radius: 12, x: 0, y: 6)
                        
                        VStack(alignment: .leading,
                               spacing: isIPad ? ScaleUtility.scaledSpacing(25) : ScaleUtility.scaledSpacing(15)) {
                            // Header
                            HStack {
                                Text(infoTitle(for: currentInfoPage))
                                    .font(FontManager.instrumentSansSemiBoldFont(size: .scaledFontSize(15)))
                                    .foregroundColor(.white)
                                Spacer()
                                Text("Tips")
                                    .font(FontManager.instrumentSansRegularFont(size: .scaledFontSize(12)))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            
                            // Pages
                            TabView(selection: $currentInfoPage) {
                                let steps0 = [
                                    "Open a browser and copy the image link.",
                                    "Download / long-press → Save image.",
                                    "Return → Files → pick downloaded file.",
                                    "Locate your downloaded image.",
                                    "Select output format and tap \"Convert\"."
                                ]

                                infoPage(steps0)
                                    .tag(0)
                                    .onAppear { triggerStepAnimation(for: steps0) }

                                let steps1 = [
                                    "Open the app with the image.",
                                    "Tap the \"Share\" button.",
                                    "Select \"Save Image\" or \"Save to Files\".",
                                    "Return to this app → Photos or Files.",
                                    "Locate and select your saved image.",
                                    "Convert to your desired format."
                                ]

                                infoPage(steps1)
                                    .tag(1)
                                    .onAppear { triggerStepAnimation(for: steps1) }

                                let steps2 = [
                                    "Send via AirDrop / Email to device.",
                                    "Open the received file(s).",
                                    "Tap \"Share\" → \"Save to Files\" or \"Save Image\".",
                                    "Return to this app.",
                                    "Tap \"Files\" or \"Photos\" option.",
                                    "Select images and convert."
                                ]

                                infoPage(steps2)
                                    .tag(2)
                                    .onAppear { triggerStepAnimation(for: steps2) }
                            }
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                            .frame(height: ScaleUtility.scaledValue(220))
                          

                            
                            // Dots
                            HStack(spacing: 8) {
                                ForEach(0..<3) { i in
                                    Circle()
                                        .fill(i == currentInfoPage ? Color.blue : Color.white.opacity(0.15))
                                        .frame(width: 8, height: 8)
                                        .onTapGesture { withAnimation { currentInfoPage = i } }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            
                            
                        }
                        .padding(.horizontal, ScaleUtility.scaledSpacing(20))
                        .padding(.vertical, ScaleUtility.scaledSpacing(16))
                    }
                    .frame(height: isIPad ? ScaleUtility.scaledValue(350) : ScaleUtility.scaledValue(320))
                    .padding(.horizontal, isIPad ? ScaleUtility.scaledSpacing(120) : ScaleUtility.scaledSpacing(20))
                    .padding(.top, ScaleUtility.scaledSpacing(16))
              
                }
                
                Spacer()
                    .frame(height: ScaleUtility.scaledValue(150))
            }
            .onAppear {
                withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.1)) {
                    animateEntry = true
                }
            }
          }
        }
        
        // MARK: Alerts / Sheets
        .fullScreenCover(isPresented: $isPaywallOn) {
            PaywallView(dismissAction: { withAnimation { isPaywallOn = false } },
                        isInternalOpen: true,
                        purchaseCompletSuccessfullyAction: { isPaywallOn = false })
        }
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPicker(onPick: { urls in
                isLoading = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    let saved = urls.compactMap { persistImage(url: $0) }
                    selectedImageURLs.append(contentsOf: saved)
                    isLoading = false
                    showInputView = true
                }
            }, maxSelection: 40)
        }
        .sheet(isPresented: $showMediaPicker) {
            MediaPicker { urls in
                let remaining = 40 - selectedImageURLs.count
                let toAdd = Array(urls.prefix(remaining))
                if !toAdd.isEmpty {
                    isLoading = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        selectedImageURLs.append(contentsOf: toAdd)
                        isLoading = false
                        showInputView = true
                    }
                }
            }
        }
    }

    // MARK: Components
    private func glowButton(title: String, icon: ImageResource, gradient: Gradient, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: ScaleUtility.scaledSpacing(10)) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(gradient: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: isIPad ? ScaleUtility.scaledValue(108) : ScaleUtility.scaledValue(72),
                               height: isIPad ? ScaleUtility.scaledValue(108) : ScaleUtility.scaledValue(72))
                        .blur(radius: 8)
                        .opacity(0.5)
                    Circle()
                        .strokeBorder(LinearGradient(gradient: gradient, startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2)
                        .frame(width:  isIPad ? ScaleUtility.scaledValue(108) :  ScaleUtility.scaledValue(72),
                               height:  isIPad ? ScaleUtility.scaledValue(108) :  ScaleUtility.scaledValue(72))
                        .overlay(
                            Circle()
                                .fill(Color.white.opacity(0.05))
                        )
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width:  isIPad ? ScaleUtility.scaledValue(48) :  ScaleUtility.scaledValue(32),
                               height:  isIPad ? ScaleUtility.scaledValue(48) :  ScaleUtility.scaledValue(32))
                        .foregroundColor(.white)
                }
                Text(title)
                    .font(FontManager.instrumentSansSemiBoldFont(size: .scaledFontSize(14)))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(.plain)
    }

    private func infoTitle(for index: Int) -> String {
        switch index {
        case 0: return "From the Web"
        case 1: return "From Another App"
        default: return "From PC / Desktop"
        }
    }

    private func infoPage(_ steps: [String]) -> some View {
        VStack(alignment: .leading, spacing: ScaleUtility.scaledSpacing(15)) {
            ForEach(steps.indices, id: \.self) { i in
                HStack(spacing: ScaleUtility.scaledSpacing(10)) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.08))
                            .frame(width: ScaleUtility.scaledValue(24), height: ScaleUtility.scaledValue(24))
                        Text("\(i + 1)")
                            .font(FontManager.instrumentSansBoldFont(size: .scaledFontSize(11)))
                            .foregroundColor(.white)
                    }
                    Text(steps[i])
                        .font(FontManager.instrumentSansRegularFont(size: .scaledFontSize( isIPad ? 14 : 12)))
                        .foregroundColor(.white.opacity(0.85))
                }
                .offset(x: animateSteps.indices.contains(i) && animateSteps[i] ? 0 : 40)
                .opacity(animateSteps.indices.contains(i) && animateSteps[i] ? 1 : 0)
            }
        }
       
      
    }



    // MARK: Logic Helpers
    func persistImage(url: URL) -> URL? {
        let fm = FileManager.default
        let dir = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dest = dir.appendingPathComponent(url.lastPathComponent)
        do {
            if !fm.fileExists(atPath: dest.path) {
                try fm.copyItem(at: url, to: dest)
            }
            return dest
        } catch { print("❌ Copy failed:", error); return nil }
    }

    func handlePasteFromClipboard() {
        let pb = UIPasteboard.general
        let tmp = FileManager.default.temporaryDirectory
        let remaining = 40 - selectedImageURLs.count
        guard remaining > 0 else { return }
        let providers = pb.itemProviders.filter {
            $0.hasItemConformingToTypeIdentifier(UTType.image.identifier)
        }
        for p in providers.prefix(remaining) {
            p.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, _ in
                guard let data else { return }
                let url = tmp.appendingPathComponent(UUID().uuidString + ".png")
                try? data.write(to: url)
                DispatchQueue.main.async {
                    selectedImageURLs.append(url)
                    showInputView = true
                }
            }
        }
    }

    func checkPhotoLibraryPermission() {
        // Selecting images never requires permission → open picker directly
        showMediaPicker = true
    }

    // You can remove this function as it's no longer needed
    // func showPermissionDeniedAlert() {
    //     showPermissionAlert = true
    // }
    
    func showPermissionDeniedAlert() {
        showPermissionAlert = true
    }
    
    func triggerStepAnimation(for steps: [String]) {
        // Change animation ID → cancels older pending callbacks
        animationID = UUID()
        let currentID = animationID

        animateSteps = Array(repeating: false, count: steps.count)

        for i in 0..<steps.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.52) {
                // Only run if this is the latest animation cycle
                guard currentID == animationID else { return }

                if i < animateSteps.count {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        animateSteps[i] = true
                    }
                }
            }
        }
    }




}


// MARK: - Color helper
extension Color {
    init(hex: String) {
        let s = Scanner(string: hex); _ = s.scanString("#")
        var rgb: UInt64 = 0; s.scanHexInt64(&rgb)
        self.init(red: Double((rgb >> 16) & 0xFF)/255,
                  green: Double((rgb >> 8) & 0xFF)/255,
                  blue: Double(rgb & 0xFF)/255)
    }
}
