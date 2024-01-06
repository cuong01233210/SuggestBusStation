//
//  Message.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 27/12/2023.
//

import SwiftUI

struct Message : Codable {
    var message: String
}

struct ErrorData: Codable {
    var message: String
    init(message: String) {
        self.message = message
    }
}
