//
//  BusStation.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 18/07/2023.
//

import Foundation
struct BusStation: Codable {
    var name: String
    var bus: [String]
    var lat: Double
    var long: Double
    var district: String
    var id: String
}
