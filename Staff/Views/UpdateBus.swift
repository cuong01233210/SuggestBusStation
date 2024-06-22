//
//  UpdateBus.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 21/6/24.
//

import SwiftUI



struct UpdateBus: View {
    @Binding var updateBus: Bool
    @EnvironmentObject var appData: AppData
    @State var newBus : BusFullData = BusFullData(bus: "", price: 0, activityTime: "", gianCachChayXe: "", gianCachTrungBinh: 0, chieuDi: [], chieuVe: [])
    @Binding var busName: String
    
    @State var sprice: String = "0"
    @State private var isInvalidInputAlertPresented = false
    @State private var successAlert = false
    @State private var sGianCachTrungBinh = ""
    @State private var gianCachTrungBinh: Double = 0
    @State var addRoutePaths = false
    @State var direction: Bool = false
    @State  var chieuDi: [BusStation]
    @State var chieuVe: [BusStation]

    var normalIn4: Bus {
        return appData.managedBuses.filter { bus in
            bus.bus == busName
        }[0]
    }
   
    init(updateBus: Binding<Bool>, busName: Binding<String>, chieuDi: [BusStation], chieuVe: [BusStation]) {
            self._updateBus = updateBus
            self._busName = busName
            self.chieuDi = chieuDi
            self.chieuVe = chieuVe
        }
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Tuyến")){
                    Text("Tuyến \(busName)")
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
                Section(header: Text("Nhập giãn cách trung bình giữa các tuyến xe")){
                    TextField("Nhập giãn cách trung bình giữa các tuyến xe", text: $sGianCachTrungBinh)
                        .onChange(of: sGianCachTrungBinh) { newValue in
                            validateAndConvertInput(newValue)
                        }
                }
                Section (header: Text("Nhập các trạm của chiều đi")){
                    Button {
                        direction =  false
                        addRoutePaths.toggle()
                    } label: {
                        Text("Thêm các trạm chiều đi")
                    }
                }
                Section (header: Text("Nhập các trạm của chiều về")){
                    Button {
                        direction = true
                        addRoutePaths.toggle()
                    } label: {
                        Text("Thêm các trạm chiều về")
                    }
                }
                
                
                
            }
            .fullScreenCover(isPresented: $addRoutePaths, content: {
                AddRoutePaths(addRoutePaths: $addRoutePaths, direction: $direction, chieuDi: $chieuDi, chieuVe: $chieuVe)
            })
            .navigationTitle("Sửa thông tin tuyến")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        updateBus.toggle()
                    } label: {
                        Image(systemName: "arrowshape.backward.fill")
                    }
                }
                
                ToolbarItemGroup (placement: .navigationBarTrailing) {
                    Button("Lưu") {
                        if let price = Int(sprice) {
                            newBus.price = price
                            // Perform any other actions with the converted value
                        } else {
                            // Show popup notification for invalid input
                            isInvalidInputAlertPresented = true
                        }
                        
                        
                        
                        Task {
                            do{
                                try await updateBus()
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
                message: Text("Bạn đã chỉnh sửa thông tin tuyến thành công"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    func updateBus() async throws {
        newBus.chieuDi = chieuDi
        newBus.chieuVe = chieuVe
        newBus.gianCachTrungBinh = gianCachTrungBinh
        newBus.bus = busName
        let url = URL(string: "http://localhost:8000/update-bus")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PATCH"
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
        appData.loadDataBusesManage = 0
        successAlert = true
    }
    
    private func validateAndConvertInput(_ input: String) {
        if let value = Double(input) {
            gianCachTrungBinh = value
        } else {
            isInvalidInputAlertPresented = true
        }
    }
}


