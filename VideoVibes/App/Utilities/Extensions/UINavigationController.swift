//
//  UINavigationController.swift
//  VideoVibes
//
//  Created by Tammy Ho.
//

import UIKit

extension UINavigationController {
    /// Pushes a view controller with a custom transition animation.
    func pushViewControllerWithCustomTransition(
        _ viewController: UIViewController,
        duration: CFTimeInterval = 0.35,
        type: CATransitionType = .push,
        subtype: CATransitionSubtype = .fromRight
    ) {
        let transition = CATransition()
        transition.duration = duration
        transition.type = type
        transition.subtype = subtype
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        view.layer.add(transition, forKey: kCATransition)
        pushViewController(viewController, animated: false)
    }
}
