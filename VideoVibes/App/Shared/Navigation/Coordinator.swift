//
//  AnyCoordinator.swift
//  VideoVibes
//
//  Created by Tammy Ho.
//
//  Defines a protocol for coordinating navigation within the app.

import Foundation

protocol Coordinator: AnyObject {
    func start()
    func popViewController(removeLastChildCoordinator: Bool)
    func popToRoot()
}
