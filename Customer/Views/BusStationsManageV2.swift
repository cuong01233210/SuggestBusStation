//
//  BusStationsManageV2.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 07/01/2024.
//

import SwiftUI

struct BusStationsManageV2: View {
    @State var hasReceivedData = false
    @Binding var busStationsManageV2 : Bool
    @Binding var token: String
    @State var busStations : [BusStation] = []
    @State private var showDataBusStationV2 = false
    @State private var selectedStationIndex = -1
    
   
    //@State var selectedBusStation : BusStation =
    
    var body: some View {
        if hasReceivedData == false {
            NavigationView {
                ProgressView("Loading ...")
                    .onAppear {
                        Task {
                            do {
                                selectedStationIndex = -1
                                try await getData()
                                // Set hasReceivedData only after the data is received
                                hasReceivedData = true
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarLeading) {
                            Button {
                                busStationsManageV2.toggle()
                            } label: {
                                Image(systemName: "arrowshape.backward.fill")
                            }
                        }
                    }
                    .accentColor(.red)
            }
        } else {
            NavigationView {
                TabView {
                    let pageNum = busStations.count / 10 + 1
                    ForEach(0..<pageNum) { pageIndex in
                        let startIndex = pageIndex * 10
                        let end = (pageIndex + 1) * 10
                        let endIndex = min((pageIndex + 1) * 10, busStations.count)
                        
                        //let productsPage = Array(busStations[startIndex..<endIndex])
                        
                        //ProductPageView(busStations: productsPage)
                        List (startIndex..<endIndex, id: \.self) { index in
                            VStack(alignment: .leading){
                                Text(busStations[index].name)
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
                            .fullScreenCover(isPresented: $showDataBusStationV2) {
                                ShowDataBusStationV2(showDataBusStationV2: $showDataBusStationV2, token: $token, frontHasReceivedData: $hasReceivedData,  busStation: busStations[selectedStationIndex])
                                    .onChange(of: showDataBusStationV2) { _ in
                                        // Reset selectedBusIndex to -1 when ShowBusRoute is dismissed
                                        selectedStationIndex = -1
                                    }
                            }
                        }
                        
                            .tabItem {
                                Text("Page \(pageIndex + 1)")
                            }
                            .tag(pageIndex)
                    }
                    
                    
                }
                .navigationTitle("Các trạm xe buýt")
                .toolbar{
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button{
                            busStationsManageV2.toggle()
                        } label: {
                            Image(systemName: "arrowshape.backward.fill")
                        }
                    }
                }
                .accentColor(.red)
            }
        }
    }
    func getData() async throws {
        busStations = []
        let url = URL(string: "http://localhost:8000/get-all-bus-stations")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type");
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            let errorData = try JSONDecoder().decode(ErrorData.self, from: data).message
            print("Error \(errorData)")
            throw URLError(.cannotParseResponse)
        }
        let jsonData  = try JSONDecoder().decode(BusStations.self, from: data)
       // print(jsonData)
        busStations.append(contentsOf: jsonData.busStations)
    }
}
