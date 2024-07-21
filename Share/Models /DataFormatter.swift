//
//  DataFormatter.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 8/7/24.
//

import SwiftUI

extension DateFormatter {
    static var shortTime: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }

    static var shortDate: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // Thiết lập múi giờ
        return formatter
    }
}
