//
//  BusStations.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 18/07/2023.
//

import Foundation
struct BusStations: Codable {
    var busStations: [BusStation]
}

enum BSError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}
