//
//  ActivityViewController.swift
//  PicVerse
//
//  Created by Neel Kalariya on 28/09/25.
//


import Foundation
import SwiftUI
import UIKit

struct ActivityViewController: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct ShareWrapper: Identifiable {
    let id = UUID()
    let urls: [URL]
}
