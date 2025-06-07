//
//  RecordCoordinator.swift
//  VideoVibes
//
//  Created by Tammy Ho.
//
//  Coordinates navigation flow for the Record tab.

import UIKit

final class RecordCoordinator: BaseCoordinator, RecordCoordinatorProtocol {
    // MARK: - Properties
    let permissionService: PermissionService
    let videoRecordingService: VideoRecordingService
    
    // MARK: - Initializer
    init(navigationController: UINavigationController, permissionService: PermissionService, videoRecordingService: VideoRecordingService) {
        self.permissionService = permissionService
        self.videoRecordingService = videoRecordingService
        super.init(navigationController: navigationController)
    }
    
    // MARK: - Coordinator Lifecycle
    override func start() {
        let viewModel = RecordVideoViewModel(coordinator: self)
        let vc = RecordVideoViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: false)
    }
    
    // MARK: - Navigation
    /// Handles navigation to different destinations within the record tab.
    func navigate(to destination: RecordDestination) {
        // No destinations defined yet
    }
}
