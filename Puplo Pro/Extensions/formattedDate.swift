//
//  formattedDate.swift
//  Puplo Pro
//
//  Created by Ahmed on 19/11/2025.
//

import Foundation

extension Date {
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: self)
    }
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: self)
    }
}
extension String {
    /// Convert time string from "hh:mm a" (e.g., "02:30 PM") to 24-hour format "HH:mm" (e.g., "14:30")
    var to24HourFormat: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        if let date = formatter.date(from: self) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "HH:mm"
            outputFormatter.locale = Locale(identifier: "en_US_POSIX")
            return outputFormatter.string(from: date)
        }
        return self
    }
}
