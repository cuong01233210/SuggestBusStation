import SwiftUI

struct AddPath: View {
    @State var busStations: [BusStation] = []
    @State private var selectedStationIndex: Int? = nil
    @State private var searchText: String = ""
    @State var busStation: BusStation = BusStation(name: "", buses: [], lat: 0, long: 0, id: "-1")
    @Binding var addPath: Bool
    @Binding var direction: Bool
    @Binding var chieuDi: [BusStation]
    @Binding var chieuVe: [BusStation]
    @EnvironmentObject var appData: AppData

    var body: some View {
        if appData.loadDataStationsManage == false {
            NavigationView {
                ProgressView("Loading ...")
                    .onAppear {
                        Task {
                            do {
                                selectedStationIndex = nil
                                try await getData()
                                appData.loadDataStationsManage = true
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarLeading) {
                            Button {
                                addPath.toggle()
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
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(filteredStations[index].name)
                                    }
                                    Spacer()
                                    if selectedStationIndex == index {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .onTapGesture {
                                    selectedStationIndex = index
                                    busStation = filteredStations[index]
                                }
                            }
                            .tabItem {
                                Text("Page \(pageIndex + 1)")
                            }
                            .tag(pageIndex)
                        }
                    }
                    .navigationTitle("Chọn trạm để thêm")
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarLeading) {
                            Button {
                                addPath.toggle()
                            } label: {
                                Image(systemName: "arrowshape.backward.fill")
                            }
                        }
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
                            Button("Chọn") {
                                if let selectedStationIndex = selectedStationIndex {
                                    let selectedStation = busStationsFiltered[selectedStationIndex]
                                    if direction {
                                        chieuVe.append(selectedStation)
                                    } else {
                                        chieuDi.append(selectedStation)
                                    }
                                    addPath.toggle()
                                }
                            }
                            .disabled(selectedStationIndex == nil)
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
        let jsonData = try JSONDecoder().decode(BusStations.self, from: data)
        appData.managedStations.append(contentsOf: jsonData.busStations)
    }
}
