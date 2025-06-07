//
//  SceneDelegate.swift
//  VideoVibes
//
//  Created by Tammy Ho.
//
//  Responsible for managing the app's scenes and lifecycle events.

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    /// Called when a scene is about to be connected to the app.
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Configure the initial window and root view controller
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = LandingViewController()
        window.makeKeyAndVisible()
        
        self.window = window
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        clearTemporaryDirectory() // Clear temporary files when the scene is disconnected.
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Intentionally left empty.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Intentionally left empty.
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Intentionally left empty.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        clearTemporaryDirectory() // Clear temporary files when the scene is disconnected.
    }
    
    /// Clears the temporary directory by removing all `.mov` files.
    private func clearTemporaryDirectory() {
        let tempDirectory = FileManager.default.temporaryDirectory
        do {
            let tempFiles = try FileManager.default.contentsOfDirectory(at: tempDirectory, includingPropertiesForKeys: nil)
            for file in tempFiles where file.pathExtension == "mov" {
                try? FileManager.default.removeItem(at: file)
            }
        } catch {
            print("Error clearing temporary directory: \(error.localizedDescription)")
        }
    }
}

