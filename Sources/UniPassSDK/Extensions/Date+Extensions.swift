//
//  Date+Extensions.swift
//  Unipass
//
//  Created by Javlonbek Dev on 21/07/25.
//

import Foundation

extension Date {
    var apiDateStr: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }
}
