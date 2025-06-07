//
//  AddFilterViewController.swift
//  VideoVibes
//
//  Created by Tammy Ho.
//
//  View controller to apply filters to a selected video and preview changes in real time.

import UIKit
import AVFoundation
import Combine

final class AddFilterViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: AddFilterViewModel
    private var playerLayer: AVPlayerLayer?
    private var cancellables = Set<AnyCancellable>()
    private var filterButtons: [FilterButtonView] = []
    private var isFirstLoad: Bool = true
    
    // MARK: - Initializers
    init(viewModel: AddFilterViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupExportButton()
        setNavBarWithLogo()
        setupViews()
        setupBindings()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = videoPreviewView.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadingSpinner.startAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirstLoad {
            configureAndShowVideoPreview()
            isFirstLoad = false
        } else {
            viewModel.resumeVideoPreview()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.pauseVideoPreview()
    }
    
    // MARK: - Setup Methods
    /// Sets up the main layout stack.
    func setupViews() {
        let contentStack = UIStackView(arrangedSubviews: [videoPreviewView, videoFilterEditStackView])
        contentStack.axis = .vertical
        contentStack.spacing = 10
        contentStack.distribution = .fill
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
        
        videoPreviewView.setContentHuggingPriority(.defaultLow, for: .vertical)
        videoPreviewView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        videoFilterEditStackView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        loadingSpinner.centerXAnchor.constraint(equalTo: videoPreviewView.centerXAnchor).isActive = true
        loadingSpinner.centerYAnchor.constraint(equalTo: videoPreviewView.centerYAnchor).isActive = true
    }
    
    /// Sets up the export button in the navigation bar.
    private func setupExportButton() {
        let exportImage = UIImage(systemName: "square.and.arrow.up")
        let exportButton = UIBarButtonItem(
            image: exportImage,
            style: .plain,
            target: self,
            action: #selector(exportButtonTapped)
        )
        exportButton.tintColor = Theme.primaryColor
        navigationItem.rightBarButtonItem = exportButton
    }
    
    // MARK: - UI Components
    /// A stack view containing the filter editing controls, including intensity slider and filter buttons.
    private lazy var videoFilterEditStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [intensitySlider, filtersSectionView])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    /// A horizontal stack view containing buttons for each filter.
    private lazy var filtersSectionView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 7.5
        stackView.distribution = .fillEqually
        
        for filter in Filter.allCases {
            let isSelectedFilter = viewModel.selectedFilter == filter
            let button = FilterButtonView(filter: filter, isSelectedFilter: isSelectedFilter)
            button.addTarget(self, action: #selector(filterButtonTapped(_:)), for: .touchUpInside)
            filterButtons.append(button)
            
            let label = UILabel()
            label.text = filter.displayName
            label.font = AppFont.caption
            
            let stack = UIStackView(arrangedSubviews: [button, label])
            stack.axis = .vertical
            stack.alignment = .center
            stack.spacing = 5
            stack.translatesAutoresizingMaskIntoConstraints = false
            
            stackView.addArrangedSubview(stack)
        }
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    /// A slider to adjust the intensity of the selected filter, shown only if the selected filter supports intensity.
    private lazy var intensitySlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1.0
        slider.value = viewModel.filterIntensity
        slider.minimumTrackTintColor = Theme.primaryColor
        slider.maximumTrackTintColor = .lightGray
        slider.thumbTintColor = Theme.primaryColor
        slider.alpha = viewModel.showIntensity ? 1 : 0 // Initially hidden if filter does not support intensity
        
        let sizeConfiguration = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
        if let thumbImage = UIImage(systemName: "swirl.circle.righthalf.filled")?
            .withConfiguration(sizeConfiguration)
            .withTintColor(Theme.primaryColor)
            .withRenderingMode(.alwaysOriginal) {
            slider.setThumbImage(thumbImage, for: .normal)
            slider.setThumbImage(thumbImage, for: .highlighted)
        }
        
        slider.addTarget(self, action: #selector(intensitySliderDragEnded(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel]) // Avoid using valueChanged for performance to prevent continuous updates
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    /// A view that contains the video preview layer and loading spinner.
    private lazy var videoPreviewView: UIView = {
        let container = UIView()
        container.layer.cornerRadius = 20
        container.clipsToBounds = true
        container.addSubview(loadingSpinner)
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    /// A spinner that indicates loading state when the video preview is being configured.
    private lazy var loadingSpinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    // MARK: - Video Preview Methods
    /// Configures the video preview by setting up the player layer and transitioning from the loading spinner to the video preview.
    private func configureAndShowVideoPreview() {
        Task.detached { [weak self] in
            guard let self else { return }
            await self.viewModel.configureVideoPreview()
            await MainActor.run {
                self.addPlayerLayer()
                self.loadingSpinner.isHidden = true
                self.loadingSpinner.stopAnimating()
            }
        }
    }
    
    /// Adds the player layer to the video preview view, removing any existing player layer.
    private func addPlayerLayer() {
        playerLayer?.removeFromSuperlayer()
        
        playerLayer = AVPlayerLayer(player: viewModel.videoPreviewPlayer)
        playerLayer?.videoGravity = .resizeAspect
        playerLayer?.frame = videoPreviewView.bounds
        
        if let playerLayer {
            videoPreviewView.layer.addSublayer(playerLayer)
        }
    }
    
    /// Updates the filter buttons to reflect the currently selected filter.
    private func updateFilterButtons(for filter: Filter) {
        for button in filterButtons {
            button.isSelectedFilter = button.filter == filter
        }
    }
    
    // MARK: - Bindings
    private func setupBindings() {
        viewModel.$selectedFilter
            .receive(on: DispatchQueue.main)
            .sink { [weak self] filter in
                self?.updateFilterButtons(for: filter)
            }
            .store(in: &cancellables)
        
        viewModel.$filterIntensity
            .receive(on: DispatchQueue.main)
            .sink { [weak self] intensity in
                self?.intensitySlider.value = intensity
            }
            .store(in: &cancellables)
        
        viewModel.$isLoadingVideoPreview
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.loadingSpinner.startAnimating()
                    self?.loadingSpinner.isHidden = false
                } else {
                    self?.loadingSpinner.stopAnimating()
                    self?.loadingSpinner.isHidden = true
                }
            }
            .store(in: &cancellables)
        
        viewModel.$showIntensity
            .receive(on: DispatchQueue.main)
            .sink { [weak self] showIntensity in
                UIView.animate(withDuration: 0.3) {
                    self?.intensitySlider.alpha = showIntensity ? 1 : 0
                    self?.intensitySlider.isUserInteractionEnabled = showIntensity
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    /// Updates filter border to indicate selection and refreshes the video preview to apply the filter when a filter button is tapped.
    @objc private func filterButtonTapped(_ sender: FilterButtonView) {
        viewModel.updateFilter(sender.filter)
        viewModel.updateVideoPreview()
    }
    
    /// Handles the end of dragging the intensity slider, updating the filter intensity and refreshing the video preview.
    @objc private func intensitySliderDragEnded(_ sender: UISlider) {
        viewModel.filterIntensity = sender.value
        viewModel.updateVideoPreview()
    }
    
    /// Placeholder export button action with temporary message
    @objc private func exportButtonTapped() {
        let messageLabel = UILabel()
        messageLabel.text = "Export functionality has not been implemented yet. Please check back later."
        messageLabel.textAlignment = .center
        messageLabel.layer.cornerRadius = 10
        messageLabel.clipsToBounds = true
        messageLabel.backgroundColor = .lightGray.withAlphaComponent(0.8)
        messageLabel.font = AppFont.body
        messageLabel.numberOfLines = 0
        messageLabel.alpha = 0 // Start hidden
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(messageLabel)
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
        
        // Animate the message label to fade in and out with a delay
        UIView.animate(withDuration: 0.3, animations: {
            messageLabel.alpha = 1
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                UIView.animate(withDuration: 0.3, animations: {
                    messageLabel.alpha = 0
                }) { _ in
                    messageLabel.removeFromSuperview()
                }
            }
        }
    }
}

// MARK: - Preview
#if DEBUG
import SwiftUI

#Preview {
    let libraryCoordinator = LibraryCoordinator(navigationController: UINavigationController(), permissionService: PermissionService())
    let videoURL = Bundle.main.url(forResource: "Video1", withExtension: "mov")!
    
    UIViewControllerPreview {
        UINavigationController(rootViewController:
            AddFilterViewController(
                viewModel: AddFilterViewModel(
                    coordinator: libraryCoordinator,
                    videoURL: videoURL
                )
            )
        )
    }
    .edgesIgnoringSafeArea(.all)
}

#endif
