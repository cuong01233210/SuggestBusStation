//
//  SuggestBusStationApp.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 10/06/2023.
//

import SwiftUI
class AppData: ObservableObject {
    @Published var outputData: OutputData
    @Published var userLat: Double
    @Published var userLong: Double
    @Published var suggestPlaces: SuggestPlaces
    @Published var startPlace: Place
    @Published var endPlace: Place
    @Published var searchMode: Int = 1
    @Published var userTimeMode: Int = 0 // 0: bây giờ, 1: tự chọn thời gian
    @Published var userInputHour: Int = 0
    @Published var userInputMinute: Int = 0
    @Published var inputFlag : Int
    @Published var loadDataBusesManage : Int = 0 // chua load
    @Published var managedBuses: [Bus] = [] // tuyen bus duoc quan ly
    @Published var managedStations: [BusStation] = []
    @Published var loadDataStationsManage : Bool = false
    @Published var userRole : String = ""
    @Published var token: String = ""
    @Published var hasUpdatedPreStations : Bool = false
    @Published var hasUpdatedPreBuses: Bool = false
    @Published var userPreStations : [BusStation] = []
    @Published var userPreBuses : [Bus] = []
    @Published var needGetStaff : Bool = true
    @Published var staffs : [Account] = []
    init() {
        self.outputData = OutputData(
            route: "test",
            stationStartName: "test",
            stationEndName: "test",
            distanceInMeters: 0,
            stationStartLat: 21.0,
            stationStartLong: 105.0,
            stationEndLat: 21.1,
            stationEndLong: 105.1
        )
        self.userLat = 21
        self.userLong = 105
        
        suggestPlaces = SuggestPlaces(
            places: [],
            stations: [],
            schools: [],
            hospitals: [],
            markets: [],
            bookstores: [],
            parks: [],
            pagodas: [],
            museums: [],
            busStations: [],
            diffPlaces: []
        )
        
        startPlace = Place(name: "Vị trí hiện tại", category: "", lat: 0, long: 0)
        endPlace = Place(name: "", category: "", lat: 0, long: 0)
        inputFlag = -1 // chưa sử dụng tính năng search xe buýt
    }
}

@main
struct SuggestBusStationApp: App {
    @StateObject var appData = AppData()
    var body: some Scene {

        WindowGroup {
            MyApp()
                .environmentObject(appData)
                .onAppear {
                    LocationManager.shared.requestLocation()
                }
        }
    }
}
