//
//  LibraryViewModel.swift
//  VideoVibes
//
//  Created by Tammy Ho.
//
//  View model responsible for managing the library grid screen.

import UIKit

class LibraryViewModel: ObservableObject {
    // MARK: - Properties
    weak var coordinator: LibraryCoordinatorProtocol?
    
    @Published var isPermissionDenied: Bool = false // Indicates if video library access is denied
    @Published var isFirstTime: Bool = true
    
    private let permissionService: PermissionService
    /// In-memory cache for thumbnails to avoid redundant disk reads.
    private var thumbnailCache: [URL: UIImage] = [:]
    
    // MARK: - Initializer
    init(coordinator: LibraryCoordinatorProtocol?) {
        self.coordinator = coordinator
        self.permissionService = coordinator?.permissionService ?? PermissionService() // Use default service if not provided
    }
    
    // MARK: - Public Methods
    /// Requests access to the video library and updates the permission state.
    func requestVideoLibraryAccessResult() {
        permissionService.requestVideoLibraryAccessResult { permissionResult in
            if permissionResult != .granted {
                self.isPermissionDenied = true
            }
            self.isFirstTime = false
        }
    }
    
    /// Loads all video URLs from the temporary directory and the app bundle.
    func loadAllVideoURLs() async -> [URL] {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self else {
                    continuation.resume(returning: [])
                    return
                }
                var videoURLs: [URL] = []
                videoURLs.append(contentsOf: self.loadTempVideoURLs())
                videoURLs.append(contentsOf: self.loadMovFilesFromBundle())
                continuation.resume(returning: videoURLs)
            }
        }
    }
    
    /// Fetches a cached thumbnail for the given video URL, if available.
    func fetchCachedThumbnail(for url: URL) -> UIImage? {
            return thumbnailCache[url]
        }

    /// Caches a thumbnail image for the given video URL.
    func cacheThumbnail(_ image: UIImage, for url: URL) {
        thumbnailCache[url] = image
    }
    
    /// Handles the selection of a video from the library by triggering navigation to the next screen.
    func didSelectVideo(_ videoURL: URL) {
        coordinator?.navigate(to: .filterVideo(videoURL: videoURL))
    }
    
    // MARK: - Private Helper Methods
    /// Loads all `.mov` files from the temporary directory.
    private func loadTempVideoURLs() -> [URL] {
        let tempDir = FileManager.default.temporaryDirectory
        do {
            let allFiles = try FileManager.default.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: nil)
            let movFiles = allFiles.filter { $0.pathExtension.lowercased() == "mov" }
            return movFiles
        } catch {
            print("Failed to list temp directory files: \(error)")
            return []
        }
    }
    
    /// Loads all `.mov` files from the app bundle.
    private func loadMovFilesFromBundle() -> [URL] {
        var urls: [URL] = []
        if let resourceURLs = Bundle.main.urls(forResourcesWithExtension: "mov", subdirectory: nil) {
            urls.append(contentsOf: resourceURLs)
        }
        return urls
    }
}


