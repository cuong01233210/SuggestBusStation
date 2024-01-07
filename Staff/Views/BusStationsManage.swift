//
//  BusStationsManage.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 06/01/2024.
//

import SwiftUI


struct BusStationsManage: View {
    @State var hasReceivedData = false
    @Binding var busStationsManage : Bool
    @State var busStations : [BusStation] = []
    @State private var showDataBusStation = false
    @State private var selectedStationIndex = 0
    @State private var plusStation = false
    //@State var lastTapTime = Date.distantPast
   
    //@State var selectedBusStation : BusStation =
    
    var body: some View {
        if hasReceivedData == false {
            NavigationView {
                ProgressView("Loading ...")
                    .onAppear {
                        Task {
                            do {
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
                                busStationsManage.toggle()
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
                                    showDataBusStation = true
                                
                            }
                            .fullScreenCover(isPresented: $showDataBusStation) {
                                ShowDataBusStation(showDataBusStation: $showDataBusStation, hasReceivedData: $hasReceivedData, busStation: busStations[selectedStationIndex])
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
                            busStationsManage.toggle()
                        } label: {
                            Image(systemName: "arrowshape.backward.fill")
                        }
                    }
                    
                    ToolbarItemGroup(placement: .navigationBarTrailing){
                        Image(systemName: "plus.square.on.square")
                            .onTapGesture {
                                plusStation.toggle()
                            }
                            .fullScreenCover(isPresented: $plusStation) {
                                PlusStation(plusStation: $plusStation, hasReceivedData: $hasReceivedData)
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
//#Preview {
//    BusStationsManage()
//}

struct BusStationPageView: View {
    let busStations: [BusStation]

    var body: some View {
        List{
            // Hoặc sử dụng indices
            ForEach(busStations.indices) { index in
                VStack (alignment: .leading) {
                    Text(busStations[index].name)
                }
                
            }
        }
    }
}
