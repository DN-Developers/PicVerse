//
//  PopOverViewModifier.swift
//  iOS-Picture-Converter
//
//  Created by Darsh Viroja on 03/05/25.
//

import Foundation
import SwiftUI

// Popover Modifier
struct PopoverViewModifier<PopoverContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    var popoverSize: CGSize?
    let popoverContent: () -> PopoverContent
    var popoverTopPadding: CGFloat
    var cornerRadius: CGFloat // NEW: Custom corner radius

    init(
        isPresented: Binding<Bool>,
        popoverSize: CGSize? = CGSize(width: 96, height: 119),
        popoverContent: @escaping () -> PopoverContent,
        popoverTopPadding: CGFloat,
        cornerRadius: CGFloat = 12 // NEW: Default radius
    ) {
        self._isPresented = isPresented
        self.popoverSize = popoverSize
        self.popoverContent = popoverContent
        self.popoverTopPadding = popoverTopPadding
        self.cornerRadius = cornerRadius
    }

    func body(content: Content) -> some View {
        content
            .background(
                PopoverWrapper(
                    isPresented: $isPresented,
                    popoverSize: popoverSize,
                    popoverContent: popoverContent,
                    cornerRadius: cornerRadius // NEW: Pass to wrapper
                )
                .padding(.top, popoverTopPadding)
                .offset(
                    x: isIPad ? ScaleUtility.scaledSpacing(224) : ScaleUtility.scaledSpacing(84),
                    y: ScaleUtility.scaledSpacing(17)
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            )
    }
}




// The Wrapper that will handle the popover logic
struct PopoverWrapper<PopoverContent: View>: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var popoverSize: CGSize?
    let popoverContent: () -> PopoverContent
    var cornerRadius: CGFloat // <-- NEW

    func makeUIViewController(context: Context) -> PopoverViewController<PopoverContent> {
        let controller = PopoverViewController(
            popoverSize: popoverSize,
            popoverContent: popoverContent,
            cornerRadius: cornerRadius, // <-- PASS IT
            onDismiss: { self.isPresented = false }
        )
        return controller
    }

    func updateUIViewController(_ uiViewController: PopoverViewController<PopoverContent>, context: Context) {
        uiViewController.updateSize(popoverSize)
        if isPresented {
            uiViewController.showPopover()
        } else {
            uiViewController.hidePopover()
        }
    }
}


// Popover ViewController to manage the actual popover
class PopoverViewController<PopoverContent: View>: UIViewController, UIPopoverPresentationControllerDelegate {
    var popoverSize: CGSize?
    let popoverContent: () -> PopoverContent
    let onDismiss: () -> Void
    let cornerRadius: CGFloat

    
    var popoverVC: UIViewController?
    init(
        popoverSize: CGSize?,
        popoverContent: @escaping () -> PopoverContent,
        cornerRadius: CGFloat,
        onDismiss: @escaping () -> Void
    ) {
        self.popoverSize = popoverSize
        self.popoverContent = popoverContent
        self.cornerRadius = cornerRadius
        self.onDismiss = onDismiss
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none // Keeps popover on iPhone
    }

    func showPopover() {
        guard popoverVC == nil else { return }
        
        let vc = UIHostingController(rootView:
            ZStack {
            Color.appGrey // Default background
                popoverContent()
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            }
        )

        if let size = popoverSize {
            vc.preferredContentSize = size
        }

        vc.modalPresentationStyle = .popover

        if let popover = vc.popoverPresentationController {
            popover.sourceView = view
            popover.delegate = self
            popover.permittedArrowDirections = []  // No arrow

            let rect = CGRect(x: view.bounds.midX - (popoverSize?.width ?? 0) / 2,
                              y: view.bounds.origin.y + 20,
                              width: popoverSize?.width ?? 300,
                              height: popoverSize?.height ?? 200)
            popover.sourceRect = rect
        }

        popoverVC = vc
        self.present(vc, animated: true, completion: nil)
    }


    func hidePopover() {
        guard let vc = popoverVC, !vc.isBeingDismissed else { return }
        vc.dismiss(animated: true, completion: nil)
        popoverVC = nil
    }

    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        popoverVC = nil
        self.onDismiss()
    }

    func updateSize(_ size: CGSize?) {
        self.popoverSize = size
        if let vc = popoverVC, let size = size {
            vc.preferredContentSize = size
        }
    }
}

