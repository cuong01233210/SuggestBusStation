//
//  SuggestBusStationApp.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 10/06/2023.
//

import SwiftUI

@main
struct SuggestBusStationApp: App {
    @StateObject var appData = AppData()
    var body: some Scene {
        var outputData : OutputData = OutputData(route: "test", stationStartName: "test", stationEndName: "test", distanceInMeters: 0, stationStartLat: 21.0, stationStartLong: 105.0, stationEndLat: 21.1, stationEndLong: 105.1)
        var mapInput : MapInput = MapInput(outputData: outputData, userLat: 21, userLong: 105.8, userLocationName: "Hà Nội")
        WindowGroup {
            ContentView()
                .environmentObject(appData)
        }
    }
}
