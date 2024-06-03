import SwiftUI

struct RouteDetail: View {
    let resultRoute: ResultRoute
    @State private var selectedTab: Int = 0
    @Binding var isPresentingRouteDetail: Bool
    
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
            }
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
                        if returnRoute.buses[0] == "Walk"{
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
