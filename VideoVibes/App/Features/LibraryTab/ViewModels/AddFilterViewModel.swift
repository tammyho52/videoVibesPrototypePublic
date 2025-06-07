//
//  AddFilterViewModel.swift
//  VideoVibes
//
//  Created by Tammy Ho.
//
//  View model responsible for managing filter selection, intensity adjustments, and preview playback for a given video in the filter editor screen.

import Foundation
import AVFoundation

class AddFilterViewModel: ObservableObject {
    // MARK: - Properties
    weak var coordinator: LibraryCoordinatorProtocol?
    
    /// The URL of the video to be filtered.
    let videoURL: URL
    
    /// Service responsible for applying filters to the video preview.
    private let filterService: VideoFilterService
    private let defaultIntensity: Float = 1.0 // Default intensity value, can be adjusted as needed
    
    @Published var selectedFilter: Filter = .none
    @Published var showIntensity: Bool = false
    @Published var filterIntensity: Float
    @Published var isLoadingVideoPreview: Bool = true
    
    /// Exposes the AVPlayer for video preview playback.
    var videoPreviewPlayer: AVPlayer {
        return filterService.avPlayer ?? AVPlayer(url: videoURL)
    }
    
    // MARK: - Initializer
    init(coordinator: LibraryCoordinatorProtocol?, videoURL: URL) {
        self.coordinator = coordinator
        self.videoURL = videoURL
        self.filterService = VideoFilterService(videoURL: videoURL)
        self.filterIntensity = defaultIntensity
    }
    
    // MARK: - Methods
    /// Configures the video preview with the selected filter and loads the video.
    func configureVideoPreview() async {
        await filterService.configure(with: videoURL, filter: selectedFilter)
        self.isLoadingVideoPreview = false
    }
    
    /// Updates the selected filter and adjusts the intensity based on the filter update.
    func updateFilter(_ filter: Filter) {
        selectedFilter = filter
        showIntensity = filter.hasIntensity
        filterIntensity = defaultIntensity
    }
    
    /// Updates the intensity of the currently selected filter.
    func updateIntensity(_ intensity: Float) {
        filterIntensity = intensity
    }
    
    /// Updates the video preview with the currently selected filter and intensity.
    func updateVideoPreview() {
        let intensity = showIntensity ? filterIntensity : nil // Use nil if intensity is not applicable
        filterService.updateVideoPreview(filter: selectedFilter, intensity: intensity)
    }
    
    /// Resumes playback of the video preview.
    func resumeVideoPreview() {
        filterService.playVideoPreview()
    }
    
    /// Pauses the video preview playback.
    func pauseVideoPreview() {
        filterService.pauseVideoPreview()
    }
    
    /// Resets the view model to its initial state.
    func reset() {
        selectedFilter = .none
        showIntensity = false
        filterIntensity = defaultIntensity
        isLoadingVideoPreview = true
    }
}
