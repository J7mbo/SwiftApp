//
//  DateExtensions.swift
//  GithubBusApp
//
//  Created by James Mallison on 10/03/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import Foundation

extension DateFormatter
{
    /// If we have a 'dd' in the format, add the correct "st", "th", "nd" or "rd" suffix to the day parameter
    ///
    /// - Parameters:
    ///   - date: The date
    ///   - format: The format (Overrides `self.dateFormat`)
    ///
    /// - Returns: The new date string
    func formatWithDaySuffix(from date: Date, andWithFormat format: String) -> String {
        self.dateFormat = format
        
        let formattedDate = self.string(from: date)
        
        if !format.contains("dd") {
            return formattedDate
        }
        
        /** We know it contains "dd" because of the above defensive clause **/
        var suffix: String
        
        switch Calendar.current.component(.day, from: date) {
        case 1, 21, 31: suffix = "st"
        case 2, 22: suffix = "nd"
        case 3, 23: suffix = "rd"
        default: suffix = "th"
        }
        
        self.dateFormat = format.replacingOccurrences(of: "dd", with: "dd'\(suffix)'")
        
        return self.string(from: date)
    }
}
