//
//  DocumentSaver.swift
//  PicVerse
//
//  Created by Neel Kalariya on 28/09/25.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers
import UIKit

struct DocumentSaver: UIViewControllerRepresentable {
    let urls: [URL]

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forExporting: urls, asCopy: true)
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
}
