//
//  FetchVideoAsset.swift
//  VideoVibes
//
//  Created by Tammy Ho.
//

import Photos

/// Fetches video assets from the Photos library using their local identifiers.
func fetchVideoAssets(with identifiers: [String]) -> [PHAsset] {
    let assets: PHFetchResult = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)
    let results: [PHAsset] = (0..<assets.count).compactMap { assets.object(at: $0) }
    return results
}
