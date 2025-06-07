//
//  AppDelegate.swift
//  VideoVibes
//
//  Created by Tammy Ho.
//
//  Serves as the entry point for the application, configuring global settings such as the appearance of the navigation bar.

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    /// Called when the application has finished launching.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure global navigation bar appearance for the app
        let navBarAppearance = UINavigationBar.appearance()
        navBarAppearance.tintColor = Theme.primaryColor

        // Customize the back button appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        appearance.setBackIndicatorImage(
            UIImage(systemName: "chevron.backward"),
            transitionMaskImage: UIImage(systemName: "chevron.backward")
        )

        // Apply the appearance to all navigation bars
        navBarAppearance.standardAppearance = appearance
        navBarAppearance.scrollEdgeAppearance = appearance
        navBarAppearance.compactAppearance = appearance
        
        return true
    }

    // MARK: UISceneSession Lifecycle
    /// Called when a new scene session is being created.
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    /// Called when a scene session is discarded.
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Intentionally left empty.
    }
}

