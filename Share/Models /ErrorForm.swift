//
//  ErrorForm.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 9/7/24.
//

import SwiftUI

struct ErrorForm: Codable{
    var id: String
    var source: String
    var destination: String
    var busName: String
    var time: String
    var date: String
    var errorDescription: String
}


