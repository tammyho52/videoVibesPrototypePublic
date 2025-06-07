//
//  Fonts.swift
//  VideoVibes
//
//  Created by Tammy Ho.
//
//  Defines the custom fonts used throughout the app.

import UIKit

enum AppFont {
    static let title = UIFont(name: "AvenirNext-Bold", size: 32) ?? UIFont.systemFont(ofSize: 32, weight: .bold)
    static let subtitle = UIFont(name: "AvenirNext-Regular", size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .regular)
    static let body = UIFont(name: "AvenirNext-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .regular)
    static let caption = UIFont(name: "AvenirNext-Regular", size: 14) ?? UIFont.italicSystemFont(ofSize: 14)
    static let boldBody = UIFont(name: "AvenirNext-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)
}


