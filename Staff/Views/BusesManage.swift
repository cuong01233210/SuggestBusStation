import SwiftUI
struct BusesManage: View {
    
    @Binding var showBusesManage: Bool
    //@Binding var token: String
    //@State var buses: [Bus] = []
    @State var showBusRoute = false
    @State var plusBus = false
    @State private var selectedBus: Bus?
    @State private var searchText: String = ""
    @State private var selectedBusName : String = "00"
    @EnvironmentObject private var appData: AppData
    
    var body: some View {
        if appData.loadDataBusesManage == 0 {
            NavigationView {
                ProgressView("Loading ...")
                    .onAppear {
                        Task {
                            do {
                                selectedBus = nil
                                try await getBuses()
                                // Set hasReceivedData only after the data is received
                                
                                appData.loadDataBusesManage = 1
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarLeading) {
                            Button {
                                showBusesManage.toggle()
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
                    TextField("Tìm kiếm tuyến xe", text: $searchText)
                        .padding(7)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    
                    List(filteredBuses) { bus in
                        VStack(alignment: .leading) {
                            Text("Tuyến số \(bus.bus)")
                                .bold()
                                .font(.system(size: 20))
                                .foregroundColor(.red)
                            Text("Giá vé \(bus.price)")
                            HStack {
                                Text(bus.activityTime)
                                    .padding(.trailing, 20)
                                Text(bus.gianCachChayXe)
                            }
                        }
                        .onTapGesture {
                            selectedBus = bus
                           
                            if let selectedBus = selectedBus {
                                selectedBusName = String(selectedBus.bus)
                               
                                showBusRoute = true
                            }
                        }
                    }
                    .fullScreenCover(isPresented: $showBusRoute) {
                        Group {
                            ShowBusRoute(bus: $selectedBusName, showBusRoute: $showBusRoute)
                          
                        }
                    }
                    .navigationTitle("Thông tin các tuyến xe")
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarLeading) {
                            Button {
                                showBusesManage.toggle()
                            } label: {
                                Image(systemName: "arrowshape.backward.fill")
                            }
                        }
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
                            Image(systemName: "plus.square.on.square")
                                .onTapGesture {
                                    plusBus.toggle()
                                }
                                .fullScreenCover(isPresented: $plusBus) {
                                    PlusBus(plusBus: $plusBus)
                                }
                        }
                    }
                    .accentColor(.red)
                }
            }
        }
    }
    
    var filteredBuses: [Bus] {
        if searchText.isEmpty {
            return appData.managedBuses
        } else {
            return appData.managedBuses.filter { $0.bus.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    func getBuses() async throws {
        appData.managedBuses = []
        let url = URL(string: "http://localhost:8000/get-all-bus-in4")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        //urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization");
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type");
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            let errorData = try JSONDecoder().decode(ErrorData.self, from: data).message
            print("Error \(errorData)")
            throw URLError(.cannotParseResponse)
        }
//        if let jsonString = String(data: data, encoding: .utf8) {
//                   print("Response JSON: \(jsonString)")
//               }
        let jsonData = try JSONDecoder().decode(Buses.self, from: data)
       
        print("jsonData")
        // print(jsonData)
        appData.managedBuses.append(contentsOf: jsonData.buses)
    }
}


