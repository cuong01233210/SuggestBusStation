//
//  SearchView.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 26/02/2024.
//



import SwiftUI
import MapKit


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
    @State private var searchResults: [ResultRoute] = []
    @State private var showError = false
    @State var selectedIndex = 0
    @State var isPresentingRouteDetail = false
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack {
                    VStack(spacing: 0) {
                        inputFields()
                            .frame(height: geometry.size.height * 0.25) // Adjust this value to change the space taken by input fields
                        Color.clear  // Invisible spacer
                            .frame(height: geometry.size.height * 0.05)
                        //                        MapView(region: $region)
                        //                        .edgesIgnoringSafeArea(.bottom)
                        
                        resultsList()
                        //.frame(height: geometry.size.height * 0.65)
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
        VStack(spacing: 0) {
            inputField(imageName: "location.circle", text: "Điểm xuất phát: \(appData.startPlace.name)", flag: 1)
            inputField(imageName: "mappin.circle", text: "Điểm đến: \(appData.endPlace.name)", flag: 2)
            
            routeButtons()
                .padding(.vertical, 8)
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
        .padding(4)
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
    
    private func resultCard(presentData: ResultRoute) -> some View {
        
        
        
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                ForEach(0..<presentData.buses.count, id: \.self) { index in
                    if presentData.buses[index] == "Walk" {
                        Image(systemName: "figure.walk")
                    } else {
                        Text(presentData.buses[index])
                            .foregroundColor(.blue) // Text color for bus numbers
                    }
                    // Display arrow except for the last item
                    if index < presentData.buses.count - 1 {
                        Image(systemName: "arrow.right")
                            .foregroundColor(.gray) // Color for arrow icons
                    }
                }
                Spacer()
            }
            
            HStack {
                Text("\(presentData.transportHour) giờ \(presentData.transportMinute) phút")
                    .foregroundColor(.black) // Primary text color
                Text(String(format: "%02d:%02d", presentData.startHour, presentData.startMinute))
                    .foregroundColor(.green)
                Image(systemName: "arrow.right")
                    .foregroundColor(.gray)
                Text(String(format: "%02d:%02d", presentData.endHour, presentData.endMinute))
                    .foregroundColor(.red)
            }
            
            Text("Trạm xuất phát: \(presentData.startStation)")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text("\(Int(presentData.cost)) đ")
                .foregroundColor(.green)
                .padding(.top, 8)
        }
        .padding() // Inner padding for content
        .background(Color.white) // Background color of the card
        .cornerRadius(10)
        .shadow(color: Color.gray.opacity(0.2), radius: 2, x: 0, y: 2)
        .padding(.horizontal, 5) // Outer padding to ensure 5px margin on both sides
        
    }
    private func resultsList() -> some View {
        Group {
            if !searchResults.isEmpty {
                VStack(alignment: .leading) {
                    Text("Kết quả tìm kiếm")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding([.horizontal, .top])
                    
                    List(0..<searchResults.count, id: \.self) { i in
                        HStack {
                            //ResultCard(presentData: searchResults[i])
                            resultCard(presentData: searchResults[i])
                                .onTapGesture {
                                    // Here, capture the current 'i' for the selected element
                                    selectedIndex = i
                                    isPresentingRouteDetail = true // Trigger the sheet
                                }
                        }
                    }
                    .fullScreenCover(isPresented: $isPresentingRouteDetail) {
                        RouteDetail(resultRoute: searchResults[selectedIndex], isPresentingRouteDetail: $isPresentingRouteDetail)
                    }
                    
                    .listStyle(PlainListStyle())
                }
                
            }
        }
    }
    
    func search() async throws {
        searchResults = []
        let url = URL(string: "http://localhost:8000/search-route")!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if appData.userTimeMode == 0 {
            let currentDate = Date()
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: currentDate)
            let minute = calendar.component(.minute, from: currentDate)
            print(hour, " ", minute)
            appData.userInputHour = hour
            appData.userInputMinute = minute
        }
        var inputData = InputData(startPlace: appData.startPlace, endPlace: appData.endPlace, searchMode: appData.searchMode, userInputHour: appData.userInputHour, userInputMinute: appData.userInputMinute)
        guard let encodedInputData = try? JSONEncoder().encode(inputData) else {
            return
        }
        let (data, response) = try await URLSession.shared.upload(for: urlRequest, from: encodedInputData)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            let errorData = try JSONDecoder().decode(ErrorData.self, from: data).message
            
            print("Error \(errorData)")
            throw URLError(.cannotParseResponse)
        }
        
        let jsonData = try JSONDecoder().decode(ResultRoutes.self, from: data)
        
        print(jsonData)
        searchResults = jsonData.resultRoutes
    }
    
    
}

