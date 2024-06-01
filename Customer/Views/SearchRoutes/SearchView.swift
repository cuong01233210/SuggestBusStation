//
//  SearchView.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 26/02/2024.
//



import SwiftUI
import MapKit
struct SearchResult {
    var name: String
    var description: String
}

struct SearchView: View {
    @Binding var showSearchView : Bool
    @State private var startPoint = "Vị trí hiện tại"
    @State private var endPoint = ""
    @State private var showRouteOptions = false
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 21.028511, longitude: 105.804817),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @ObservedObject var locationManager = LocationManager.shared
    @State private var showInputView = false
    @EnvironmentObject var appData: AppData
    @State private var searchResults: [SearchResult] = []
    @State private var showError = false
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack {
                    VStack(spacing: 0) {
                        inputFields()
                            .frame(height: geometry.size.height * 0.3) // Adjust this value to change the space taken by input fields
                        Color.clear  // Invisible spacer
                            .frame(height: geometry.size.height * 0.05)
                        //                        MapView(region: $region)
                        //                        .edgesIgnoringSafeArea(.bottom)
                        
                        resultsList()
                            //.frame(height: geometry.size.height * 0.7) // Adjust this value to change the space taken by the map
                    }
                    .navigationTitle("Tìm đường")
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarLeading) {
                            backButton()
                        }
                    }
                    .sheet(isPresented: $showRouteOptions) {
                        SearchSetting()
                    }
                    .alert(isPresented: $showError) {
                        Alert(title: Text("Bạn cần nhập thêm dữ liệu"),
                              dismissButton: .default(Text("OK"))
                        )
                    }
                    .onAppear{
                        if let location = locationManager.userLocation {
                            appData.startPlace = Place(name: "Vị trí hiện tại", category: "", lat: location.coordinate.latitude, long: location.coordinate.longitude)
                        }
                       
                    }
                }
            }
        }
        
    }
    
    private func inputFields() -> some View {
        VStack {
            inputField(imageName: "location.circle", text: "Điểm xuất phát: \(appData.startPlace.name)", flag: 1)
            inputField(imageName: "mappin.circle", text: "Điểm đến: \(appData.endPlace.name)", flag: 2)
            routeButtons()
        }
    }
    
    private func inputField(imageName: String, text: String, flag: Int) -> some View {
        HStack {
            Image(systemName: imageName)
            Text(text)
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding()
        .onTapGesture {
            showInputView = true
            appData.inputFlag = flag
        }
        .fullScreenCover(isPresented: $showInputView) {
            InputView(showInputView: $showInputView)
        }
    }
    
    private func routeButtons() -> some View {
        HStack {
            Button("Tìm đường") {
                if appData.startPlace.lat != 0 && appData.endPlace.lat != 0 {
                    Task {
                        do {
                            try await search()
                        }
                        catch {
                            print("error")
                        }
                    }
                } else {
                    showError.toggle()
                }
                
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Button("Tùy chỉnh") {
                showRouteOptions.toggle()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
    
    private func backButton() -> some View {
        Button {
            appData.inputFlag = -1
            appData.startPlace = Place(name: "Vị trí hiện tại", category: "", lat: 0, long: 0)
            appData.endPlace = Place(name: "", category: "", lat: 0, long: 0)
            showSearchView.toggle()
        } label: {
            Image(systemName: "arrowshape.backward.fill")
        }
    }
    
    private func resultsList() -> some View {
        Group {
            if !searchResults.isEmpty {
                VStack(alignment: .leading) {
                    Text("Kết quả tìm kiếm")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding([.horizontal, .top])  // Đảm bảo có padding trên cùng và hai bên

                    List(searchResults, id: \.name) { result in
                        VStack(alignment: .leading) {
                            Text(result.name)
                                .font(.headline)
                            Text(result.description)
                                .font(.subheadline)
                        }
                    }
                    .listStyle(PlainListStyle())  // Để loại bỏ các khoảng cách và padding mặc định
                }
            }
        }
    }

    func search() async throws {
            let url = URL(string: "http://localhost:8000/search-route")!
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            var inputData = InputData(startPlace: appData.startPlace, endPlace: appData.endPlace)
            guard let encodedInputData = try? JSONEncoder().encode(inputData) else {
                return
            }
            let (data, response) = try await URLSession.shared.upload(for: urlRequest, from: encodedInputData)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                let errorData = try JSONDecoder().decode(ErrorData.self, from: data).message
                
                print("Error \(errorData)")
                throw URLError(.cannotParseResponse)
            }
            
            
//            let jsonData =  try JSONDecoder().decode(Todos.self, from: data)
//            print(jsonData.message)
//            todos = jsonData.todos
        }
           
      
}

