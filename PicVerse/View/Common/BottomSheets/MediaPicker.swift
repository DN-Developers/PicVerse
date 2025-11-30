//
//  MediaPicker.swift
//  iOS-Picture-Converter
//
//  Created by Darsh Viroja on 30/04/25.
//

import Foundation
import PhotosUI
import AVFoundation
import SwiftUI

struct MediaPicker: UIViewControllerRepresentable {
    var onPick: ([URL]) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images  // ✅ Only allow image selection
        config.selectionLimit = 40

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let onPick: ([URL]) -> Void

        init(onPick: @escaping ([URL]) -> Void) {
            self.onPick = onPick
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            let group = DispatchGroup()
            var urls: [URL] = []

            for result in results {
                group.enter()
                let provider = result.itemProvider

                if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                    provider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { url, _ in
                        if let url = url {
                            self.copyAndAppend(url: url, to: &urls)
                        }
                        group.leave()
                    }
                } else {
                    group.leave()  // Skip non-images
                }
            }

            group.notify(queue: .main) {
                self.onPick(urls)
            }
        }

        private func copyAndAppend(url: URL, to urls: inout [URL]) {
            let fileName = url.lastPathComponent
            let destination = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

            try? FileManager.default.copyItem(at: url, to: destination)
            urls.append(destination)
        }
    }
}
