//
//  Filter.swift
//  VideoVibes
//
//  Created by Tammy Ho.
//
//  Defines the filters available for video editing feature.

import Foundation

enum Filter: CaseIterable, Equatable {
    case none
    case sepia // Vintage look
    case noir // Black and white effect
    case mono // Monochrome effect
    case monochrome // Darkened edges
    
    /// Returns the Core Image filter name associated with the filter.
    var ciFilterName: String {
        switch self {
        case .none: return "" // No filter applied
        case .sepia: return "CISepiaTone"
        case .noir: return "CIPhotoEffectNoir"
        case .mono: return "CIPhotoEffectMono"
        case .monochrome: return "CIColorMonochrome"
        }
    }
    
    /// Provides a user-friendly display name for the filter.
    var displayName: String {
        switch self {
        case .none: return "None"
        case .sepia: return "Sepia"
        case .noir: return "Noir"
        case .mono: return "Mono"
        case .monochrome: return "Tint"
        }
    }
    
    /// Determines if the filter has an intensity parameter.
    var hasIntensity: Bool {
        switch self {
        case .sepia, .monochrome:
            return true
        case .noir, .mono, .none:
            return false
        }
    }
}
        
