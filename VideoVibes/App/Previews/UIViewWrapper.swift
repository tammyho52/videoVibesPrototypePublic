//
//  UIViewWrapper.swift
//  VideoVibes
//
//  Created by Tammy Ho.
//
//  A SwiftUI wrapper for a UIView to allow UIKit views in SwiftUI previews.

#if DEBUG
import SwiftUI
import UIKit

struct UIViewWrapper<UIViewType: UIView>: UIViewRepresentable {
    let view: UIViewType

    init(_ view: UIViewType) {
        self.view = view
    }

    func makeUIView(context: Context) -> UIViewType {
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        // No update logic needed for this wrapper
    }
}
#endif
