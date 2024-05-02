//
//  MapView.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 20/09/2023.
//

import MapKit
import SwiftUI
import UIKit

//struct ContentMapView2: View {
//    @Binding var isPresentingContentMapView2 : Bool
//  @State private var directions: [String] = []
//  @State private var showDirections = false
//  
//    var presentData: PresentData
//  var body: some View {
//      VStack {
//          MapView2(directions: $directions, presentData: presentData)
//          
//          HStack {
//              
//              Button(action: {
//                  self.showDirections.toggle()
//              }, label: {
//                  Text("Hiển thị đường đi")
//              })
//              .disabled(directions.isEmpty)
//              .padding()
//          }.sheet(isPresented: $showDirections, content: {
//              VStack(spacing: 0) {
//                      Text("Đường đi")
//                          .font(.largeTitle)
//                          .bold()
//                          .padding()
//                      
//                  Divider().background(Color(UIColor.systemBlue))
//                  
//                  List(0..<self.directions.count, id: \.self) { i in
//                      Text(self.directions[i]).padding()
//                  }
//              }
//          })
//          Button("Đóng") {
//              isPresentingContentMapView2 = false
//          }
//      }
//  }
//}
//
//struct MapView2: UIViewRepresentable {
//
//  typealias UIViewType = MKMapView
//
//  @Binding var directions: [String]
//    var presentData : PresentData
//  func makeCoordinator() -> MapViewCoordinator {
//    return MapViewCoordinator()
//  }
//
//  func makeUIView(context: Context) -> MKMapView {
//      //print("presentData", presentData)
//    let mapView = MKMapView()
//    mapView.delegate = context.coordinator
//
//    let region = MKCoordinateRegion(
//      center: CLLocationCoordinate2D(latitude: 21, longitude: 105),
//      span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
//    mapView.setRegion(region, animated: true)
//
//    // Start Location
//      let p1 = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: presentData.startLocationLat, longitude: presentData.startLocationLong))
//
//    // End Location
//      let p2 = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: presentData.startStationLat, longitude: presentData.startStaionLong))
//
//    let request = MKDirections.Request()
//    request.source = MKMapItem(placemark: p1)
//    request.destination = MKMapItem(placemark: p2)
//    request.transportType = .automobile
//
//    let directions = MKDirections(request: request)
//    directions.calculate { response, error in
//      guard let route = response?.routes.first else { return }
//      mapView.addAnnotations([p1, p2])
//      mapView.addOverlay(route.polyline)
//      mapView.setVisibleMapRect(
//        route.polyline.boundingMapRect,
//        edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20),
//        animated: true)
//      self.directions = route.steps.map { $0.instructions }.filter { !$0.isEmpty }
//    }
//    return mapView
//  }
//
//  func updateUIView(_ uiView: MKMapView, context: Context) {
//  }
//
//  class MapViewCoordinator: NSObject, MKMapViewDelegate {
//    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//      let renderer = MKPolylineRenderer(overlay: overlay)
//      renderer.strokeColor = .systemBlue
//      renderer.lineWidth = 5
//      return renderer
//    }
//  }
//}

//struct ContentView_Previews: PreviewProvider {
//  static var previews: some View {
//    ContentView()
//  }
//}


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
