//
//  PlusBus.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 10/01/2024.
//

import SwiftUI

struct PlusBus: View {
    @Binding var plusBus: Bool
    @Binding var hasReceivedData: Bool
    @State var newBus : BusFullData = BusFullData(bus: "", price: 0, activityTime: "", gianCachChayXe: "", chieuDi: [], chieuVe: [])
    @State var sprice: String = "0"
    @State private var isInvalidInputAlertPresented = false
    @State private var successAlert = false
    @State private var schieuDi: String = ""
    @State private var schieuVe: String = ""
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Nhập số tuyến")){
                    TextField("Nhập tên trạm", text: $newBus.bus)
                }
                Section(header: Text("Nhập giá vé")){
                    TextField("Nhập giá vé", text: $sprice)
                }
                Section(header: Text("Nhập thời gian hoạt động")){
                    TextField("Nhập thời gian hoạt động", text: $newBus.activityTime)
                }
                Section(header: Text("Nhập giãn cách giữa các chuyến xe")){
                    TextField("Nhập thời gian hoạt động", text: $newBus.gianCachChayXe)
                }
                Section (header: Text("Nhập các trạm của chiều đi")){
                    Text("Chú ý: nhập cách nhau bởi dấu ';' ")
                    TextField("Nhập các trạm của chiều đi (cách nhau bởi dấu ';')", text: $schieuDi)
                        .lineLimit(nil)  // Tự động xuống dòng
                        .multilineTextAlignment(.leading)  // Canh lề trái
                }
                Section (header: Text("Nhập các trạm của chiều về")){
                    Text("Chú ý: nhập cách nhau bởi dấu ';' ")
                    TextField("Nhập các trạm của chiều đi (cách nhau bởi dấu ';')", text: $schieuVe)
                        .lineLimit(nil)  // Tự động xuống dòng
                        .multilineTextAlignment(.leading)  // Canh lề trái
                }
                
            }
            .navigationTitle("Thêm trạm xe buýt")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        hasReceivedData = false
                        plusBus.toggle()
                    } label: {
                        Image(systemName: "arrowshape.backward.fill")
                    }
                }
                ToolbarItemGroup (placement: .navigationBarTrailing) {
                    Button("Save") {
                        
                        // Split the input string into an array of bus numbers
                         let chieuDi = schieuDi.split(separator: ";").map { String($0.trimmingCharacters(in: .whitespaces)) }
                        
                        for jchieuDi in chieuDi {
                            var stationRouteData : StationRouteData = StationRouteData(name: jchieuDi, bus: [], lat: 0, long: 0)
                            newBus.chieuDi.append(stationRouteData)
                        }
                            
                        


                         let chieuVe = schieuVe.split(separator: ";").map { String($0.trimmingCharacters(in: .whitespaces)) }
                            
                        for jchieuVe in chieuVe {
                            var stationRouteData : StationRouteData = StationRouteData(name: jchieuVe, bus: [], lat: 0, long: 0)
                            newBus.chieuVe.append(stationRouteData)
                        }
                        

                        
                        
                        if let price = Int(sprice) {
                            newBus.price = price
                            // Perform any other actions with the converted value
                        } else {
                            // Show popup notification for invalid input
                            isInvalidInputAlertPresented = true
                        }
                        
                        
                        
                        Task {
                            do{
                                try await createNewBus()
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
                        message: Text("Bạn cần chú ý nhập đúng định dạng cho dữ liệu"),
                        dismissButton: .default(Text("OK"))
                    )
        }
        .alert(isPresented: $successAlert) {
                    Alert(
                        title: Text("Thông báo"),
                        message: Text("Bạn đã thêm một tuyến xe buýt thành công"),
                        dismissButton: .default(Text("OK"))
                    )
        }
    }
    
    func createNewBus() async throws {
        let url = URL(string: "http://localhost:8000/add-bus")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let encoded = try? JSONEncoder().encode(newBus) else {
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


