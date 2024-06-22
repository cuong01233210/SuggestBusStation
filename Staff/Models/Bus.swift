//
//  Bus.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 03/01/2024.
//

import SwiftUI

struct Bus: Codable, Identifiable {
    var id: String
    var bus: String
    var price: Int
    var activityTime: String
    var gianCachChayXe: String
    var gianCachTrungBinh: Double
}

struct Buses: Codable {
    var buses: [Bus]
}

struct BusRoute: Codable {
    var chieuDi: [BusStation]
    var chieuVe: [BusStation]
    //var chieuDi : [String]
    //var chieuVe: [String]
}

struct BusName: Codable {
    var bus: String
}

struct BusesName : Codable {
    let sbuses: [String]
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
    var gianCachTrungBinh: Double
    var chieuDi: [BusStation]
    var chieuVe: [BusStation]
}
