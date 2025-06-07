//
//  RecordViewController.swift
//  VideoVibes
//
//  Created by Tammy Ho.
//
//  View controller responsible for recording video, displaying a preview, and managing the recording session.

import UIKit
import AVFoundation
import Combine

class RecordVideoViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: RecordVideoViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var isFirstLoad: Bool = true
    
    // MARK: - Initializers
    init(viewModel: RecordVideoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavBarWithLogo()
        setupViews()
        setupBindings()
        setupPreviewLayer()
        setupTimerLayer()
        setupTemporaryMessage()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = previewView.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if viewModel.hasVideoRecordingPermission == true {
            viewModel.startCaptureSession()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stopCaptureSession()
        viewModel.resetSession()
    }
    
    // MARK: - Setup Methods
    private func setupViews() {
        view.addSubview(previewView)
        previewView.addSubview(placeholderImageView)
        view.addSubview(recordButton)
        
        NSLayoutConstraint.activate([
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            recordButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            recordButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        NSLayoutConstraint.activate([
            placeholderImageView.centerXAnchor.constraint(equalTo: previewView.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: previewView.centerYAnchor),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 120),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 120)
        ])
        
        NSLayoutConstraint.activate([
            previewView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            previewView.bottomAnchor.constraint(equalTo: recordButton.topAnchor, constant: -20)
        ])
        
        recordButton.addTarget(self, action: #selector(didTapRecord), for: .touchUpInside)
    }
    
    /// Sets up the video preview layer to display the camera feed.
    private func setupPreviewLayer() {
        self.previewLayer = viewModel.videoPreviewLayer
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.cornerRadius = 20
        previewLayer?.frame = previewView.bounds
        previewLayer?.masksToBounds = true
        if let previewLayer {
            previewView.layer.addSublayer(previewLayer)
        }
    }
    
    /// Sets up the timer label to display the recording duration.
    private func setupTimerLayer() {
        previewView.addSubview(timerLabel)
        
        NSLayoutConstraint.activate([
            timerLabel.bottomAnchor.constraint(equalTo: previewView.bottomAnchor, constant: -20),
            timerLabel.trailingAnchor.constraint(equalTo: previewView.trailingAnchor, constant: -20)
        ])
    }
    
    /// Sets up the temporary message label that appears after recording a video.
    private func setupTemporaryMessage() {
        view.addSubview(temporaryMessageLabel)
        
        NSLayoutConstraint.activate([
            temporaryMessageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            temporaryMessageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            temporaryMessageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            temporaryMessageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
    
    // MARK: - UI Components
    /// A button to start or stop video recording.
    private lazy var recordButton: UIButton = {
        let button = UIButton(type: .system)
        let recordImage = UIImage(systemName: "video.fill")
        
        var configuration = UIButton.Configuration.filled()
        
        let title = "Record"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: AppFont.boldBody,
            .foregroundColor: Theme.primaryColor
        ]
        configuration.attributedTitle = AttributedString(NSAttributedString(string: title, attributes: attributes))
        configuration.image = recordImage
        configuration.imagePadding = 10
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        configuration.buttonSize = .large
        configuration.baseForegroundColor = Theme.primaryColor
        configuration.background.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        configuration.background.cornerRadius = 20
        
        button.configuration = configuration
        
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    /// A label that informs the user about permission requirements when access is denied.
    private lazy var permissionDeniedLabel: UILabel = {
        let label = UILabel()
        label.text = "Camera, Microphone, and Photo Library access are required to record and save videos. Please enable these permissions in Settings."
        label.textAlignment = .center
        label.font = AppFont.body
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// A view that displays the camera preview.
    private lazy var previewView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.layer.backgroundColor = UIColor.white.withAlphaComponent(0.1).cgColor
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// A placeholder image view that displays an icon when no video is being recorded.
    private let placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "camera.fill")
        imageView.tintColor = .lightGray
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    /// A label that displays the recording timer.
    private lazy var timerLabel: UILabel = {
        let label = UILabel()
        label.text = viewModel.recordingTimeLabel
        label.font = AppFont.subtitle
        label.isHidden = true // Initially hidden until recording starts
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// A temporary message label that appears briefly after recording a video.
    private lazy var temporaryMessageLabel: UILabel = {
        let message: String = "Recorded video has been saved to Library."
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.textAlignment = .center
        messageLabel.backgroundColor = .lightGray.withAlphaComponent(0.8)
        messageLabel.font = AppFont.subtitle
        messageLabel.layer.cornerRadius = 10
        messageLabel.clipsToBounds = true
        messageLabel.numberOfLines = 0
        messageLabel.alpha = 0 // Start hidden
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return messageLabel
    }()
    
    // MARK: - UI Update Methods
    /// Updates the record button's image and title based on the recording state.
    private func updateRecordButtonImage(isRecording: Bool) {
        let newRecordButtonImage = UIImage(systemName: isRecording ? "stop.fill" : "video.fill")
        UIView.transition(with: recordButton,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: {
                            if var attributedTitle = self.recordButton.configuration?.attributedTitle {
                                if let firstRun = attributedTitle.runs.first {
                                    let title = isRecording ? "Stop" : "Record"
                                    attributedTitle = AttributedString(title, attributes: firstRun.attributes)
                                    self.recordButton.configuration?.attributedTitle = attributedTitle
                                }
                            }
            
                            self.recordButton.configuration?.image = newRecordButtonImage
                          },
                          completion: nil
        )
    }
    
    /// Shows or hides the permission denied view based on the camera access status.
    private func showPermissionDeniedView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.previewView.alpha = 0
            self.recordButton.alpha = 0
        }) { _ in
            // Add and fade in the permission denied label
            if self.permissionDeniedLabel.superview == nil {
                self.view.addSubview(self.permissionDeniedLabel)
                NSLayoutConstraint.activate([
                    self.permissionDeniedLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                    self.permissionDeniedLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
                    self.permissionDeniedLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
                    self.permissionDeniedLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20)
                ])
                self.permissionDeniedLabel.alpha = 0
                UIView.animate(withDuration: 0.3) {
                    self.permissionDeniedLabel.alpha = 1
                }
            }
        }
    }
    
    /// Hides the permission denied view and shows the preview and record button views.
    private func hidePermissionDeniedView() {
        UIView.animate(withDuration: 0.3, animations: {
            // Remove the permission denied label
            self.permissionDeniedLabel.alpha = 0
        }) { _ in
            // Ensure the label is removed from the view hierarchy
            self.permissionDeniedLabel.removeFromSuperview()
            
            // Add and fade in the core preview and record button views
            UIView.animate(withDuration: 0.3) {
                self.previewView.alpha = 1
                self.recordButton.alpha = 1
            }
        }
    }
    
    /// Displays a temporary message when the recording finishes.
    private func showTemporaryMessage() {
        let duration: TimeInterval = 1.0
        
        UIView.animate(withDuration: 0.3, animations: {
            self.temporaryMessageLabel.alpha = 1
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                UIView.animate(withDuration: 0.3, animations: {
                    self.temporaryMessageLabel.alpha = 0
                }) { _ in
                    self.viewModel.showTemporaryMessage = false // Reset the flag after showing the message
                }
            }
        }
    }
    
    // MARK: - Recording Methods
    /// Checks if the app has permission to record videos and starts recording if granted.
    func checkPermissionAndStartRecording() {
        if viewModel.isFirstTime {
            viewModel.requestVideoRecordingAccessResult()
        } else {
            viewModel.checkVideoRecordingPermission()
        }
        
        if viewModel.hasVideoRecordingPermission == true {
            startRecording()
        }
    }
    
    /// Starts the video recording session.
    private func startRecording() {
        viewModel.startRecording()
    }
    
    /// Stops the video recording session.
    private func stopRecording() {
        viewModel.stopRecording()
    }
    
    // MARK: - Actions
    /// Handles the record button tap action to start or stop video recording.
    @objc private func didTapRecord() {
        if !viewModel.isRecording {
            checkPermissionAndStartRecording()
        } else {
            stopRecording()
        }
    }
    
    // MARK: - Bindings
    /// Sets up Combine bindings to observe changes in the view model and update the UI accordingly.
    func setupBindings() {
        viewModel.$hasVideoRecordingPermission
            .receive(on: DispatchQueue.main)
            .sink { [weak self] hasPermission in
                if hasPermission != false {
                    self?.hidePermissionDeniedView()
                } else {
                    self?.showPermissionDeniedView()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$isRecording
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isRecording in
                self?.updateRecordButtonImage(isRecording: isRecording)
                self?.previewLayer?.isHidden = !isRecording
                self?.timerLabel.isHidden = !isRecording
            }
            .store(in: &cancellables)
        
        viewModel.$recordingTimeLabel
            .receive(on: DispatchQueue.main)
            .sink { [weak self] timerLabelText in
                self?.timerLabel.text = timerLabelText
            }
            .store(in: &cancellables)
        
        viewModel.$showTemporaryMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] showMessage in
                if showMessage {
                    self?.showTemporaryMessage()
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Preview
#if DEBUG
import SwiftUI

#Preview {
    UINavigationController(rootViewController:
        RecordVideoViewController(
            viewModel: RecordVideoViewModel(
                coordinator: RecordCoordinator(
                    navigationController: UINavigationController(),
                    permissionService: PermissionService(),
                    videoRecordingService: VideoRecordingService()
                )
            )
        )
    )
}
#endif
