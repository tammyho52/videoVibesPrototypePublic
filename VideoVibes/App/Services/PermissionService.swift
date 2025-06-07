//
//  PermissionService.swift
//  VideoVibes
//
//  Created by Tammy Ho.
//
//  Manages permissions for camera, microphone, and photo library access.

import AVFoundation
import Photos

final class PermissionService {
    // MARK: - Permission Status Check Methods
    /// Checks if the app can access the photo library.
    func canAccessPhotoLibrary() -> Bool {
        isPhotoLibraryPermissionGranted()
    }
    
    /// Checks if the app can access the camera.
    func checkVideoLibraryAccess() -> Bool {
        isPhotoLibraryPermissionGranted()
    }
    
    /// Checks if the app can record video with all necessary permissions.
    func checkVideoRecordingAccess() -> Bool {
        isCameraPermissionGranted() && isMicrophonePermissionGranted() && isPhotoLibraryPermissionGranted()
    }
    
    /// Checks if the necessary permissions for video recording are granted.
    private func isCameraPermissionGranted() -> Bool {
        AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }
    
    /// Checks if the necessary permissions for microphone access are granted.
    private func isMicrophonePermissionGranted() -> Bool {
        AVCaptureDevice.authorizationStatus(for: .audio) == .authorized
    }
    
    /// Checks if the necessary permissions for photo library access are granted.
    private func isPhotoLibraryPermissionGranted() -> Bool {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        return status == .authorized || status == .limited
    }
    
    // MARK: - Permission Request Methods
    /// Requests access for video library access.
    func requestVideoLibraryAccessResult(completion: @escaping (PermissionResult) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .authorized, .limited:
            completion(.granted)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    switch newStatus {
                    case .authorized, .limited:
                        completion(.granted)
                    case .denied, .restricted:
                        completion(.denied([.photoLibrary]))
                    default:
                        completion(.denied([.photoLibrary]))
                    }
                }
            }
        case .denied, .restricted:
            completion(.denied([.photoLibrary]))
        default:
            completion(.denied([.photoLibrary]))
        }
    }
    
    /// Requests access for video recording.
    func requestVideoRecordingAccessResult(completion: @escaping (PermissionResult) -> Void) {
        var permissionResults: [PermissionType] = []
        
        requestCameraAccessResult { cameraResult in
            if cameraResult != .granted {
                permissionResults.append(.camera)
            }
            
            self.requestMicrophoneAccessResult { microphoneResult in
                if microphoneResult != .granted {
                    permissionResults.append(.microphone)
                }
                
                self.requestPhotoLibraryAccessResult { photoLibraryResult in
                    if photoLibraryResult != .granted {
                        permissionResults.append(.photoLibrary)
                    }
                    
                    /// Now we have all permission results, we can determine the final result.
                    if permissionResults.isEmpty {
                        completion(.granted)
                    } else {
                        completion(.denied(permissionResults))
                    }
                }
            }
        }
    }
    
    /// Checks if the app has permission to access photo library before requesting access.
    private func requestPhotoLibraryAccessResult(completion: @escaping (PermissionResult) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .authorized, .limited:
            completion(.granted)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    switch newStatus {
                    case .authorized, .limited:
                        completion(.granted)
                    case .denied, .restricted:
                        completion(.denied([.photoLibrary]))
                    default:
                        completion(.denied([.photoLibrary]))
                    }
                }
            }
        case .denied, .restricted:
            completion(.denied([.photoLibrary]))
        default:
            completion(.denied([.photoLibrary]))
        }
    }
    
    /// Requests access to the camera.
    private func requestCameraAccessResult(completion: @escaping (PermissionResult) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            completion(.granted)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted ? .granted : .denied([.camera]))
                }
            }
        case .denied, .restricted:
            completion(.denied([.camera]))
        default:
            completion(.denied([.camera]))
        }
    }
    
    /// Requests access to the microphone.
    private func requestMicrophoneAccessResult(completion: @escaping (PermissionResult) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        switch status {
        case .authorized:
            completion(.granted)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                DispatchQueue.main.async {
                    completion(granted ? .granted : .denied([.microphone]))
                }
            }
        case .denied, .restricted:
            completion(.denied([.microphone]))
        default:
            completion(.denied([.microphone]))
        }
    }
}
