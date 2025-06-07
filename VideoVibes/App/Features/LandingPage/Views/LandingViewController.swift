//
//  ViewController.swift
//  VideoVibes
//
//  Created by Tammy Ho.
//
//  Shows the app's landing page with an animated hexagon logo and title then transitions to the main tab bar interface.

import UIKit

class LandingViewController: UIViewController {
    // MARK: - UI Components
    /// Hexagon logo view that animates.
    private let hexagonLogoView = HexagonLogoView(shouldAnimate: true)
    
    /// Title label displaying the app name with a shadow effect.
    private let titleLabel: UILabel = {
        let label = UILabel()
        
        // Sets a subtle shadow effect for the title
        let shadow = NSShadow()
        shadow.shadowColor = Theme.primaryColor.withAlphaComponent(0.8)
        shadow.shadowOffset = CGSize(width: 0, height: 3)
        shadow.shadowBlurRadius = 2

        let attributes: [NSAttributedString.Key: Any] = [
            .shadow: shadow,
            .font: UIFont(name: "AvenirNext-Bold", size: 48) ?? UIFont.boldSystemFont(ofSize: 48),
        ]

        // Configure the label with the app name and attributes
        label.attributedText = NSAttributedString(string: "VideoVibes", attributes: attributes)
        label.alpha = 0 // Initially hidden
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    /// Stack view that contains the title label and hexagon logo view.
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, hexagonLogoView])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupHexagonLogo()
        setupStackView()
        
        // Animate fade in of the hexagon logo and title label
        toggleVisibility(true)
        
        // After a delay,fade out the logo and title label and transition to the main app
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.toggleVisibility(false)
        }
    }
    
    // MARK: - Setup Methods
    /// Sets up the hexagon logo view
    private func setupHexagonLogo() {
        hexagonLogoView.alpha = 0
        hexagonLogoView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hexagonLogoView.widthAnchor.constraint(equalToConstant: 150),
            hexagonLogoView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    /// Sets up the stack view containing the title label and hexagon logo view
    private func setupStackView() {
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
        
    // MARK: - Animation Methods
    /// Toggles the visibility of the title label and hexagon logo view with a fade animation.
    private func toggleVisibility(_ isVisible: Bool) {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 2,
            delay: 0.25,
            options: .curveEaseOut,
            animations: {
                self.titleLabel.alpha = isVisible ? 1.0 : 0.0
                self.hexagonLogoView.alpha = isVisible ? 1.0 : 0.0
            },
            completion: { position in
                if position == .end && !isVisible {
                    self.transitionToMainApp()
                }
            }
        )
    }
    
    // MARK: - Navigation Methods
    /// Transitions to the main app's tab bar interface with a flip animation.
    private func transitionToMainApp() {
        let tabBarController = TabBarController()
        
        // Find the active window scene and perform the transition
        if let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
            
            UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromRight) {
                window.rootViewController = tabBarController
            }
        }
    }
}

// MARK: - Preview
#if DEBUG
import SwiftUI

#Preview {
    UIViewControllerPreview {
        LandingViewController()
    }
    .edgesIgnoringSafeArea(.all)
    .preferredColorScheme(.dark)
}
#endif
