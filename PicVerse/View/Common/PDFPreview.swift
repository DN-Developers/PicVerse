//
//  PDFPreview.swift
//  PicVerse
//
//  Created by Neel Kalariya on 28/09/25.
//

import Foundation
import Foundation
import SwiftUI
import PDFKit

struct PDFPreview: View {
    let pdfURL: URL
    @Binding var previewScreen: Bool
    var onback: () -> Void
    
    @State private var showOverlay: Bool = true
    @State private var document: PDFDocument?
    
    // Overlay header with back button and file name
    @State private var shareWrapper: ShareWrapper? = nil
    @State private var deleteTargetURL: URL? = nil
    
    var onDelete: (() -> Void)?
    
    var istrue: Bool
    
    let notificationfeedback = UINotificationFeedbackGenerator()
    let impactfeedback = UIImpactFeedbackGenerator(style: .medium)
    let selectionfeedback = UISelectionFeedbackGenerator()
    @EnvironmentObject var purchaseManager: PurchaseManager
    
    @State var isPaywallOn = false
    
    
    private var overlayHeader: some View {
        
        HStack{
            
            HStack(spacing: ScaleUtility.scaledSpacing(91) ) {
                Button(action: {
                    impactfeedback.impactOccurred()
                    previewScreen = false
                    onback()
                }) {
                    Image("backIcon")
                        .resizable()
                        .frame(width: isIPad ? ScaleUtility.scaledValue(34) :  ScaleUtility.scaledValue(24) ,
                               height:isIPad ? ScaleUtility.scaledValue(34) :   ScaleUtility.scaledValue(24))
                    
                }
                
                if isIPad
                {
                  Spacer()
                }
                
                Text(pdfURL.lastPathComponent)
                    .font(FontManager.instrumentSansMediumFont(size: .scaledFontSize(21)))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                if isIPad
                {
                  Spacer()
                }
                Button {
                    impactfeedback.impactOccurred()
                    isPaywallOn.toggle()
                } label:
                {
                    Image("crownIcon")
                        .resizable()
                        .frame(width: isIPad ? ScaleUtility.scaledValue(34) :  ScaleUtility.scaledValue(24) ,
                               height:isIPad ? ScaleUtility.scaledValue(34) :   ScaleUtility.scaledValue(24))
                        .opacity(purchaseManager.hasPro ? 0 : 1)
                }
                
            }
            .padding(.horizontal,isIPad ? ScaleUtility.scaledSpacing(40) : ScaleUtility.scaledSpacing(20))
            
        }
        .frame(maxWidth:.infinity)
        .frame(height: ScaleUtility.scaledValue(50) * heightRatio)
        .background(Color.black)
        .shadow(radius: 3)
       
    }
    
    
    private var overlayFooter: some View {
        
        HStack{
            
            HStack {
                Button(action: {
                    impactfeedback.impactOccurred()
                        shareWrapper = ShareWrapper(urls: [pdfURL])
                    
                }) {
                    Image("shareImage")
                        .resizable()
                        .resizable(size: CGSize(
                            width: isIPad ? ScaleUtility.scaledValue(55) :  ScaleUtility.scaledValue(45),
                            height: isIPad ?  ScaleUtility.scaledValue(53) : ScaleUtility.scaledValue(43)))
                    
                }
                
     
                Spacer()
                
                Button(action: {
                    notificationfeedback.notificationOccurred(.warning)
                    onDelete?()
                }) {
                    Image("delete")
                        .resizable()
                        .resizable(size: CGSize(
                            width: isIPad ? ScaleUtility.scaledValue(55) :  ScaleUtility.scaledValue(45),
                            height: isIPad ?  ScaleUtility.scaledValue(53) : ScaleUtility.scaledValue(43)))
                    
                    
                }
            
            }
            .padding(.horizontal,ScaleUtility.scaledSpacing(50))
            .padding(.top,ScaleUtility.scaledSpacing(10))
            
        }
        .frame(maxWidth:.infinity,alignment: .bottom)
        .frame(height: ScaleUtility.scaledValue(50) * heightRatio)
        .background(Color.black)
        .shadow(radius: 3)
  
    }
    
    
    var body: some View {
        ZStack(alignment: .top) {
            if let document = document {
                PDFKitView(document: document)
                    .edgesIgnoringSafeArea(.all)
            } else {
                ProgressView("")
                    .progressViewStyle(CircularProgressViewStyle())
                    .tint(.white)
            }
            
            if showOverlay {
                overlayHeader
                    .transition(.move(edge: .top).combined(with: .opacity))
                
            }
            
       
            
        }
        .frame(maxWidth:.infinity,maxHeight: .infinity)
        .background(Color.black)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 )
            {
                downloadPDF()
            }
            showOverlay = false
        }
        .onTapGesture {
            withAnimation {
                showOverlay.toggle()
            }
        }
        .sheet(item: $shareWrapper) { wrapper in
            ActivityViewController(activityItems: wrapper.urls)
        }
        .overlay(alignment: .bottom) {
            
            if showOverlay && istrue {
                overlayFooter
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
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
        .navigationBarHidden(true)

    }
    
    // Download PDF from the URL and load into the PDFDocument
    private func downloadPDF() {
        // Create a temporary file path to store the downloaded PDF
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let fileURL = documentDirectory.appendingPathComponent(pdfURL.lastPathComponent)
        
        // Check if the PDF is already downloaded
        if fileManager.fileExists(atPath: fileURL.path) {
            // If the file already exists, load the document from the file
            loadPDF(from: fileURL)
        } else {
            // If the file doesn't exist, download it
            URLSession.shared.downloadTask(with: pdfURL) { localURL, response, error in
                guard let localURL = localURL, error == nil else {
                    // Handle download error
                    return
                }
                
                // Move the downloaded file to the document directory
                do {
                    try fileManager.moveItem(at: localURL, to: fileURL)
                    loadPDF(from: fileURL)
                } catch {
                    // Handle file move error
                    print("Error moving file: \(error)")
                }
            }.resume()
        }
    }
    
    // Load PDF from the local URL
    private func loadPDF(from url: URL) {
        if let pdfDocument = PDFDocument(url: url) {
            DispatchQueue.main.async {
                document = pdfDocument
            }
        }
    }
}

struct PDFKitView: UIViewRepresentable {
    let document: PDFDocument

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = document
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        // No update needed here, as PDFView is static for now
    }
}
