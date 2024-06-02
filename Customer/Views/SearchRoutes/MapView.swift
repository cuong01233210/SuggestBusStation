//
//  MapView.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 20/09/2023.
//

import MapKit
import SwiftUI
import UIKit




import SwiftUI
import MapKit

struct LocationPickerView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 21.028511, longitude: 105.804817), // Tọa độ của Hà Nội
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @ObservedObject var locationManager = LocationManager.shared
    @Binding var showInputView : Bool
    @Binding var showLocationPicker : Bool
    @EnvironmentObject var appData: AppData
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack(alignment: .center) {
                    MapView(region: $region)
                        .edgesIgnoringSafeArea(.all)
                    
                    // Hiển thị hình ảnh marker
                    Image(systemName: "circle.fill")
                        .foregroundColor(.blue)
                        .opacity(0.5)
                        .frame(width: 30, height: 30)
                }
                
                Button("Chọn địa điểm") {
                    //print("Chosen latitude: \(region.center.latitude)")
                    //print("Chosen longitude: \(region.center.longitude)")
                    if appData.inputFlag == 1 {
                        appData.startPlace = Place(name: "Vị trí bản đồ", category: "", lat: region.center.latitude, long: region.center.longitude)
                    } else {
                        appData.endPlace = Place(name: "Vị trí bản đồ", category: "", lat: region.center.latitude, long: region.center.longitude)
                    }
                    showLocationPicker = false
                    showInputView.toggle()
                }
                .frame(width: 280, height: 44)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(22)
                .padding()
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        showLocationPicker.toggle()
                    } label: {
                        Image(systemName: "arrowshape.backward.fill")
                    }
                }
            }
            .accentColor(.red)
            .onAppear {
                updateCurrentRegion()
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

struct MapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.setRegion(region, animated: true)
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(region, animated: true)
    }
}
