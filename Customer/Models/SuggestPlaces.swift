//
//  SuggestPlaces.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 01/05/2024.
//

import SwiftUI

struct Place: Codable, Identifiable {
    let id = UUID()
    var name: String
    var category: String
    var lat: Double
    var long: Double
}

struct SuggestPlaces: Codable {
    var places: [Place]
    var stations: [Place]
    var schools: [Place]
    var hospitals: [Place]
    var markets: [Place]
    var bookstores: [Place]
    var parks: [Place]
    var pagodas: [Place]
    var museums: [Place]
    var diffPlaces: [Place]
}
