//
//  ResponseData.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 2/6/24.
//

import SwiftUI

struct ReturnRoute: Codable, Identifiable {
    var id: UUID { UUID() }
    let source: String
  //  let sourceLat : Double
   // let sourceLong : Double
    let destination: String
    let destinationLat: Double
    let destinationLong : Double
    let buses: [String]
    let transportTime: Int
    let transportS: Int
    let pathType: PathType
    
    enum PathType: String, Codable {
        case bus
        case walk
    }
}

struct ResultRoute: Codable, Identifiable {
    var id: UUID { UUID() }
    let startStation: String
    let endStation: String
   // let startStationLat: Double
   // let startStationLong: Double
  //  let endStationLat: Double
   // let endStationLong : Double
    let buses: [String]
    let cost: Double
    let transportHour: Int
    let transportMinute: Int
    let startHour: Int
    let startMinute: Int
    let endHour: Int
    let endMinute: Int
    let stations: [String]
    let returnRoutes: [ReturnRoute]
}

struct ResultRoutes: Codable {
    let resultRoutes: [ResultRoute]
}
