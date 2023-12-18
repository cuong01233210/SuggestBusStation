//
//  CardData.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 20/09/2023.
//

import Foundation
struct PresentData {
    var startLocation: String
    var startDistance: Double
    var route: String
    var endStation: String
    var startLocationLat: Double
    var startLocationLong: Double
    var startStationLat: Double
    var startStaionLong: Double
    
    init(startLocation: String, startDistance: Double, route: String, endStation: String, startLocationLat: Double, startLocationLong: Double, startStationLat: Double, startStationLong: Double) {
        self.startLocation = startLocation
        self.startDistance = startDistance
        self.route = route
        self.endStation = endStation
        self.startLocationLat = startLocationLat
        self.startLocationLong = startLocationLong
        self.startStationLat = startStationLat
        self.startStaionLong = startStationLong
    }
}
