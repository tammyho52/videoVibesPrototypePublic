//
//  LibraryCoordinator.swift
//  VideoVibes
//
//  Created by Tammy Ho.
//
//  Coordinates navigation flow for the Library tab.

import UIKit

final class LibraryCoordinator: BaseCoordinator, LibraryCoordinatorProtocol {
    // MARK: - Properties
    /// The service responsible for managing permissions.
    let permissionService: PermissionService
    
    // MARK: - Initializer
    init(navigationController: UINavigationController, permissionService: PermissionService) {
        self.permissionService = permissionService
        super.init(navigationController: navigationController)
    }
    
    // MARK: - Coordinator Lifecycle
    /// Starts the library tab flow by pushing the initial view controller onto the navigation stack.
    override func start() {
        let viewModel = LibraryViewModel(coordinator: self)
        let vc = LibraryViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: false)
    }
    
    // MARK: - Navigation
    /// Handles navigation to different destinations within the library tab.
    /// - Parameter destination: The destination to navigate to.
    func navigate(to destination: LibraryDestination) {
        switch destination {
        case .filterVideo(let videoURL):
            navigateToAddFilter(videoURL: videoURL)
        }
    }
    
    /// Pushes the AddFilterViewController onto the navigation stack with a custom transition.
    /// - Parameter videoURL: The URL of the video to be filtered.
    private func navigateToAddFilter(videoURL: URL) {
        let viewModel = AddFilterViewModel(coordinator: self, videoURL: videoURL)
        let addFilterVC = AddFilterViewController(viewModel: viewModel)
        addFilterVC.modalPresentationStyle = .fullScreen
        
        // Add a custom transition animation
        let transition = CATransition()
        transition.duration = 0.35
        transition.type = .push // .fade, .moveIn, etc.
        transition.subtype = .fromRight
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        navigationController.view.layer.add(transition, forKey: kCATransition)
        
        navigationController.pushViewControllerWithCustomTransition(addFilterVC)
    }
}
