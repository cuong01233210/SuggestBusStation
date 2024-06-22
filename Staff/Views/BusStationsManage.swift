

import SwiftUI



struct BusStationsManage: View {
    
    @Binding var busStationsManage: Bool
    @State var busStations: [BusStation] = []
    @State private var showDataBusStation = false
    @State private var selectedStationIndex = -1
    @State private var plusStation = false
    @State private var searchText: String = ""
   // @State var busStation: BusStation = BusStation(name: "", buses: [], lat: 0, long: 0, id: "-1")
    @State var busStation: BusStation = BusStation(name: "", buses: [], lat: 0, long: 0)
    @EnvironmentObject var appData: AppData

    var body: some View {
        if appData.loadDataStationsManage == false {
            NavigationView {
                ProgressView("Loading ...")
                    .onAppear {
                        Task {
                            do {
                                selectedStationIndex = -1
                                try await getData()
                                
                                // Set hasReceivedData only after the data is received
                                
                                appData.loadDataStationsManage = true
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
                VStack {
                    // Search bar
                    TextField("Tìm kiếm trạm xe buýt", text: $searchText)
                        .padding(7)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)

                    TabView {
                        let filteredStations = busStationsFiltered
                        let pageNum = filteredStations.count / 10 + 1
                        ForEach(0..<pageNum, id: \.self) { pageIndex in
                            let startIndex = pageIndex * 10
                            let endIndex = min((pageIndex + 1) * 10, filteredStations.count)

                            List(startIndex..<endIndex, id: \.self) { index in
                                VStack(alignment: .leading) {
                                    Text(filteredStations[index].name)
                                }
                                .onTapGesture {
                                    selectedStationIndex = index
                                    print("Selected station index: \(selectedStationIndex)")
                                    
                                    if let selectedBusStation = filteredStations[safe: selectedStationIndex] {
                                        print("Selected bus station: \(selectedBusStation.name)")
                                        busStation = selectedBusStation
                                        showDataBusStation = true
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
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarLeading) {
                            Button {
                                busStationsManage.toggle()
                            } label: {
                                Image(systemName: "arrowshape.backward.fill")
                            }
                        }
                        if appData.userRole == "1"{
                            ToolbarItemGroup(placement: .navigationBarTrailing) {
                                Image(systemName: "plus.square.on.square")
                                    .onTapGesture {
                                        plusStation.toggle()
                                    }
                                    .fullScreenCover(isPresented: $plusStation) {
                                        PlusStation(plusStation: $plusStation)
                                    }
                            }
                        }
                        
                    }
                    .fullScreenCover(isPresented: $showDataBusStation) {
                        ShowDataBusStation(showDataBusStation: $showDataBusStation, busStation: $busStation)
                            .onDisappear {
                                selectedStationIndex = -1
                            }
                    }
                    .accentColor(.red)
                }
            }
        }
    }

    var busStationsFiltered: [BusStation] {
        if searchText.isEmpty {
            return appData.managedStations
        } else {
            return appData.managedStations.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }

    func getData() async throws {
        appData.managedStations = []
        let url = URL(string: "http://localhost:8000/get-all-bus-stations")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            let errorData = try JSONDecoder().decode(ErrorData.self, from: data).message
            print("Error \(errorData)")
            throw URLError(.cannotParseResponse)
        }
        let jsonData  = try JSONDecoder().decode(BusStations.self, from: data)
        appData.managedStations.append(contentsOf: jsonData.busStations)
    }
    
    
}



extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
