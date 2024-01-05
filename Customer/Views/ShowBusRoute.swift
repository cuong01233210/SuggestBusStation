//
//  ShowBusRoute.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 03/01/2024.
//

import SwiftUI

struct ShowBusRoute: View {
    let bus : String
    @Binding var showBusRoute: Bool
    @State var isLoved = false
    @State var hasReceivedData = false
    
    @State var chieuDi: [String] = []
    @State var chieuVe: [String] = []
    @State var showChieuDi = true
    var body: some View {
        if hasReceivedData == false {
            ProgressView("Loading ...")
                .onAppear {
                    Task {
                        do {
                            print("\(bus)")
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
                                if isLoved == false {
                                    Image(systemName: "heart")
                                        .onTapGesture {
                                            isLoved = true
                                        }
                                } else {
                                    Image(systemName: "heart.fill")
                                        .onTapGesture {
                                            isLoved = false
                                        }
                                }
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
                            }
                            ToolbarItemGroup(placement: .navigationBarLeading) {
                                Button {
                                    showBusRoute.toggle()
                                } label: {
                                    Image(systemName: "arrowshape.backward.fill")
                                }
                            }
                        }
                } else {
                    List (0..<chieuVe.count, id: \.self ) { index in
                        VStack (alignment: .leading){
                            Text("\(chieuVe[index])")
                        }
                    }
                    .navigationTitle("Tuyến \(bus)")
                        .toolbar {
                            ToolbarItemGroup(placement: .navigationBarTrailing){
                                if isLoved == false {
                                    Image(systemName: "heart")
                                        .onTapGesture {
                                            isLoved = true
                                        }
                                } else {
                                    Image(systemName: "heart.fill")
                                        .onTapGesture {
                                            isLoved = false
                                        }
                                }
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
                            }
                            ToolbarItemGroup(placement: .navigationBarLeading) {
                                Button {
                                    showBusRoute.toggle()
                                } label: {
                                    Image(systemName: "arrowshape.backward.fill")
                                }
                            }
                        }
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
    func placeOrder() { }
        func adjustOrder() { }
        func rename() { }
        func delay() { }
        func cancelOrder() { }
}
//#Preview {
//    ShowBusRoute()
//}
