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
    // tạm thời chưa thêm trường gianCachTrungBinh vào để xử lý
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

struct BusesName : Codable {
    var buses: [String]
}

struct StationRouteData: Codable{
    var name: String
    var bus: [String]
    var lat: Double
    var long: Double
}
struct BusFullData: Codable {
    var bus: String
    var price : Int
    var activityTime: String
    var gianCachChayXe: String
    var chieuDi: [StationRouteData]
    var chieuVe: [StationRouteData]
}
