//
//  VideoFilterService.swift
//  VideoVibes
//
//  Created by Tammy Ho.
//
//  Service responsible for applying filters to video previews and managing video previews for the video filter screen.

import Foundation
import AVFoundation
import CoreImage

class VideoFilterService {
    // MARK: - Properties
    private var player: AVQueuePlayer?
    private var playerItem: AVPlayerItem?
    private var playerLooper: AVPlayerLooper?
    
    private var currentFilter: Filter
    private var videoURL: URL?
    
    var avPlayer: AVPlayer? {
        return player
    }
    
    var currentCIFilter: CIFilter? {
        CIFilter(name: currentFilter.ciFilterName)
    }
    
    // MARK: - Initializer
    init(videoURL: URL, filter: Filter = .none) {
        self.videoURL = videoURL
        self.currentFilter = filter
    }
    
    // MARK: - Configuration
    /// Configures the video player with the provided video URL and filter.
    func configure(with videoURL: URL, filter: Filter) async {
        let asset = AVAsset(url: videoURL)
        do {
            guard try await asset.load(.isPlayable) else { return }
            
            let item = await AVPlayerItem(asset: asset)
            let queuePlayer = AVQueuePlayer(playerItem: item)
            let looper = AVPlayerLooper(player: queuePlayer, templateItem: item)
            
            DispatchQueue.main.async {
                self.player = queuePlayer
                self.playerItem = item
                self.playerLooper = looper
                self.currentFilter = filter
                self.playVideoPreview()
            }
        } catch {
            print("Error loading asset: \(error)")
        }
    }
    
    // MARK: - Video Preview Control
    /// Plays the video preview.
    func playVideoPreview() {
        guard let player = player else { return }
        player.play()
    }
    
    /// Pauses the video preview.
    func pauseVideoPreview() {
        guard let player = player else { return }
        player.pause()
    }
    
    /// Applies a color filter and optional intensity to the video preview and resets the video player to play the newly filtered video preview.
    func updateVideoPreview(filter: Filter, intensity: Float? = nil) {
        self.currentFilter = filter
        guard let videoURL = videoURL else { return }
        
        let newAsset = AVAsset(url: videoURL)
        let newPlayerItem = AVPlayerItem(asset: newAsset)
        
        // Create a video composition that applies the color filter
        let videoComposition = AVVideoComposition(asset: newAsset) { request in
            var image = request.sourceImage.clampedToExtent()
            do {
                try applyColorFilter(to: &image, filter: filter, intensity: intensity)
            } catch {
                print("Error applying filter: \(error)")
            }
            image = image.cropped(to: request.sourceImage.extent)
            request.finish(with: image, context: nil)
        }
        
        DispatchQueue.main.async {
            newPlayerItem.videoComposition = videoComposition
            
            guard let player = self.player else { return }
            player.pause()
            player.replaceCurrentItem(with: newPlayerItem)
            
            // Reinitialize the looper with the new player item
            self.playerLooper = AVPlayerLooper(player: player, templateItem: newPlayerItem)
            self.playerItem = newPlayerItem
            
            // Restart playback from the beginning
            player.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero) { _ in
                player.play()
            }
        }
    }
}
