//
//  DocumentPicker.swift
//  iOS-Picture-Converter
//
//  Created by Darsh Viroja on 30/04/25.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct DocumentPicker: UIViewControllerRepresentable {
    var onPick: ([URL]) -> Void
    var maxSelection: Int = 40  // ✅ Add a max selection limit

    func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick, maxSelection: maxSelection)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let supportedTypes: [UTType] = [.image]  // ✅ Allow only images
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes, asCopy: true)
        picker.allowsMultipleSelection = true
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPick: ([URL]) -> Void
        let maxSelection: Int

        init(onPick: @escaping ([URL]) -> Void, maxSelection: Int) {
            self.onPick = onPick
            self.maxSelection = maxSelection
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            let limitedURLs = Array(urls.prefix(maxSelection))  // ✅ Enforce limit here
            onPick(limitedURLs)
        }
    }

}
