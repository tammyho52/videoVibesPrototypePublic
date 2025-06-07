//
//  TimeInterval+Extension.swift
//  VideoVibes
//
//  Created by Tammy Ho.
//

import Foundation

extension TimeInterval {
    /// Converts a TimeInterval to a formatted timestamp string.
    func asTimeStamp() -> String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
