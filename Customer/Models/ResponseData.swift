//
//  ResponseData.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 2/6/24.
//

import SwiftUI

struct ReturnRoute: Codable {
    let source: String
    let destination: String
    let buses: [String]
    let transportTime: Int
    let transportS: Int
    let pathType: PathType
    
    enum PathType: String, Codable {
        case bus
        case walk
    }
}

struct ResultRoute: Codable {
    let startStation: String
    let endStation: String
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
