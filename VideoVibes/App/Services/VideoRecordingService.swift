//
//  VideoRecordingService.swift
//  VideoVibes
//
//  Created by Tammy Ho.
//
//  Service that manages video recording functionality.

import AVFoundation
import Photos

class VideoRecordingService: NSObject, ObservableObject {
    // MARK: - Properties
    @Published var elapsedTime: TimeInterval = 0
    
    private var timer: Timer?
    private var startTime: Date?
    
    private let captureSession = AVCaptureSession()
    private var videoDeviceInput: AVCaptureDeviceInput?
    private let movieFileOutput = AVCaptureMovieFileOutput()
    
    private var isUsingBackCamera = true
    private var lastRecordedURL: URL?
    
    // MARK: - Computed Properties
    var isCaptureSessionRunning: Bool {
        return captureSession.isRunning
    }
    
    var isRecording: Bool {
        return movieFileOutput.isRecording
    }
    
    var captureSessionObject: AVCaptureSession {
        return captureSession
    }
    
    /// The video preview layer for displaying the camera feed.
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        return AVCaptureVideoPreviewLayer(session: captureSession)
    }()
    
    /// Exposes the video preview layer for use in the UI.
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return previewLayer
    }
    
    // MARK: - Callbacks
    var onRecordingFinished: ((URL?, Error?) -> Void)?
    var onVideoSavingFinished: ((URL?, Error?) -> Void)?
    var onError: ((String) -> Void)?
    
    // MARK: - Initializer
    override init() {
        super.init()
    }
    
    // MARK: - Setup Methods
    /// Initializes the video recording service and sets up the capture session.
    func setupSession() throws {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .high
        
        // Video input
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: isUsingBackCamera ? .back : .front),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
              captureSession.canAddInput(videoInput) else {
            throw AppError.videoProcessingError(message: "Unable to add video device input.")
        }
        captureSession.addInput(videoInput)
        videoDeviceInput = videoInput
        
        // Audio input
        guard let audioDevice = AVCaptureDevice.default(for: .audio),
              let audioInput = try? AVCaptureDeviceInput(device: audioDevice),
              captureSession.canAddInput(audioInput) else {
            throw AppError.videoProcessingError(message: "Unable to add audio device input.")
        }
        captureSession.addInput(audioInput)
        
        // File output
        guard captureSession.canAddOutput(movieFileOutput) else {
            throw AppError.videoProcessingError(message: "Unable to add movie file output.")
        }
        captureSession.addOutput(movieFileOutput)
        
        captureSession.commitConfiguration()
    }
    
    // MARK: - Capture Session Management
    /// Starts the capture session.
    func startCaptureSession() {
        guard !captureSession.isRunning else {
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
    
    /// Stops the capture session if it is currently running.
    func stopCaptureSession() {
        if captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.stopRunning()
            }
        }
    }
    
    /// Starts video recording to a temporary file.
    func startRecording() {
        if movieFileOutput.isRecording {
            stopRecording()
        }
        
        let outputURL = tempURL()
        lastRecordedURL = outputURL // Store the URL for later use
        movieFileOutput.startRecording(to: outputURL, recordingDelegate: self)

        startTimer()
    }
    
    /// Stops the current video recording.
    func stopRecording() {
        if movieFileOutput.isRecording {
            movieFileOutput.stopRecording()
            stopTimer()
        }
    }
    
    /// Starts a timer to track the elapsed recording time.
    private func startTimer() {
        startTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let startTime = self?.startTime else { return }
            self?.elapsedTime = Date().timeIntervalSince(startTime)
        }
    }
    
    /// Stops the timer that tracks the elapsed recording time.
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        startTime = nil
        elapsedTime = 0
    }
    
    /// Returns a temporary file URL for video recording.
    private func tempURL() -> URL {
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileName = UUID().uuidString + ".mov"
        return tempDirectory.appendingPathComponent(fileName)
    }
    
    /// Switches the camera between front and back.
    func toggleCamera() {
        isUsingBackCamera.toggle()
    }
    
    /// Resets the recording session, stopping any ongoing recording and clearing the last recorded URL.
    func resetRecordingSession() {
        /// Stops the current recording and resets the session.
        if movieFileOutput.isRecording {
            stopRecording()
        }
        
        /// Resets the last recorded URL
        resetOutputURL()
    }
    
    /// Cleans up the capture session by stopping it and removing all inputs and outputs.
    func cleanupCaptureSession() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
        
        for input in captureSession.inputs {
            captureSession.removeInput(input)
        }
        
        for output in captureSession.outputs {
            captureSession.removeOutput(output)
        }
    }
    
    /// Resets the last recorded URL to nil.
    private func resetOutputURL() {
        lastRecordedURL = nil
    }
    
    /// Saves the recorded video to the photo library.
    func saveVideoToLibrary(url: URL, completion: @escaping (Bool, Error?) -> Void) {
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        } completionHandler: { success, error in
            DispatchQueue.main.async {
                if success {
                    self.onVideoSavingFinished?(url, nil)
                } else {
                    self.onError?("Failed to save video to photo library: \(error?.localizedDescription ?? "Failed to save video")")
                    self.onVideoSavingFinished?(nil, error)
                }
            }
        }
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate
extension VideoRecordingService: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput,
                    didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection],
                    error: Error?) {
        if let error = error {
            onError?("Recording failed: \(error.localizedDescription)")
            onRecordingFinished?(nil, error)
            return
        }
        
        DispatchQueue.main.async {
            self.onRecordingFinished?(outputFileURL, nil)
        }
    }
}
