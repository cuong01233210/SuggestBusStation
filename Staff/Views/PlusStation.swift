//
//  PlusStation.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 07/01/2024.
//

import SwiftUI

struct PlusStation: View {
    @Binding var plusStation: Bool
    @State private var newStation: BusStation = BusStation(name: "", buses: [], lat: 0.0, long: 0.0)
    @State private var busStationInput: String = ""
    @State private var slat: String = ""
    @State private var slong: String = ""
    @State private var isInvalidInputAlertPresented = false
    @State private var successAlert = false
    
    @EnvironmentObject var appData: AppData
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Nhập tên trạm")) {
                    TextField("Nhập tên trạm", text: $newStation.name)
                }
                Section(header: Text("Nhập các tuyến xe buýt")) {
                    TextField("Nhập các tuyến xe buýt (cách nhau bởi dấu ',')", text: $busStationInput)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                }
                Section(header: Text("Nhập toạ độ ")) {
                    TextField("Nhập toạ độ latitude", text: $slat)
                    TextField("Nhập toạ độ longitude", text: $slong)
                }
            }
            .navigationTitle("Thêm trạm xe buýt")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        
                        plusStation.toggle()
                    } label: {
                        Image(systemName: "arrowshape.backward.fill")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Lưu") {
                        // Split the input string into an array of bus numbers
                        let busNumbers = busStationInput.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
                        
                        // Update the bus property of the BusStation struct
                        newStation.buses = busNumbers
                        
                        var validInput = true
                        
                        if let value = Double(slat) {
                            newStation.lat = value
                        } else {
                            isInvalidInputAlertPresented = true
                            validInput = false
                        }
                        
                        if let value = Double(slong) {
                            newStation.long = value
                        } else {
                            isInvalidInputAlertPresented = true
                            validInput = false
                        }
                        
                        if validInput {
                            Task {
                                do {
                                    try await createNewStation()
                                    successAlert = true
                                } catch {
                                    print("Error: \(error)")
                                }
                            }
                        }
                    }
                }
            }
            .accentColor(.red)
        }
        .alert(isPresented: $isInvalidInputAlertPresented) {
            Alert(
                title: Text("Nhập sai định dạng"),
                message: Text("Bạn cần chú ý nhập đúng định dạng cho lat long"),
                dismissButton: .default(Text("OK"))
            )
        }
        .alert(isPresented: $successAlert) {
            Alert(
                title: Text("Thông báo"),
                message: Text("Bạn đã thêm một trạm thành công"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    func createNewStation() async throws {
        let url = URL(string: "https://bus-station-server-production.up.railway.app/add-bus-station")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let encoded = try? JSONEncoder().encode(newStation) else {
            return
        }
        let (data, response) = try await URLSession.shared.upload(for: urlRequest, from: encoded)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            let errorData = try JSONDecoder().decode(ErrorData.self, from: data).message
            print("Error \(errorData)")
            throw URLError(.cannotParseResponse)
        }
        let jsonData = try JSONDecoder().decode(Message.self, from: data)
        
        successAlert = true
        appData.loadDataStationsManage = false
    }
}
