//
//  ShowDataBusStationV2.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 07/01/2024.
//

import SwiftUI

struct ShowDataBusStationV2: View {
    @Binding var showDataBusStationV2: Bool
    @Binding var token: String
    @State var isLoved = false
   // @State var userStation = UserStation
     var busStation: BusStation
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Tên trạm")){
                    Text(busStation.name)
                }
                Section(header: Text("Các tuyến xe buýt đi qua")){
                    ForEach(0..<busStation.bus.count, id: \.self) { index in
                        if index % 5 == 0 {
                            let endIndex = Swift.min(index + 5, busStation.bus.count)
                            let chunk = busStation.bus[index..<endIndex]
                            Text("Bus List: \(chunk.joined(separator: ", "))")
                            // .foregroundColor(.gray) // Tùy chỉnh màu sắc nếu cần
                        }
                    }
                }
                Section(header: Text("Toạ độ của trạm")){
                    Text("Toạ độ latitude: \(busStation.lat)")
                    Text("Toạ độ longitude: \(busStation.long)")
                }
                Section(header: Text("Khu vực")){
                    Text("Quận: \(busStation.district)")
                }
                
               
            }
            .navigationTitle("Thông tin chi tiết")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        showDataBusStationV2.toggle()
                    } label: {
                        Image(systemName: "arrowshape.backward.fill")
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if isLoved == false{
                    Image(systemName: "heart")
                        .onTapGesture {
                                Task {
                                    do {
                                        try await bookmark()
                                        DispatchQueue.main.async {
                                            isLoved = true
                                        }
                                    } catch {
                                        print(error.localizedDescription)
                                    }
                                }
                            }
                    } else {
                        Image(systemName: "heart.fill")
                            .onTapGesture {
                                Task {
                                    do {
                                        try await unbookmark()
                                        DispatchQueue.main.async {
                                            isLoved = false
                                        }
                                        
                                    } catch {
                                        print(error.localizedDescription)
                                    }
                                }
                            }
                    }
                }
            }.accentColor(.red)
        }
    }
    
    func bookmark() async throws {
        //print("Đã vào hàm bookmark")
        let url = URL(string: "http://localhost:8000/add-station-prefer")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        //print(token)
        
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization");
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type");
        
        let userStationId = UserStationId(stationId: busStation.id)
        guard let encoded = try? JSONEncoder().encode(userStationId) else {
                    return
        }
        let (data, response) = try await URLSession.shared.upload(for: urlRequest, from: encoded)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    let errorData = try JSONDecoder().decode(ErrorData.self, from: data).message
                    
                    print("Error \(errorData)")
                    throw URLError(.cannotParseResponse)
                }
       // let jsonData =  try JSONDecoder().decode(Message.self, from: data)
       // print(jsonData.message)
    }
    
    func unbookmark() async throws {
        let url = URL(string: "http://localhost:8000/delete-station-prefer")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization");
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type");
        let userStationId = UserStationId(stationId: busStation.id)
        guard let encoded = try? JSONEncoder().encode(userStationId) else {
                    return
        }
        let (data, response) = try await URLSession.shared.upload(for: urlRequest, from: encoded)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    let errorData = try JSONDecoder().decode(ErrorData.self, from: data).message
                    
                    print("Error \(errorData)")
                    throw URLError(.cannotParseResponse)
                }
        //let jsonData =  try JSONDecoder().decode(Message.self, from: data)
       // print(jsonData.message)
    }
}

