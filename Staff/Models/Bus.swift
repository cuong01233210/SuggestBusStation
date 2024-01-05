//
//  Bus.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 03/01/2024.
//

import SwiftUI

struct Bus: Codable {
    var bus: String
    var price : Int
    var activityTime: String
    var gianCachChayXe: String
}

struct Buses: Codable {
    var buses: [Bus]
}

struct BusRoute: Codable {
    var chieuDi: [String]
    var chieuVe: [String]
}

struct BusName: Codable {
    var bus: String
}
