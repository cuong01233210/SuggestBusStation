import SwiftUI

struct PreferenceBuses: View {
    @Binding var showPreferenceBuses: Bool
    @EnvironmentObject var appData: AppData
    @State var sbuses: [String] = []
  //  @State var buses: [Bus] = []
   
    @State var showBusRoute = false
    @State private var selectedBusIndex: Int = -1
    
    var body: some View {
        if !appData.hasUpdatedPreBuses {
            NavigationView {
                ProgressView("Loading ...")
                    .onAppear {
                        Task {
                            do {
                                selectedBusIndex = -1
                                try await Task.withGroup(resultType: Void.self) { group in
                                    await group.add { try await getAllBookmark() }
                                    try await group.next()
                                    try await getAllBookmarkData()
                                    appData.hasUpdatedPreBuses = true
                                }
                            } catch {
                                print("Error during data loading: \(error.localizedDescription)")
                            }
                        }
                    }
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarLeading) {
                            Button {
                                showPreferenceBuses.toggle()
                            } label: {
                                Image(systemName: "arrowshape.backward.fill")
                            }
                        }
                    }
                    .accentColor(.red)
            }
        } else {
            NavigationView {
                List(0..<appData.userPreBuses.count, id: \.self) { index in
                    VStack(alignment: .leading) {
                        Text("Tuyến số \(appData.userPreBuses[index].bus)")
                            .bold()
                            .font(.system(size: 20))
                            .foregroundColor(.red)
                        Text("Giá vé \(appData.userPreBuses[index].price)")
                        HStack {
                            Text(appData.userPreBuses[index].activityTime)
                                .padding(.trailing, 20)
                            Text(appData.userPreBuses[index].gianCachChayXe)
                        }
                    }
                    .onTapGesture {
                        selectedBusIndex = index
                    }
                    .onChange(of: selectedBusIndex) { newValue in
                        showBusRoute = true
                    }
                    
                }
                .fullScreenCover(isPresented: $showBusRoute) {
                    ShowBusRoute(bus: $appData.userPreBuses[selectedBusIndex].bus, showBusRoute: $showBusRoute)
                        .onChange(of: showBusRoute) { _ in
                            selectedBusIndex = -1
                        }
                }
                .navigationTitle("Tuyến xe buýt yêu thích")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button {
                            showPreferenceBuses.toggle()
                        } label: {
                            Image(systemName: "arrowshape.backward.fill")
                        }
                    }
                }
                .accentColor(.red)
            }
        }
    }
    
    func getAllBookmarkData() async throws {
        appData.userPreBuses = []
        let url = URL(string: "http://localhost:8000/get-bus-prefer-by-array")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let busesName = BusesName(sbuses: sbuses)
        guard let encoded = try? JSONEncoder().encode(busesName) else {
            print("Failed to encode busesName")
            return
        }
        let (data, response) = try await URLSession.shared.upload(for: urlRequest, from: encoded)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let errorData = try JSONDecoder().decode(ErrorData.self, from: data).message
            print("Error \(errorData)")
            throw URLError(.cannotParseResponse)
        }
        let jsonData = try JSONDecoder().decode(Buses.self, from: data)
        print("getAllBookmarkData response: \(jsonData)")
        appData.userPreBuses.append(contentsOf: jsonData.buses)
    }
    
    func getAllBookmark() async throws {
        sbuses = []
        let url = URL(string: "http://localhost:8000/get-all-bus-prefer")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Bearer \(appData.token)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let errorData = try JSONDecoder().decode(ErrorData.self, from: data).message
            print("Error \(errorData)")
            throw URLError(.cannotParseResponse)
        }
        let jsonData = try JSONDecoder().decode(BusesName.self, from: data)
        print("getAllBookmark response: \(jsonData)")
        sbuses.append(contentsOf: jsonData.sbuses)
    }
}

//#Preview {
//    PreferenceBuses()
//}
