//
//  OutputData.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 18/09/2023.
//

import Foundation
struct OutputData: Codable{
    var route: String
    var stationStartName: String
    var stationEndName: String
    var distanceInMeters : Double
    var stationStartLat: Double
    var stationStartLong: Double
    var stationEndLat: Double
    var stationEndLong: Double
    
    init(route: String, stationStartName: String, stationEndName: String, distanceInMeters: Double, stationStartLat: Double, stationStartLong: Double, stationEndLat: Double, stationEndLong: Double) {
        self.route = route
        self.stationStartName = stationStartName
        self.stationEndName = stationEndName
        self.distanceInMeters = distanceInMeters
        self.stationStartLat = stationStartLat
        self.stationStartLong = stationStartLong
        self.stationEndLat = stationEndLat
        self.stationEndLong = stationEndLong
    }
}



struct OutputData2: Codable{
    var startLocation: String
    var startLocationLat: Double
    var startLocationLong: Double
    var minDistances: [Double]
    var minDistancesStations: [String]
    var minRoutes: [String]
    var startDistance: Double
    
    init(startLocation: String, startLocationLat: Double, startLocationLong: Double, minDistances: [Double], minDistancesStations: [String], minRoutes: [String], startDistance: Double) {
        self.startLocation = startLocation
        self.startLocationLat = startLocationLat
        self.startLocationLong = startLocationLong
        self.minDistances = minDistances
        self.minDistancesStations = minDistancesStations
        self.minRoutes = minRoutes
        self.startDistance = startDistance
    }
}



















