//
//  LibraryCoordinatorProtocol.swift
//  VideoVibes
//
//  Created by Tammy Ho.
//
//  Defines the protocol for the Library Coordinator, which handles navigation and permissions related to the Library tab.

import Foundation

protocol LibraryCoordinatorProtocol: AnyObject {
    var permissionService: PermissionService { get }
    func navigate(to destination: LibraryDestination)
    func popToRoot()
}
