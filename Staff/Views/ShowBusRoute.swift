//
//  ShowBusRoute.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 10/01/2024.
//



import SwiftUI

struct ShowBusRoute: View {
    @Binding var bus : String
    @Binding var showBusRoute: Bool
   // @State var isLoved = false
    @State var hasReceivedData = false
    
    @State var chieuDi: [String] = []
    @State var chieuVe: [String] = []
    @State var showChieuDi = true
    //@Binding var token : String
   
    @State var showDeleteAlert = false
    @EnvironmentObject var appData : AppData
    var body: some View {
        if hasReceivedData == false {
            NavigationView {
                ProgressView("Loading ...")
                    .onAppear {
                        Task {
                            do {
                                //print("\(bus)")
                                try await getData()
                                
                                // Set hasReceivedData only after the data is received
                                hasReceivedData = true
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }
                    .toolbar{
                        ToolbarItemGroup(placement: .navigationBarLeading) {
                            Button {
                                
                                showBusRoute.toggle()
                            } label: {
                                Image(systemName: "arrowshape.backward.fill")
                            }
                        }
                        ToolbarItemGroup(placement: .navigationBarTrailing){
                            Button {
                                showDeleteAlert.toggle()
                            } label: {
                                Image(systemName: "trash")
                            }
                            .alert(isPresented: $showDeleteAlert) {
                                Alert(
                                    title: Text("Xóa tuyến"),
                                    message: Text("Bạn có chắc muốn xóa tuyến này?"),
                                    primaryButton: .destructive(Text("OK")) {
                                        // Gọi hàm delete khi người dùng ấn OK
                                        Task {
                                            do {
                                                try await deleteBus(bus: bus)
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
        }
        else {
            NavigationView {
                if showChieuDi == true {
                    List (0..<chieuDi.count, id: \.self ) { index in
                        VStack (alignment: .leading){
                            Text("\(chieuDi[index])")
                        }
                    }
                    .navigationTitle("Tuyến \(bus)")
                        .toolbar {
                            ToolbarItemGroup(placement: .navigationBarTrailing){
                                Menu("Chọn chiều của tuyến") {
                                    Button {
                                        showChieuDi = true
                                    } label: {
                                        Text("Chiều đi")
                                    }

                                    Button {
                                        showChieuDi = false
                                    } label: {
                                        Text("Chiều về")
                                    }
                                    
                                }
                                Button {
                                    showDeleteAlert.toggle()
                                } label: {
                                    Image(systemName: "trash")
                                }
                                .alert(isPresented: $showDeleteAlert) {
                                    Alert(
                                        title: Text("Xóa tuyến"),
                                        message: Text("Bạn có chắc muốn xóa tuyến này?"),
                                        primaryButton: .destructive(Text("OK")) {
                                            // Gọi hàm delete khi người dùng ấn OK
                                            Task {
                                                do {
                                                    try await deleteBus(bus: bus)
                                                } catch {
                                                    print("Error deleting: \(error)")
                                                }
                                            }
                                        },
                                        secondaryButton: .cancel()
                                    )
                                }
                            }
                            ToolbarItemGroup(placement: .navigationBarLeading) {
                                Button {
                                   
                                    showBusRoute.toggle()
                                } label: {
                                    Image(systemName: "arrowshape.backward.fill")
                                }
                            }
                        }.accentColor(.red)
                } else {
                    List (0..<chieuVe.count, id: \.self ) { index in
                        VStack (alignment: .leading){
                            Text("\(chieuVe[index])")
                        }
                    }
                    .navigationTitle("Tuyến \(bus)")
                        .toolbar {
                            ToolbarItemGroup(placement: .navigationBarTrailing){
                                Menu("Chọn chiều của tuyến") {
                                    Button {
                                        showChieuDi = true
                                    } label: {
                                        Text("Chiều đi")
                                    }

                                    Button {
                                        showChieuDi = false
                                    } label: {
                                        Text("Chiều về")
                                    }
                                    
                                }
                                Button {
                                    showDeleteAlert.toggle()
                                } label: {
                                    Image(systemName: "trash")
                                }
                                .alert(isPresented: $showDeleteAlert) {
                                    Alert(
                                        title: Text("Xóa tuyến"),
                                        message: Text("Bạn có chắc muốn xóa tuyến này?"),
                                        primaryButton: .destructive(Text("OK")) {
                                            // Gọi hàm delete khi người dùng ấn OK
                                            Task {
                                                do {
                                                    try await deleteBus(bus: bus)
                                                } catch {
                                                    print("Error deleting: \(error)")
                                                }
                                            }
                                        },
                                        secondaryButton: .cancel()
                                    )
                                }
                            }
                            ToolbarItemGroup(placement: .navigationBarLeading) {
                                Button {
                                   
                                    showBusRoute.toggle()
                                } label: {
                                    Image(systemName: "arrowshape.backward.fill")
                                }
                            }
                        }.accentColor(.red)
                }
            }
        }
    }
    func getData() async throws {
        let url = URL(string: "http://localhost:8000/get-one-bus-data/\(bus)")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type");
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            let errorData = try JSONDecoder().decode(ErrorData.self, from: data).message
            print("Error \(errorData)")
            throw URLError(.cannotParseResponse)
        }
        let jsonData  = try JSONDecoder().decode(BusRoute.self, from: data)
        //print(jsonData)
        chieuDi = jsonData.chieuDi
        chieuVe = jsonData.chieuVe
    }
    
    func deleteBus(bus: String) async throws {
        let url = URL(string: "http://localhost:8000/delete-bus")!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
        var busName : BusName = BusName(bus: bus)
        print(busName)
        guard let encoded = try? JSONEncoder().encode(busName) else {
            return
        }
        let (data, response) = try await URLSession.shared.upload(for: urlRequest, from: encoded)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            let errorData = try JSONDecoder().decode(ErrorData.self, from: data).message

            print("Error \(errorData)")
            throw URLError(.cannotParseResponse)
        }
        let jsonData =  try JSONDecoder().decode(Message.self, from: data)
        //print(jsonData)
        
        showBusRoute.toggle()
        appData.loadDataBusesManage = 0
    }
    
    
    
    
}
//#Preview {
//    ShowBusRoute()
//}
