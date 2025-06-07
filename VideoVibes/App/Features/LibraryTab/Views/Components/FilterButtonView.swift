//
//  FilterButtonView.swift
//  VideoVibes
//
//  Created by Tammy Ho.
//
//  Custom button with a thumbnail image representing the filter.

import UIKit

class FilterButtonView: UIButton {
    // MARK: - Properties
    /// The base image used for the filter button, which is a placeholder image.
    private let baseImage: UIImage = UIImage(named: "Lake")!
    
    /// The filter associated with this button.
    let filter: Filter
    
   var isSelectedFilter: Bool {
       didSet {
           updateSelection()
       }
    }
    
    // MARK: - Initializers
    init(filter: Filter, isSelectedFilter: Bool) {
        self.filter = filter
        self.isSelectedFilter = isSelectedFilter
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    /// Configures the button's appearance and behavior.
    private func configure() {
        alpha = 0 // Initially hidden until the image is loaded
        layer.cornerRadius = 10
        layer.borderWidth = 3.5
        updateSelection()
        clipsToBounds = true
        
        imageView?.contentMode = .scaleAspectFill
        translatesAutoresizingMaskIntoConstraints = false
        
        // Enforce square aspect ratio
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalTo: widthAnchor)
        ])
        
        Task {
            await loadImage()
        }
    }
    
    /// Loads the filtered version of the base image and sets it as the button's background image.
    private func loadImage() async {
        let filteredImage = await getFilteredBaseImage(intensity: filter.hasIntensity ? 1 : nil) ?? baseImage
        await MainActor.run {
            setBackgroundImage(filteredImage, for: .normal)
            // Fade in once the image is set
            UIView.animate(withDuration: 0.3) {
                self.alpha = 1
            }
        }
    }
    
    /// Applies the specified color filter and intensity to the base image.
    private func getFilteredBaseImage(intensity: Float?) async -> UIImage? {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                defer {
                    continuation.resume(returning: nil) // fallback if nothing returns above
                }
                
                if var ciImage = CIImage(image: self.baseImage) {
                    try? applyColorFilter(to: &ciImage, filter: self.filter, intensity: intensity)
                    
                    let context = CIContext()
                    if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
                        let filteredImage = UIImage(cgImage: cgImage)
                        continuation.resume(returning: filteredImage)
                        return
                    }
                }
                continuation.resume(returning: nil)
            }
        }
    }
    
    /// Updates the button's border color based on whether it is selected.
    private func updateSelection() {
        layer.borderColor = isSelectedFilter ? Theme.primaryColor.cgColor : UIColor.clear.cgColor
    }
}
