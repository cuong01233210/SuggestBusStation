//
//  PlusStation.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 07/01/2024.
//

import SwiftUI

struct PlusStation: View {
    @Binding var plusStation: Bool
    @State private var newStation: BusStation = BusStation(name: "", bus: [], lat: 0.0, long: 0.0, district: "", id: "")
    @State private var busStationInput: String = ""
    @State private var slat: String = ""
    @State private var slong: String = ""
    @State private var isInvalidInputAlertPresented = false
    @State private var successAlert = false
    @Binding var hasReceivedData: Bool
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Nhập tên trạm")){
                    TextField("Nhập tên trạm", text: $newStation.name)
                }
                Section (header: Text("Nhập các tuyến xe buýt")){
                    TextField("Nhập các tuyến xe buýt (cách nhau bởi dấu ',')", text: $busStationInput)
                        .lineLimit(nil)  // Tự động xuống dòng
                        .multilineTextAlignment(.leading)  // Canh lề trái
                }
                Section (header: Text("Nhập toạ độ ")){
                    TextField("Nhập toạ độ latitude", text: $slat)
                    TextField("Nhập toạ độ longitude", text: $slong)
                }
                Section (header: Text("Trạm thuộc quận nào?")){
                    TextField("Nhập quận của trạm", text: $newStation.district)
                }
            }
            .navigationTitle("Thêm trạm xe buýt")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        hasReceivedData = false
                        plusStation.toggle()
                    } label: {
                        Image(systemName: "arrowshape.backward.fill")
                    }
                }
                ToolbarItemGroup (placement: .navigationBarTrailing) {
                    Button("Save") {
                        // Split the input string into an array of bus numbers
                        let busNumbers = busStationInput.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }

                            // Update the bus property of the BusStation struct
                            newStation.bus = busNumbers
                        
                        if let value = Double(slat) {
                            newStation.lat = value
                            // Perform any other actions with the converted value
                        } else {
                            // Show popup notification for invalid input
                            isInvalidInputAlertPresented = true
                        }
                        
                        if let value = Double(slong) {
                            newStation.long = value
                            // Perform any other actions with the converted value
                        } else {
                            // Show popup notification for invalid input
                            isInvalidInputAlertPresented = true
                        }
                        
                        Task {
                            do{
                                try await createNewStation()
                              //  alertMessage = "Comment sent successfully!"
                              //  showAlert = true // Hiển thị Alert khi thành công
                                //appData.outputData = self.outputData
                            }
                            catch{
                                print("Error: \(error)")
                               // alertMessage = "An error occurred while sending the comment."
                               // showAlert = true // Hiển thị Alert khi có lỗi
                            }
                        }
                        
                       // print(newStation)
                    }
                }
            }.accentColor(.red)
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
        let url = URL(string: "http://localhost:8000/add-bus-station")!
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
        let jsonData =  try JSONDecoder().decode(Message.self, from: data)
        print(jsonData)
        successAlert = true
    }
}


