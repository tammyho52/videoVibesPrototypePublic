//
//  GenerateFirstFrameThumbnail.swift
//  VideoVibes
//
//  Created by Tammy Ho.
//

import AVFoundation
import UIKit

/// Generates a thumbnail image from the first frame of a video asset.
func generateFirstFrameThumbnail(from asset: AVAsset, maxSize: CGSize) -> UIImage? {
    let imageQualityScaleFactor: CGFloat = 3
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true
    imageGenerator.maximumSize = CGSize(
        width: maxSize.width * UIScreen.main.scale * imageQualityScaleFactor,
        height: maxSize.height * UIScreen.main.scale * imageQualityScaleFactor
    )

    do {
        let time = CMTime(seconds: 0.5, preferredTimescale: 600) // Use 0.5 second as a reference point for the first frame
        let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
        return UIImage(cgImage: cgImage)
    } catch {
        return nil
    }
}
