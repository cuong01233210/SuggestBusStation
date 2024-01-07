//
//  ShowDataBusStation.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 06/01/2024.
//

import SwiftUI

struct ShowDataBusStation: View {
    @Binding var showDataBusStation: Bool
    @Binding var hasReceivedData: Bool
    @State private var isEditing = false
    @State private var editedName = ""
    @State private var editedBus = ""
    @State private var editedLat = ""
    @State private var editedLong = ""
    @State private var editedDistrict = ""
    @State var editedSetup = false
    @State var showDeleteAlert = false
    @State private var isInvalidInputAlertPresented = false
    @State private var successAlert = false
    @State private var showUpdateAlert = false
    @State private var newStation = BusStation(name: "", bus: [], lat: 0.0, long: 0.0, district: "", id: "")
    var busStation: BusStation
    var body: some View {
        if editedSetup == false {
            NavigationView {
                ProgressView("Loading ...")
                    .onAppear {
                        Task {
                            do {
                                newStation.name = busStation.name
                                newStation.bus = busStation.bus
                                newStation.lat = busStation.lat
                                newStation.long = busStation.long
                                newStation.district = busStation.district
                                newStation.id = busStation.id
                                // Set hasReceivedData only after the data is received
                                editedSetup = true
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarLeading) {
                            Button {
                                hasReceivedData = false
                                showDataBusStation.toggle()
                            } label: {
                                Image(systemName: "arrowshape.backward.fill")
                            }
                        }
                    }
                    .accentColor(.red)
            }
        }
        NavigationView {
            List {
                Section(header: Text("Tên trạm")){
                    if isEditing {
                        TextEditor(text: $editedName)
                            .lineLimit(nil) // Loại bỏ giới hạn số dòng
                    } else {
                        Text(newStation.name)
                    }
                }
                Section(header: Text("Các tuyến xe buýt đi qua")){
                    if isEditing {
                        TextEditor(text: $editedBus)
                    } else {
                        ForEach(0..<newStation.bus.count, id: \.self) { index in
                            if index % 5 == 0 {
                                let endIndex = Swift.min(index + 5, newStation.bus.count)
                                let chunk = newStation.bus[index..<endIndex]
                                Text("Bus List: \(chunk.joined(separator: ", "))")
                                // .foregroundColor(.gray) // Tùy chỉnh màu sắc nếu cần
                            }
                        }
                    }
                }
                Section(header: Text("Toạ độ của trạm")){
                    if isEditing {
                        HStack {
                            Text("Toạ độ latitude")
                            TextEditor(text: $editedLat)
                        }
                        HStack {
                            Text("Toạ độ longitude")
                            TextEditor(text: $editedLong)
                        }
                    }
                    else {
                        Text("Toạ độ latitude: \(newStation.lat)")
                        Text("Toạ độ longitude: \(newStation.long)")
                    }
                }
                Section(header: Text("Khu vực")){
                    if isEditing{
                        TextEditor(text: $editedDistrict)
                    } else {
                        Text("Quận: \(newStation.district)")
                    }
                }
                
                
            }
            .navigationTitle("Thông tin chi tiết")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        hasReceivedData = false
                        showDataBusStation.toggle()
                    } label: {
                        Image(systemName: "arrowshape.backward.fill")
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing){
                    if isEditing == true {
                        Button {
                            showUpdateAlert.toggle()
                        } label: {
                            Text("Lưu thay đổi")
                        }
                        .alert(isPresented: $showUpdateAlert) {
                            Alert(
                                title: Text("Thêm trạm"),
                                message: Text("Bạn có chắc muốn sửa thông tin trạm này?"),
                                primaryButton: .destructive(Text("OK")) {
                                    // Gọi hàm delete khi người dùng ấn OK
                                    Task {
                                        do{
                                            try await update()
                                        }
                                        catch{
                                            print("Error: \(error)")
                                        }
                                    }
                                },
                                secondaryButton: .cancel()
                            )
                        }
                    }
                    Image(systemName: "pencil.circle")
                        .onTapGesture {
                            editedName = busStation.name
                            editedBus = busStation.bus.joined(separator: ", ")
                            editedLat = String(busStation.lat)
                            editedLong = String(busStation.long)
                            editedDistrict = busStation.district
                            isEditing = true
                        }
                    
                    Button {
                        showDeleteAlert.toggle()
                    } label: {
                        Image(systemName: "trash")
                    }
                    .alert(isPresented: $showDeleteAlert) {
                        Alert(
                            title: Text("Xóa trạm"),
                            message: Text("Bạn có chắc muốn xóa trạm này?"),
                            primaryButton: .destructive(Text("OK")) {
                                // Gọi hàm delete khi người dùng ấn OK
                                Task {
                                    do {
                                        try await delete()
                                    } catch {
                                        print("Error deleting: \(error)")
                                    }
                                }
                            },
                            secondaryButton: .cancel()
                        )
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

     func update() async throws {
        let url = URL(string: "http://localhost:8000/update-bus-station")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PATCH"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
         let busNumbers = editedBus.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
         var newLat: Double = 0.0
         var newLong : Double = 0.0
         if let value = Double(editedLat) {
            newLat = value
         } else {
             isInvalidInputAlertPresented = true
         }
         
         if let value = Double(editedLong) {
            newLong = value
         } else {
             isInvalidInputAlertPresented = true
         }
         newStation.name = editedName
         newStation.bus = busNumbers
         newStation.lat = newLat
         newStation.long = newLong
         newStation.district = editedDistrict

        print(newStation)
        guard let encoded = try? JSONEncoder().encode(newStation) else {
            return
        }
        let (data, response) = try await URLSession.shared.upload(for: urlRequest, from: encoded)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            let errorData = try JSONDecoder().decode(ErrorData.self, from: data).message
            
            print("Error \(errorData)")
            throw URLError(.cannotParseResponse)
        }

         successAlert = true
         isEditing = false
    }
    func delete() async throws {
        let url = URL(string: "http://localhost:8000/delete-bus-station")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let encoded = try? JSONEncoder().encode(busStation) else {
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
        hasReceivedData = false
        showDataBusStation.toggle()
    }
    
}
//#Preview {
//    ShowDataBusStation()
//}
