//
//  TabBarController.swift
//  VideoVibes
//
//  Created by Tammy Ho.
//
//  Manages the main tab bar interface for the app, coordinating between tabs.

import UIKit
import AVFoundation

class TabBarController: UITabBarController {
    // MARK: - Properties
    /// Service to manage permissions (camera, microphone, and photo library) across the app.
    let permissionService = PermissionService()
    let videoRecordingService = VideoRecordingService()
    
    /// Coordinators for managing the navigation stacks of each tab.
    private var libraryCoordinator: LibraryCoordinator! // Initialized in viewDidLoad
    private var recordCoordinator: RecordCoordinator! // Initialized in viewDidLoad
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Customize the tab bar appearance
        tabBar.tintColor = Theme.primaryColor
        tabBar.unselectedItemTintColor = UIColor.lightGray
        setupTabBarBackground()
        
        // Set up the tab bar with its view controllers
        setupTabBar()
        observeAppLifecycle()
    }
    
    // MARK: - Setup Methods
    /// Sets up the tab bar with the necessary view controllers for each tab.
    private func setupTabBar() {
        // Create coordinators for each tab with their own navigation controllers
        libraryCoordinator = LibraryCoordinator(
            navigationController: UINavigationController(),
            permissionService: permissionService
        )
        recordCoordinator = RecordCoordinator(
            navigationController: UINavigationController(),
            permissionService: permissionService,
            videoRecordingService: videoRecordingService
        )
        
        libraryCoordinator.start()
        recordCoordinator.start()
        
        let libraryNav = libraryCoordinator.navigationController
        let recordNav = recordCoordinator.navigationController
        
        // Configure the tab bar items for each navigation controller
        libraryNav.tabBarItem = UITabBarItem(
            title: "Library",
            image: UIImage(systemName: "rectangle.grid.2x2"),
            selectedImage: UIImage(systemName: "rectangle.grid.2x2.fill")
        )
        libraryNav.tabBarItem.tag = 0
        
        recordNav.tabBarItem = UITabBarItem(
            title: "Record",
            image: UIImage(systemName: "video"),
            selectedImage: UIImage(systemName: "video.fill")
        )
        recordNav.tabBarItem.tag = 1
        
        // Assign the view controllers to the tab bar
        self.viewControllers = [libraryNav, recordNav]
    }
    
    /// Sets up the appearance of the tab bar background.
    private func setupTabBarBackground() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        
        // Background is set to a subtle dark blur effect
        appearance.backgroundColor = UIColor.darkGray.withAlphaComponent(0.1)
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        
        tabBar.standardAppearance = appearance
        
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }
    
    /// Observes app lifecycle events to handle session cleanup.
    private func observeAppLifecycle() {
        // Observer for app background
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSessionCleanup),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )

        // Observer for app termination
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSessionCleanup),
            name: UIApplication.willTerminateNotification,
            object: nil
        )

        // Observer for audio session interruptions
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSessionCleanup),
            name: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance()
        )
    }
    
    // MARK: - Cleanup Methods
    @objc private func handleSessionCleanup() {
        self.videoRecordingService.resetRecordingSession()
    }
}
