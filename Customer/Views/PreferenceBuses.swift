//
//  PreferenceBuses.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 05/01/2024.
//

import SwiftUI

struct PreferenceBuses: View {
    @Binding var showPreferenceBuses : Bool
    @Binding var token: String
    @State var sbuses: [String] = []
    @State var buses : [Bus] = []
    @State var hasReceivedData = false
    @State var showBusRoute = false
    @State private var selectedBusIndex: Int = -1
    
    var body: some View {
        if hasReceivedData == false {
            NavigationView {
                ProgressView("Loading ...")
                    .onAppear {
                        Task {
                            do {
                                try await Task.withGroup(resultType: Void.self) { group in
                                    // Thực hiện hàm getAllBookmark trong một task group
                                    await group.add { try await getAllBookmark() }
                                    
                                    // Đợi cho getAllBookmark hoàn thành trước khi thực hiện getAllBookmarkData
                                 try   await group.next()
                                    
                                    // Thực hiện hàm getAllBookmarkData
                                    try await getAllBookmarkData()
                                    
                                    // Set hasReceivedData only after both functions are completed
                                    hasReceivedData = true
                                }
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }

                    .toolbar{
                        ToolbarItemGroup(placement: .navigationBarLeading) {
                            Button {
                                showPreferenceBuses.toggle()
                            } label: {
                                Image(systemName: "arrowshape.backward.fill")
                            }
                        }
                    }.accentColor(.red)
            }
        } else {
            NavigationView {
                List (0..<buses.count, id: \.self) { index in
                    
                        VStack(alignment: .leading) {
                            Text("Tuyến số \(buses[index].bus)")
                                .bold()
                                .font(.system(size: 20))
                                .foregroundColor(.red)
                            Text("Giá vé \(buses[index].price)")
                            HStack {
                                Text(buses[index].activityTime)
                                    .padding(.trailing, 20)
                                Text(buses[index].gianCachChayXe)
                            }
                        }
                        .onTapGesture {
                            print(index)
                            selectedBusIndex = index
                        }
                        .onChange(of: selectedBusIndex) {  newValue in
                            showBusRoute = true
                        }
                        .fullScreenCover(isPresented: $showBusRoute) {
                            ShowBusRoute(bus: String(buses[selectedBusIndex].bus), showBusRoute: $showBusRoute, token: $token, frontHasReceivedData: $hasReceivedData)
                                .onChange(of: showBusRoute) { _ in
                                // Reset selectedBusIndex to -1 when ShowBusRoute is dismissed
                                selectedBusIndex = -1
                            }
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
                    }.accentColor(.red)
            }
        }
    }
    
    func getAllBookmarkData() async throws {
        buses = []
        let url = URL(string: "http://localhost:8000/get-bus-prefer-by-array")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let busesName: BusesName = BusesName(buses: sbuses)
        guard let encoded = try? JSONEncoder().encode(busesName) else {
                    return
            }
        let (data, response) = try await URLSession.shared.upload(for: urlRequest, from: encoded)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    let errorData = try JSONDecoder().decode(ErrorData.self, from: data).message
                    
                    print("Error \(errorData)")
                    throw URLError(.cannotParseResponse)
                }
        let jsonData =  try JSONDecoder().decode(Buses.self, from: data)
        print(jsonData)
        buses.append(contentsOf: jsonData.buses)
    }
    func getAllBookmark() async throws {
        sbuses = []
        let url = URL(string: "http://localhost:8000/get-all-bus-prefer")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization");
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type");
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            let errorData = try JSONDecoder().decode(ErrorData.self, from: data).message
            print("Error \(errorData)")
            throw URLError(.cannotParseResponse)
        }
        let jsonData  = try JSONDecoder().decode(BusesName.self, from: data)
       // print(jsonData)
        for jbus in jsonData.buses {
            sbuses.append(jbus)
        }
        print(sbuses)
        
    }
    
}


//#Preview {
//    PreferenceBuses()
//}
