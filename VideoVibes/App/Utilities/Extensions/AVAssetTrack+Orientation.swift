//
//  AVAssetTrack+Orientation.swift
//  VideoVibes
//
//  Created by Tammy Ho.
//

import AVFoundation
import CoreGraphics

extension AVAssetTrack {
    /// Retrieves the video orientation based on the track's preferred transform.
    func videoOrientation() async throws -> VideoOrientation {
        let transform = try await self.load(.preferredTransform)
        
        switch (transform.a, transform.b, transform.c, transform.d) {
        case (0, 1, -1, 0):
            return .portrait
        case (0, -1, 1, 0):
            return .portraitUpsideDown
        case (1, 0, 0, 1):
            return .landscapeRight
        case (-1, 0, 0, 1):
            return .landscapeLeft
        default:
            return .unknown
        }
    }
}

/// Enumeration representing video orientations.
enum VideoOrientation {
    case portrait
    case portraitUpsideDown
    case landscapeRight
    case landscapeLeft
    case unknown
}

