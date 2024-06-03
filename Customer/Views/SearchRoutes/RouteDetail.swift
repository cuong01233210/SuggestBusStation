//
//  RouteDetail.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 3/6/24.
//

import SwiftUI

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
        
        return List(resultRoute.returnRoutes, id: \.id) { returnRoute in
            VStack(alignment: .leading, spacing: 8) {
                if returnRoute.buses[0] == "Walk" {
                    Text("Đi bộ từ \(returnRoute.source) đến \(returnRoute.destination)")
                } else {
                    Text("Đi tuyến \(returnRoute.buses[0]) từ \(returnRoute.source) đến \(returnRoute.destination)")
                }
                Text("Thời gian: \(returnRoute.transportTime) phút")
                
                let distance = returnRoute.transportS
                if distance > 1000 {
                    let distanceInKm = Double(distance) / 1000
                    let formattedDistance = formatter.string(from: NSNumber(value: distanceInKm)) ?? "\(distanceInKm)"
                    Text("Quãng đường: \(formattedDistance) km")
                } else {
                    Text("Quãng đường: \(distance) mét")
                }
            }
            .padding()
        }
    }



    @ViewBuilder
    private func stationListView() -> some View {
        List(resultRoute.stations, id: \.self) { station in
            Text(station)
        }
    }
    
    private func backButton() -> some View {
        Button {
            isPresentingRouteDetail.toggle()
        } label: {
            Image(systemName: "arrowshape.backward.fill")
        }
    }
}

