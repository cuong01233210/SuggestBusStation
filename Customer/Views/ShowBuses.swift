//
//  ShowBuses.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 02/01/2024.
//

import SwiftUI

struct ShowBuses: View {
    @State var hasReceivedData = false
    @Binding var showBuses: Bool
    @Binding var token: String
    @State var buses : [Bus] = []
    @State var showBusRoute = false
    @State private var selectedBusIndex: Int = -1
    
    var body: some View {
        if !hasReceivedData {
            NavigationView {
                ProgressView("Loading ...")
                    .onAppear {
                        Task {
                            do {
                                selectedBusIndex = -1
                                try await getBuses()
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
                            showBuses.toggle()
                        } label: {
                            Image(systemName: "arrowshape.backward.fill")
                        }
                    }
                }
                .accentColor(.red)
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
                            selectedBusIndex = index
                        }
                        .onChange(of: selectedBusIndex) {  newValue in
                            showBusRoute = true
                        }
                        .fullScreenCover(isPresented: $showBusRoute) {
                            ShowBusRoute(bus: String(buses[selectedBusIndex].bus), showBusRoute: $showBusRoute, token: $token, frontHasReceivedData: $hasReceivedData)
                                
                        }
                    
                }
                

                .navigationTitle("Thông tin các tuyến xe")
                .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        showBuses.toggle()
                    } label: {
                        Image(systemName: "arrowshape.backward.fill")
                    }
                }
            }
            .accentColor(.red)
        }
    }

    }
    
    func getBuses() async throws{
        buses = []
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

        let jsonData = try JSONDecoder().decode(Buses.self, from: data)
        print("jsonData")
       // print(jsonData)
        buses.append(contentsOf: jsonData.buses)
    }
}

//#Preview {
//    ShowBuses()
//}
