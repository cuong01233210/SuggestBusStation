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
struct BusStations: Codable {
    var busStations: [BusStation]
}


enum BSError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}

struct UserStationId : Codable {
    var stationId: String
}

struct UserStationIds: Codable {
    var stationIds: [String]
}
