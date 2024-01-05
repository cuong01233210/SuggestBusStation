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
    @Binding var token : String
    @Binding var frontHasReceivedData: Bool
    var body: some View {
        if hasReceivedData == false {
            NavigationView {
                ProgressView("Loading ...")
                    .onAppear {
                        Task {
                            do {
                                //print("\(bus)")
                                try await getData()
                                try await getAllBookmark()
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
                                frontHasReceivedData = false
                                showBusRoute.toggle()
                            } label: {
                                Image(systemName: "arrowshape.backward.fill")
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
                                if isLoved == false {
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
                                    frontHasReceivedData = false
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
                                if isLoved == false {
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
                                    frontHasReceivedData = false
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
    
    func getAllBookmark() async throws {
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
        print(jsonData)
        for jbus in jsonData.buses {
            if jbus == bus {
                isLoved = true
                //print("Mảng chứa chuỗi \(bus)")
                // Thực hiện hành động cụ thể khi tìm thấy chuỗi '01'
            }
        }
    }
    func bookmark() async throws {
        //print("Đã vào hàm bookmark")
        let url = URL(string: "http://localhost:8000/add-bus-prefer")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        //print(token)
        
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization");
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type");
        
        let busName : BusName = BusName(bus: bus)
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
        print(jsonData.message)
    }
    
    func unbookmark() async throws {
        let url = URL(string: "http://localhost:8000/delete-bus-prefer")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization");
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type");
        let busName : BusName = BusName(bus: bus)
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
        print(jsonData.message)
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
