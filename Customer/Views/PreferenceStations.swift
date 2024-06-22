//
//  PreferenceStations.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 08/01/2024.
//

import SwiftUI

struct PreferenceStations: View {
    @Binding var showPreferenceStations : Bool
    @State private var showDataBusStationV2 = false
    @State private var selectedStationIndex: Int = -1
    @State private var Ids: [String] = []
   // @State var busStations : [BusStation] = []
    @EnvironmentObject var appData: AppData
    var body: some View {
        if appData.hasUpdatedPreStations == false {
    NavigationView {
        ProgressView("Loading ...")
            .onAppear {
                Task {
                    do {
                        selectedStationIndex = -1
                        try await Task.withGroup(resultType: Void.self) { group in
                            // Thực hiện hàm getAllBookmark trong một task group
                            await group.add { try await getAllBookmark() }
                            
                            // Đợi cho getAllBookmark hoàn thành trước khi thực hiện getAllBookmarkData
                         try   await group.next()
                            
                            // Thực hiện hàm getAllBookmarkData
                            try await getAllBookmarkData()
                            
                            // Set hasReceivedData only after both functions are completed
                            appData.hasUpdatedPreStations = true
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
            .toolbar{
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        showPreferenceStations.toggle()
                    } label: {
                        Image(systemName: "arrowshape.backward.fill")
                    }
                }
            }.accentColor(.red)
            }
        } else {
            NavigationView {
                TabView {
                    let pageNum = appData.userPreStations.count / 10 + 1
                    ForEach(0..<pageNum) { pageIndex in
                        let startIndex = pageIndex * 10
                        let endIndex = min((pageIndex + 1) * 10, appData.userPreStations.count)
                        
                        //let productsPage = Array(busStations[startIndex..<endIndex])
                        
                        //ProductPageView(busStations: productsPage)
                        List (startIndex..<endIndex, id: \.self) { index in
                            VStack(alignment: .leading){
                                Text(appData.userPreStations[index].name)
                            }
                            .onTapGesture {
                                selectedStationIndex = index
                                //print(selectedStationIndex)
                                //showDataBusStation = true
                            }
                            .onChange(of: selectedStationIndex) { newValue in
                                // Khi selectedStationIndex thay đổi thì mới cho show màn hình kia
                                showDataBusStationV2 = true
                            }
                                                    }
                        .tabItem {
                            Text("Page \(pageIndex + 1)")
                        }
                        .tag(pageIndex)
                    }
                }
                .fullScreenCover(isPresented: $showDataBusStationV2) {

                    ShowDataBusStation(showDataBusStation: $showDataBusStationV2, busStation: $appData.userPreStations[selectedStationIndex])
                }

                .navigationTitle("Trạm xe buýt yêu thích")
                .toolbar{
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button {
                            showPreferenceStations.toggle()
                        } label: {
                            Image(systemName: "arrowshape.backward.fill")
                        }
                    }
                }.accentColor(.red)
            }
        }
    }
    func getAllBookmarkData() async throws {
        appData.userPreStations = []
        let url = URL(string: "http://localhost:8000/get-stations-by-ids")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //let busesName: BusesName = BusesName(buses: sbuses)
        let userStationsIds = UserStationIds(stationIds: Ids)
        guard let encoded = try? JSONEncoder().encode(userStationsIds) else {
                    return
            }
        let (data, response) = try await URLSession.shared.upload(for: urlRequest, from: encoded)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    let errorData = try JSONDecoder().decode(ErrorData.self, from: data).message
                    
                    print("Error \(errorData)")
                    throw URLError(.cannotParseResponse)
                }
        let jsonData =  try JSONDecoder().decode(BusStations.self, from: data)
       // print(jsonData)
        appData.userPreStations.append(contentsOf: jsonData.busStations)
        //print(busStations)
    }
    func getAllBookmark() async throws {
        Ids = []
        let url = URL(string: "http://localhost:8000/get-all-stations-prefer")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Bearer \(appData.token)", forHTTPHeaderField: "Authorization");
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type");
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            let errorData = try JSONDecoder().decode(ErrorData.self, from: data).message
            print("Error \(errorData)")
            throw URLError(.cannotParseResponse)
        }
        let jsonData  = try JSONDecoder().decode(UserStationIds.self, from: data)
       // print(jsonData)
        
        //print(userStationIds)
        for jId in jsonData.stationIds {
            Ids.append(jId)
        }
        //print(userStationIds)
        //print(Ids)
        
    }
}


