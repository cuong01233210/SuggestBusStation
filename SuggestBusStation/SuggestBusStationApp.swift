//
//  SuggestBusStationApp.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 10/06/2023.
//

import SwiftUI

@main
struct SuggestBusStationApp: App {
    var body: some Scene {
        var outputData : OutputData = OutputData(route: "test", stationStartName: "test", stationEndName: "test", distanceInMeters: 0, stationStartLat: 0.0, stationStartLong: 0.0, stationEndLat: 0.0, stationEndLong: 0.0)
        var mapInput : MapInput = MapInput(outputData: outputData, userLat: 21, userLong: 105.8, userLocationName: "Hà Nội")
        WindowGroup {
            ContentView()
        }
    }
}
