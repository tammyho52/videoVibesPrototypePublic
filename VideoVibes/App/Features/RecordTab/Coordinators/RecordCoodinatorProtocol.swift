//
//  RecordCoodinatorProtocol.swift
//  VideoVibes
//
//  Created by Tammy Ho.
//
//  Defines the protocol for the Record Coordinator, which handles navigation and permissions related to the Record tab.

import Foundation

protocol RecordCoordinatorProtocol: AnyObject {
    var permissionService: PermissionService { get }
    var videoRecordingService: VideoRecordingService { get }
    func navigate(to destination: RecordDestination)
    func popToRoot()
}
