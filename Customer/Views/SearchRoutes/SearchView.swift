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
        center: CLLocationCoordinate2D(latitude: 21.028511, longitude: 105.804817), // Tọa độ của Hà Nội
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @ObservedObject var locationManager = LocationManager.shared
    @State private var showInputView = false
   // @State private var inputFlag = 0 //cờ để quyết định xem là người dùng cập nhật start hay end
    @EnvironmentObject var appData: AppData
    
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    HStack {
                        Image(systemName: "location.circle")
                        Text("Điểm xuất phát: \(appData.startPlace.name)")
                        Spacer() // Pushes all content to the left
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding()
                    .onTapGesture {
                        showInputView = true
                        appData.inputFlag = 1
                    }
                    .fullScreenCover(isPresented: $showInputView) {
                       InputView(showInputView: $showInputView)
                    }
                    
                    
                    HStack {
                        Image(systemName: "mappin.circle")
                        Text("Điểm đến: \(appData.endPlace.name)")
                        Spacer() // Pushes all content to the left
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding()
                    .onTapGesture {
                        showInputView = true
                        appData.inputFlag = 2
                    }
                    .fullScreenCover(isPresented: $showInputView) {
                       InputView(showInputView: $showInputView)
                    }
                    
                    HStack {
                        Button("Tìm đường") {
                            // Kích hoạt tìm đường
                        }
                        .padding()
                        .foregroundColor(.green)
                        .cornerRadius(10)
                        .padding()
                        
                        Button("Tùy chỉnh") {
                            showRouteOptions.toggle()
                        }
                    }
                    
                    
                }
                MapView(region: $region)
                    .edgesIgnoringSafeArea(.bottom)
                    .frame(height: 400)
                //Spacer()
            }
            .sheet(isPresented: $showRouteOptions) {
                // View để tùy chỉnh các lựa chọn tìm đường
                Text("Tùy chỉnh tìm đường")
            }
            .navigationTitle("Tìm đường")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        appData.inputFlag = -1 // reset về trạng thái chưa dùng search
                        appData.startPlace.name = "Vị trí hiện tại"
                        showSearchView.toggle()
                    } label: {
                        Image(systemName: "arrowshape.backward.fill")
                    }
                }
            }
            .accentColor(.red)
            .onAppear {
                updateCurrentRegion()
                if appData.inputFlag == -1 {
                    appData.inputFlag = 0 // chuyển vào trạng thái đang dùng tính năng search -> bảo lưu dữ liệu người dùng nhập khi chuyển View
                }
            }
        }
        
    }
    private func updateCurrentRegion() {
        if let location = locationManager.userLocation {
            region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
    }
}




