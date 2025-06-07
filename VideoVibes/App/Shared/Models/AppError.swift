//
//  AppError.swift
//  VideoVibes
//
//  Created by Tammy Ho.
//
//  Defines the custom error types used throughout the app.

import Foundation

enum AppError: Error {
    case filterError(message: String)
    case videoProcessingError(message: String)
    case systemError
}
