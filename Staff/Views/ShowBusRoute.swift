import SwiftUI

struct ShowBusRoute: View {
    @Binding var bus: String
    @Binding var showBusRoute: Bool
    @State var isLoved = false
    @State var hasReceivedData = false
    
    @State var chieuDi: [BusStation] = []
    @State var chieuVe: [BusStation] = []
    @State var showChieuDi = true
    
    @State var showDeleteAlert = false
    @EnvironmentObject var appData: AppData
    @State var updateBus = false
    
    var body: some View {
        if !hasReceivedData {
            NavigationView {
                ProgressView("Loading ...")
                    .onAppear {
                        Task {
                            do {
                                try await getData()
                                try await getAllBookmark()
                                hasReceivedData = true
                            } catch {
                                print("Error during data loading: \(error.localizedDescription)")
                            }
                        }
                    }
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarLeading) {
                            Button {
                                showBusRoute.toggle()
                            } label: {
                                Image(systemName: "arrowshape.backward.fill")
                            }
                        }
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
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
                    }
                    .accentColor(.red)
            }
        } else {
            NavigationView {
                if showChieuDi {
                    List(0..<chieuDi.count, id: \.self) { index in
                        VStack(alignment: .leading) {
                            Text(chieuDi[index].name)
                        }
                    }
                    .navigationTitle("Tuyến \(bus)")
                    .toolbar {
                        ToolbarItems
                    }
                    .accentColor(.red)
                    .fullScreenCover(isPresented: $updateBus) {
                        UpdateBus(updateBus: $updateBus, busName: $bus, chieuDi: chieuDi, chieuVe: chieuVe)
                    }
                } else {
                    List(0..<chieuVe.count, id: \.self) { index in
                        VStack(alignment: .leading) {
                            Text(chieuVe[index].name)
                        }
                    }
                    .navigationTitle("Tuyến \(bus)")
                    .toolbar {
                        ToolbarItems
                    }
                    .accentColor(.red)
                    .fullScreenCover(isPresented: $updateBus) {
                        UpdateBus(updateBus: $updateBus,  busName: $bus, chieuDi: chieuDi, chieuVe: chieuVe)
                    }
                }
            }
        }
    }
    
    var ToolbarItems: some ToolbarContent {
        Group {
            if appData.userRole == "1" {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Menu("Chọn chiều") {
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
                    Button {
                        updateBus.toggle()
                    } label : {
                        Image(systemName: "pencil.circle")
                    }
                }
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        appData.hasUpdatedPreBuses = false
                        showBusRoute.toggle()
                    } label: {
                        Image(systemName: "arrowshape.backward.fill")
                    }
                }
            } else {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if isLoved {
                        Image(systemName: "heart.fill")
                            .onTapGesture {
                                Task {
                                    do {
                                        try await unbookmark()
                                        DispatchQueue.main.async {
                                            isLoved = false
                                        }
                                    } catch {
                                        print("Error unbookmarking: \(error.localizedDescription)")
                                    }
                                }
                            }
                    } else {
                        Image(systemName: "heart")
                            .onTapGesture {
                                Task {
                                    do {
                                        try await bookmark()
                                        DispatchQueue.main.async {
                                            isLoved = true
                                        }
                                    } catch {
                                        print("Error bookmarking: \(error.localizedDescription)")
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
                        appData.hasUpdatedPreBuses = false
                        showBusRoute.toggle()
                    } label: {
                        Image(systemName: "arrowshape.backward.fill")
                    }
                }
            }
        }
    }
    
    func getData() async throws {
        let url = URL(string: "https://bus-station-server-production.up.railway.app/get-one-bus-data/\(bus)")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let errorData = try JSONDecoder().decode(ErrorData.self, from: data).message
            print("Error \(errorData)")
            throw URLError(.cannotParseResponse)
        }
        
        let jsonData = try JSONDecoder().decode(BusRoute.self, from: data)
        chieuDi = jsonData.chieuDi
        chieuVe = jsonData.chieuVe
    }
    
    func deleteBus(bus: String) async throws {
        let url = URL(string: "http://localhost:8000/delete-bus")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let busName = BusName(bus: bus)
        guard let encoded = try? JSONEncoder().encode(busName) else {
            print("Failed to encode busName")
            return
        }
        
        let (data, response) = try await URLSession.shared.upload(for: urlRequest, from: encoded)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let errorData = try JSONDecoder().decode(ErrorData.self, from: data).message
            print("Error \(errorData)")
            throw URLError(.cannotParseResponse)
        }
        
        let jsonData = try JSONDecoder().decode(Message.self, from: data)
      //  print(jsonData.message)
        
        showBusRoute.toggle()
        appData.loadDataBusesManage = 0
    }
    
    func bookmark() async throws {
        let url = URL(string: "http://localhost:8000/add-bus-prefer")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(appData.token)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let busName = BusName(bus: bus)
        guard let encoded = try? JSONEncoder().encode(busName) else {
            print("Failed to encode busName")
            return
        }
        
        let (data, response) = try await URLSession.shared.upload(for: urlRequest, from: encoded)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let errorData = try JSONDecoder().decode(ErrorData.self, from: data).message
            print("Error \(errorData)")
            throw URLError(.cannotParseResponse)
        }
        
        let jsonData = try JSONDecoder().decode(Message.self, from: data)
        
       // print(jsonData.message)
    }
    
    func unbookmark() async throws {
        let url = URL(string: "http://localhost:8000/delete-bus-prefer")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        urlRequest.setValue("Bearer \(appData.token)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let busName = BusName(bus: bus)
        guard let encoded = try? JSONEncoder().encode(busName) else {
            print("Failed to encode busName")
            return
        }
        
        let (data, response) = try await URLSession.shared.upload(for: urlRequest, from: encoded)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let errorData = try JSONDecoder().decode(ErrorData.self, from: data).message
            print("Error \(errorData)")
            throw URLError(.cannotParseResponse)
        }
        
        let jsonData = try JSONDecoder().decode(Message.self, from: data)
       // print(jsonData.message)
       
    }
    
    func getAllBookmark() async throws {
        let url = URL(string: "http://localhost:8000/get-all-bus-prefer")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Bearer \(appData.token)", forHTTPHeaderField: "Authorization");
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type");
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            let errorData = try JSONDecoder().decode(ErrorData.self, from: data).message
            print("Error \(errorData)")
            throw URLError(.cannotParseResponse)
        }
        let jsonData  = try JSONDecoder().decode(BusesName.self, from: data)
       // print(jsonData)
        for jbus in jsonData.sbuses {
            if jbus == bus {
                isLoved = true
                //print("Mảng chứa chuỗi \(bus)")
                // Thực hiện hành động cụ thể khi tìm thấy chuỗi '01'
            }
        }
    }
    
    
}

