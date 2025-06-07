//
//  UIViewController+NavBarLogo.swift
//  VideoVibes
//
//  Created by Tammy Ho.
//

import UIKit

extension UIViewController {
    /// Sets the navigation bar with the app logo centered.
    func setNavBarWithLogo() {
        guard let navBar = navigationController?.navigationBar else { return }
        navBar.subviews.filter { $0.tag == 1001 }.forEach { $0.removeFromSuperview() }
        
        let logoHeight: CGFloat = 24
        let logoImageView = HexagonLogoView(shouldAnimate: false, scale: 0.5)
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.tag = 1001 // Unique tag to identify the logo view
        
        navBar.insertSubview(logoImageView, at: 0)
        
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: navBar.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: navBar.centerYAnchor),
            logoImageView.heightAnchor.constraint(equalToConstant: logoHeight),
        ])
    }
}

