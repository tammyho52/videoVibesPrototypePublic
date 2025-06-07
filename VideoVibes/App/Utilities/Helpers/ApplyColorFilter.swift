//
//  ApplyFiltersChain.swift
//  VideoVibes
//
//  Created by Tammy Ho.
//

import CoreImage

/// Applies a color filter to a CIImage based on the specified filter type and intensity.
func applyColorFilter(to image: inout CIImage, filter: Filter, intensity: Float? = nil) throws {
    guard filter != .none else {
        return // No filter to apply
    }
    
    guard let ciFilter = CIFilter(name: filter.ciFilterName) else {
        throw AppError.filterError(message: "Filter \(filter.ciFilterName) not found.")
    }
    ciFilter.setValue(image, forKey: kCIInputImageKey)
    
    // Set intensity for filters, if applicable
    if let intensity {
        ciFilter.setValue(intensity, forKey: kCIInputIntensityKey)
    }
    
    image = ciFilter.outputImage ?? image
}
