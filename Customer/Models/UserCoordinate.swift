//
//  UserCoordinate.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 18/07/2023.
//

import Foundation
struct UserCoordinate: Codable {
    var id: String
    var lat: Double
    var long: Double
    
    init(id: String, lat: Double, long: Double) {
        self.id = id
        self.lat = lat
        self.long = long
    }
}
