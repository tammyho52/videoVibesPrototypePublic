//
//  BaseCoordinator.swift
//  VideoVibes
//
//  Created by Tammy Ho.
//
//  Base class for coordinators in the app.

import UIKit

class BaseCoordinator: Coordinator {
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    /// Starts the coordinator's flow.
    func start() {
        // Default implementation does nothing - will be overridden by subclasses
    }
    
    /// Dismisses the current view controller and removes the last child coordinator.
    func popViewController(removeLastChildCoordinator: Bool = false) {
        guard navigationController.viewControllers.count > 1 else { return }
        navigationController.popViewController(animated: true)
        
        // Remove the last child coordinator, assuming it corresponds to the screen that was dismissed
        if removeLastChildCoordinator && !childCoordinators.isEmpty {
            childCoordinators.removeLast()
        }
    }
    
    /// Pops all view controllers on the navigation stack except the root view controller and removes child coordinators.
    func popToRoot() {
        navigationController.popToRootViewController(animated: true)
        childCoordinators.removeAll()
    }
}

