//
//  Extensions.swift
//  Cube_Demo
//
//  Created by Nihar Jagad on 26/09/23.
//

import Foundation


extension Date {
    
    func getStringFromDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        let dateString = dateFormatter.string(from:self)
        return dateString
    }
    
    static func getDateFromString(dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        let date = dateFormatter.date(from: dateString)
        return date
    }
}

