import SwiftUI

struct ShowDataBusStation: View {
    @Binding var showDataBusStation: Bool
    
    @Binding var busStation: BusStation
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
   // @State private var newStation = BusStation(name: "", buses: [], lat: 0.0, long: 0.0, id: "")
    @State var newStation: BusStation = BusStation(name: "", buses: [], lat: 0, long: 0)
    @State private var isLoved = false
    @EnvironmentObject var appData: AppData
    
    var body: some View {
        Group {
            if !editedSetup {
                LoadingView
            } else {
                ContentView
            }
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
    
    private var LoadingView: some View {
        NavigationView {
            ProgressView("Loading ...")
                .onAppear{
                    Task {
                        newStation.name = busStation.name
                        newStation.buses = busStation.buses
                        newStation.lat = busStation.lat
                        newStation.long = busStation.long
                      //  newStation.id = busStation.id
                        editedSetup = true
                        do {
                            try await getAllBookmark()
                        }catch {
                            print(error.localizedDescription)
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            
                            //showDataBusStation.toggle()
                        } label: {
                            Image(systemName: "arrowshape.backward.fill")
                        }
                    }
                }
                .accentColor(.red)
        }
    }
    
    private var ContentView: some View {
        NavigationView {
            List {
                Section(header: Text("Tên trạm")) {
                    if isEditing {
                        TextEditor(text: $editedName)
                    } else {
                        Text(newStation.name)
                    }
                }
                Section(header: Text("Các tuyến xe buýt đi qua")) {
                    if isEditing {
                        TextEditor(text: $editedBus)
                    } else {
                        ForEach(0..<newStation.buses.count, id: \.self) { index in
                            if index % 5 == 0 {
                                let endIndex = Swift.min(index + 5, newStation.buses.count)
                                let chunk = newStation.buses[index..<endIndex]
                                Text("Danh sách tuyến: \(chunk.joined(separator: ", "))")
                            }
                        }
                    }
                }
                Section(header: Text("Toạ độ của trạm")) {
                    if isEditing {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Toạ độ latitude")
                                TextEditor(text: $editedLat)
                            }
                            HStack {
                                Text("Toạ độ longitude")
                                TextEditor(text: $editedLong)
                            }
                        }
                    } else {
                        VStack(alignment: .leading) {
                            Text("Toạ độ latitude: \(newStation.lat)")
                            Text("Toạ độ longitude: \(newStation.long)")
                        }
                    }
                }
            }
            .navigationTitle("Thông tin chi tiết")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        appData.hasUpdatedPreStations = false
                        showDataBusStation.toggle()
                    } label: {
                        Image(systemName: "arrowshape.backward.fill")
                    }
                }
                if appData.userRole == "1"{
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            if isEditing {
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
                                            Task {
                                                do {
                                                    try await update()
                                                } catch {
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
                                    if isEditing == false {
                                        editedName = busStation.name
                                        editedBus = busStation.buses.joined(separator: ", ")
                                        editedLat = String(busStation.lat)
                                        editedLong = String(busStation.long)
                                        isEditing = true
                                    }
                                    else {
                                        isEditing = false
                                    }
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
                    }
                    
                }else if appData.userRole == "0" {
                    ToolbarItem(placement: .navigationBarTrailing){
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
                }
            }
            .accentColor(.red)
        }
    }
    
    private func setupEditedStation() {
        newStation.name = busStation.name
        newStation.buses = busStation.buses
        newStation.lat = busStation.lat
        newStation.long = busStation.long
       // newStation.id = busStation.id
        editedSetup = true
    }
    
    func update() async throws {
        let url = URL(string: "https://bus-station-server-production.up.railway.app/update-bus-station")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PATCH"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let busNumbers = editedBus.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
        var newLat: Double = 0.0
        var newLong: Double = 0.0
        
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
        newStation.buses = busNumbers
        newStation.lat = newLat
        newStation.long = newLong
        
        
        guard let encoded = try? JSONEncoder().encode(newStation) else {
            return
        }
        
        let (data, response) = try await URLSession.shared.upload(for: urlRequest, from: encoded)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            let errorData = try JSONDecoder().decode(ErrorData.self, from: data).message
            print("Error \(errorData)")
            throw URLError(.cannotParseResponse)
        }
        appData.loadDataStationsManage = false
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
        
        let jsonData = try JSONDecoder().decode(Message.self, from: data)
        
        appData.loadDataStationsManage = false
        showDataBusStation.toggle()
    }
    func getAllBookmark() async throws {
        let url = URL(string: "http://localhost:8000/get-all-stations-prefer")!
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
        let jsonData  = try JSONDecoder().decode(UserStationIds.self, from: data)
        print(jsonData)
        for jId in jsonData.stationIds {
            if jId == busStation.id {
                isLoved = true
                //print("Mảng chứa chuỗi \(bus)")
                // Thực hiện hành động cụ thể khi tìm thấy chuỗi '01'
            }
        }
    }
    func bookmark() async throws {
        //print("Đã vào hàm bookmark")
        let url = URL(string: "http://localhost:8000/add-station-prefer")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        //print(token)
        
        urlRequest.setValue("Bearer \(appData.token)", forHTTPHeaderField: "Authorization");
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
        urlRequest.setValue("Bearer \(appData.token)", forHTTPHeaderField: "Authorization");
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

