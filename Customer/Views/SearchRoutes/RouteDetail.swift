import SwiftUI


func haversineDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
    let R = 6371000.0 // Earth radius in meters
    let dLat = (lat2 - lat1) * .pi / 180
    let dLon = (lon2 - lon1) * .pi / 180
    let a = sin(dLat / 2) * sin(dLat / 2) +
    cos(lat1 * .pi / 180) * cos(lat2 * .pi / 180) *
    sin(dLon / 2) * sin(dLon / 2)
    let c = 2 * atan2(sqrt(a), sqrt(1 - a))
    return R * c
}

struct RouteDetail: View {
    let resultRoute: ResultRoute
    @State private var selectedTab: Int = 0
    @Binding var isPresentingRouteDetail: Bool
    @State private var notifiedRoutes: Set<String> = []
    @State private var showErrorForm = false
    @State private var currentReturnRoute: ReturnRoute?
    @ObservedObject var locationManager = LocationManager.shared
    @State private var isChoosen = true
    @State private var nearDestinationStationAlert = false
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button(action: {
                        selectedTab = 0
                    }) {
                        Text("Chi tiết cách đi")
                            .foregroundColor(selectedTab == 0 ? .white : .blue)
                            .padding()
                            .background(selectedTab == 0 ? Color.blue : Color.clear)
                            .cornerRadius(8)
                    }
                    Button(action: {
                        selectedTab = 1
                    }) {
                        Text("Các trạm đi qua")
                            .foregroundColor(selectedTab == 1 ? .white : .blue)
                            .padding()
                            .background(selectedTab == 1 ? Color.blue : Color.clear)
                            .cornerRadius(8)
                    }
                }
                
                if selectedTab == 0 {
                    detailRouteView()
                } else {
                    stationListView()
                }
            }
            .navigationTitle("Chi tiết lộ trình")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    backButton()
                }
            }.accentColor(.red)
        }
    }
    
    private func detailRouteView() -> some View {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        
        return List {
            ForEach(resultRoute.returnRoutes, id: \.id) { returnRoute in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Đi từ: ")
                            .foregroundColor(.green)
                            .bold()
                        Text(returnRoute.source)
                            .foregroundColor(.black)
                    }
                    
                    HStack {
                        Text("Đi tới: ")
                            .foregroundColor(.red)
                            .bold()
                        Text(returnRoute.destination)
                            .foregroundColor(.black)
                    }
                    
                    HStack {
                        Text("Phương thức di chuyển: ")
                            .foregroundColor(.yellow)
                            .bold()
                        if returnRoute.buses[0] == "Walk" || returnRoute.buses[0] == "walk"{
                            Text("Đi bộ")
                                .foregroundColor(.black)
                        } else {
                            Text("Tuyến \(returnRoute.buses[0])")
                                .foregroundColor(.black)
                        }
                        
                    }
                    
                    HStack {
                        let distance = returnRoute.transportS
                        if distance > 1000 {
                            let distanceInKm = Double(distance) / 1000
                            let formattedDistance = formatter.string(from: NSNumber(value: distanceInKm)) ?? "\(distanceInKm)"
                            Text("Quãng đường: \(formattedDistance) km")
                                .foregroundColor(.black)
                        } else {
                            Text("Quãng đường: \(distance) m")
                                .foregroundColor(.black)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            let transportTime = returnRoute.transportTime
                            if transportTime >= 60 {
                                let hours = transportTime / 60
                                let minutes = transportTime % 60
                                Text("Thời gian: \(hours)h \(minutes) phút")
                                    .foregroundColor(.black)
                            } else {
                                Text("Thời gian: \(transportTime) phút")
                                    .foregroundColor(.black)
                            }
                        }
                    }
                }
                
                
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .shadow(radius: 2)
            }
            // .listRowInsets(EdgeInsets()) // Removes default insets
        }
        .onReceive(locationManager.$userLocation) { location in
            if let userLocation = location {
                for returnRoute in resultRoute.returnRoutes {
                    let destinationDistance = haversineDistance(
                        lat1: userLocation.coordinate.latitude,
                        lon1: userLocation.coordinate.longitude,
                        lat2: returnRoute.destinationLat,
                        lon2: returnRoute.destinationLong
                    )
                    print("\n")
                    print("userlocation: \(userLocation)")
                    print("destinationName: \(returnRoute.destination)")
                    print("destination: \(returnRoute.destinationLat); \(returnRoute.destinationLong)")
                    print("distance: \(destinationDistance)")
                    print("\(notifiedRoutes)")
                    if destinationDistance <= 2000 && !notifiedRoutes.contains(returnRoute.destination) && isChoosen {
                        print("Đã gần đến trạm \(returnRoute.destination) - khoảng cách: \(destinationDistance)") // Thêm log để kiểm tra
                        //DispatchQueue.main.async {
                            notifiedRoutes.insert(returnRoute.destination)
                            nearDestinationStationAlert = true
                            currentReturnRoute = returnRoute
                            print("Alert will be shown for \(returnRoute.destination)")
                        //}
                        break
                    }
                }
            }
        }

        .alert(isPresented: $nearDestinationStationAlert) {
            Alert(
                title: Text("Thông báo"),
                message: Text("Bạn đã gần đến trạm \(currentReturnRoute?.destination ?? ""), nếu bạn muốn báo lỗi thì ấn vào nút 'Báo lỗi' hoặc ấn OK để bỏ qua "),
                primaryButton: .default(Text("OK"), action: {
                    nearDestinationStationAlert = false
                }),
                secondaryButton: .default(Text("Báo lỗi"), action: {
                    nearDestinationStationAlert = false
                    showErrorForm = true
                })
            )
        }
        .sheet(isPresented: $showErrorForm) {
                    if let returnRoute = currentReturnRoute {
                        ErrorFormView(returnRoute: returnRoute)
                    }
                }
        .listStyle(PlainListStyle()) // Use a plain list style
    }
    
    @ViewBuilder
    private func stationListView() -> some View {
        List(resultRoute.stations, id: \.self) { station in
            Text(station)
        }.listStyle(PlainListStyle())
    }
    
    private func backButton() -> some View {
        Button {
            isPresentingRouteDetail.toggle()
        } label: {
            Image(systemName: "arrowshape.backward.fill")
        }
    }
}
