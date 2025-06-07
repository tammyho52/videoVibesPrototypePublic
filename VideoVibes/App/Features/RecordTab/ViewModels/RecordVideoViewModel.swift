//
//  RecordVideoViewModel.swift
//  VideoVibes
//
//  Created by Tammy Ho.
//
//  View Model responsible for managing the video recording screen.

import Foundation
import AVFoundation
import Combine
import UIKit

class RecordVideoViewModel: ObservableObject {
    
    // MARK: - Properties
    weak var coordinator: RecordCoordinatorProtocol?
    
    @Published var hasVideoRecordingPermission: Bool?
    @Published var isRecording: Bool = false
    @Published var recordingTimeLabel: String = "00:00"
    @Published var showTemporaryMessage: Bool = false
    
    private let permissionService: PermissionService
    private let videoRecordingService: VideoRecordingService
    var isFirstTime: Bool = true
    private var didStopRunningObserver: NSObjectProtocol? // Observer for session stop events
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return videoRecordingService.videoPreviewLayer
    }
    
    // MARK: - Initializer
    init(coordinator: RecordCoordinatorProtocol?) {
        self.coordinator = coordinator
        self.permissionService = coordinator?.permissionService ?? PermissionService() // Use default service if not provided
        self.videoRecordingService = coordinator?.videoRecordingService ?? VideoRecordingService()
        
        // Observe changes to recording timer
        videoRecordingService.$elapsedTime
            .map { $0.asTimeStamp() }
            .assign(to: &$recordingTimeLabel)
            
        
        // Set up video recording service callbacks
        videoRecordingService.onRecordingFinished = { _, _ in
            DispatchQueue.main.async {
                self.resetSession() // Assumes that user is ok with saving video to device
                self.showTemporaryMessage = true // Show temporary message after recording finishes
            }
        }
        
        videoRecordingService.onVideoSavingFinished = { _, _ in
            // Intentionally left empty for now, can be used to handle post-save actions
        }
        
        videoRecordingService.onError = { message in
            print("Video recording error: \(message)")
        }
        
        setDidStopRunningObserver() // Set up observer for session stop events
    }
    
    deinit {
        if let observer = didStopRunningObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    // MARK: - Permission Handling
    /// Requests video recording access and sets up the video recording session if granted.
    func requestVideoRecordingAccessResult() {
        permissionService.requestVideoRecordingAccessResult { [weak self] permissionResult in
            guard let self else { return }
            
            DispatchQueue.main.async {
                self.isFirstTime = false
                if permissionResult == .granted {
                    self.hasVideoRecordingPermission = true
                    self.setUpVideoRecordingService()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.startCaptureSession() // Start session if permission granted
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            if self.videoRecordingService.isCaptureSessionRunning {
                                self.startRecording()
                            } else {
                                print("Capture session not ready yet")
                            }
                        }
                    }
                } else {
                    self.hasVideoRecordingPermission = false
                }
            }
        }
    }
    
    /// Checks if the app has permission to record videos.
    func checkVideoRecordingPermission() {
        hasVideoRecordingPermission = permissionService.checkVideoRecordingAccess()
    }
    
    // MARK: - Capture Session Management
    /// Sets up the video recording service by initializing the capture session.
    func setUpVideoRecordingService() {
        do {
            try videoRecordingService.setupSession()
        } catch {
            print("Error setting up video recording service: \(error.localizedDescription)")
        }
    }
    
    /// Starts the capture session for video recording.
    func startCaptureSession() {
        videoRecordingService.startCaptureSession()
    }
    
    /// Stops the capture session for video recording.
    func stopCaptureSession() {
        videoRecordingService.stopCaptureSession()
    }
    
    /// Starts or resumes the video recording session.
    func startRecording() {
        isRecording = true
        videoRecordingService.startRecording()
    }
    
    /// Stops the video recording session.
    func stopRecording() {
        isRecording = false
        videoRecordingService.stopRecording()
    }
    
    /// Toggles the camera between front and back.
    func toggleCamera() {
        videoRecordingService.toggleCamera()
    }
    
    // MARK: - Cleanup
    /// Sets up an observer for when the capture session stops running.
    func setDidStopRunningObserver() {
        didStopRunningObserver = NotificationCenter.default.addObserver(
            forName: .AVCaptureSessionDidStopRunning,
            object: videoRecordingService.captureSessionObject,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            self.resetSession()
        }
    }
    
    /// Resets the recording session state.
    func resetSession() {
        isRecording = false
        recordingTimeLabel = "00:00"
    }
}
