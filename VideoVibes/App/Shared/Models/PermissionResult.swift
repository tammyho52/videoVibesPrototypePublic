//
//  PermissionResult.swift
//  VideoVibes
//
//  Created by Tammy Ho.
//
//  Defines an enum to represent the result of a permission request,

import Foundation

enum PermissionResult {
    case granted
    case denied([PermissionType])
}

extension PermissionResult: Equatable {
    static func == (lhs: PermissionResult, rhs: PermissionResult) -> Bool {
        switch (lhs, rhs) {
        case (.granted, .granted):
            return true
        case (.denied(let lhsTypes), .denied(let rhsTypes)):
            return lhsTypes == rhsTypes
        default:
            return false
        }
    }
}
