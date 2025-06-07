//
//  UIViewControllerPreview.swift
//  VideoVibes
//
//  Created by Tammy Ho.
//
//  Defines a SwiftUI-compatible wrapper for previewing UIKit's view controllers during development.

#if DEBUG
import SwiftUI
import UIKit

struct UIViewControllerPreview<ViewController: UIViewController>: UIViewControllerRepresentable {
    let builder: () -> ViewController
    
    init(_ builder: @escaping () -> ViewController) {
        self.builder = builder
    }
    
    func makeUIViewController(context: Context) -> ViewController {
        return builder()
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        // No update needed for preview
    }
}
#endif


