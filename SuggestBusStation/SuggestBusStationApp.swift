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

        WindowGroup {
            MyApp()
                .environmentObject(appData)
        }
    }
}
