//
//  ContentView.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 10/06/2023.
//

import SwiftUI
import MapKit
import UIKit
struct ErrorData: Codable {
    var message: String
    init(message: String) {
        self.message = message
    }
}

struct OutputData: Codable{
    var route: String
    var stationStartName: String
    var stationEndName: String
    var distanceInMeters : Double
    var stationStartLat: Double
    var stationStartLong: Double
    var stationEndLat: Double
    var stationEndLong: Double
    
    init(route: String, stationStartName: String, stationEndName: String, distanceInMeters: Double, stationStartLat: Double, stationStartLong: Double, stationEndLat: Double, stationEndLong: Double) {
        self.route = route
        self.stationStartName = stationStartName
        self.stationEndName = stationEndName
        self.distanceInMeters = distanceInMeters
        self.stationStartLat = stationStartLat
        self.stationStartLong = stationStartLong
        self.stationEndLat = stationEndLat
        self.stationEndLong = stationEndLong
    }
}

struct MapInput {
    var outputData : OutputData
    var userLat: Double
    var userLong: Double
    var userLocationName: String
    
    init(outputData: OutputData, userLat: Double, userLong: Double, userLocationName: String) {
        self.outputData = outputData
        self.userLat = userLat
        self.userLong = userLong
        self.userLocationName = userLocationName
    }
}
struct ContentView: View{
    @State var outputData : OutputData = OutputData(route: "test", stationStartName: "test", stationEndName: "test", distanceInMeters: 0, stationStartLat: 0.0, stationStartLong: 0.0, stationEndLat: 0.0, stationEndLong: 0.0)

    
    @ObservedObject var locationManager = LocationManager.shared
    var body: some View{
        Group {
            if locationManager.userLocation == nil {
                LocationRequestView()
            }
            else {
                if let location = locationManager.userLocation {
                    NavigationView{
                        VStack {
                            InputScreen(outputData: $outputData)
                            NavigationLink(destination: ContentMapView(outputData: $outputData, userLat: location.coordinate.latitude, userLong: location.coordinate.longitude), label: {Text("NextPage")})
                        }
                    }
                }
            }
        }
    }
    
    
}
struct InputScreen: View {
    // Các biến @State và các phương thức khác...
    @State private var busStations: BusStations?
    @State private var startString: String = ""
    @State private var endString: String = ""
    @State private var searchText: String = ""
    
    @State private var inputUserKm : String = ""
    @State private var userKm : Double = 0.0
    @State private var showingAlert : Bool = false
    @State private var alertTitle : String = ""
    @State private var alertText : String = ""
    @State private var startStationText: String = ""
    @State private var endStationText: String = ""
    @Binding var outputData: OutputData
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Tìm kiếm")) {
                    TextField("Nhập điểm xuất phát", text: $startString)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(10)
                    
                    TextField("Nhập điểm đến", text: $endString)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(10)
                    
                    TextField("Nhập số Km cách trạm xe buýt tối đa cách điểm đến", text: $inputUserKm)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(10)
                    
                    Button("Search") {
                        searchText = "\(startString) - \(endString)"
                        
                        Task{
                            if let userKm1 = Double(inputUserKm){
                                userKm = userKm1
                            }
                            else {
                                userKm = 10000
                            }
                            let userString = UserString(id: "1", startString: startString, endString: endString, userKm: userKm)
                            do{
                                try await updateUserString(userString: userString)
                            }
                            catch{
                                print("Error: \(error)")
                            }
                        }
                        
                    }
                    

                    Text("Trạm xuất phát: \(startStationText)")
                        .bold()
                        .padding()
                    
                    Text("Trạm đích đến: \(endStationText)")
                        .bold()
                        .padding()
                }
                

            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text(alertTitle), message: Text(alertText))
        }
    }
    func updateUserString(userString: UserString) {
        let url = URL(string: "http://localhost:8000/user-input-string/")!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PATCH"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //urlRequest.timeoutInterval = 90 // Đặt thời gian chờ tối đa là 30 giây
        
        guard let encodedUserString = try? JSONEncoder().encode(userString) else {
            return
        }
        
        URLSession.shared.uploadTask(with: urlRequest, from: encodedUserString) { data, response, error in
            do {
                if let error = error {
                    throw error // Rethrow the error to handle it
                }
                
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    if let data = data {
                            do {
                                let errorData = try JSONDecoder().decode(ErrorData.self, from: data).message
                                alertText = errorData
                                alertTitle = "Lỗi"
                                showingAlert = true
                                print(errorData)
                            } catch {
                                print("can't parse json to show error")
                            }

                    }
                    throw URLError(.cannotParseResponse)
                }
                
                // If the request is successful, you can handle the response data here if needed.
                if let data = data {
                    do {
                        print("vào được chỗ request thành công rồi")
                        let outputData = try JSONDecoder().decode(OutputData.self, from: data)
                        // print("Updated user data: \(updatedUserString)")
                        
                        self.outputData = outputData
                        print("Output data: \(self.outputData)")
                        self.startStationText = self.outputData.stationStartName
                        self.endStationText = self.outputData.stationEndName
                    } catch {
                        print("Error decoding response data: \(error)")
                    }
                }
            } catch {
                print("Error: \(error)")
            }
        }.resume()
    }
    
    
    
    
    
    
    //struct ContentView_Previews: PreviewProvider {
    //    static var previews: some View {
    //        InputScreen()
    //    }
    //}

    
    
    
}


struct ContentMapView: View {

  @State private var directions: [String] = []
  @State private var showDirections = false
    @Binding var outputData : OutputData
    @State var userLat: Double
    @State var userLong: Double
  var body: some View {
    VStack {
        MapView(directions: $directions, outputData: $outputData, userLat: userLat, userLong: userLong)

      Button(action: {
        self.showDirections.toggle()
      }, label: {
        Text("Show directions")
      })
      .disabled(directions.isEmpty)
      .padding()
    }.sheet(isPresented: $showDirections, content: {
      VStack(spacing: 0) {
        Text("Directions")
          .font(.largeTitle)
          .bold()
          .padding()

        Divider().background(Color(UIColor.systemBlue))

        List(0..<self.directions.count, id: \.self) { i in
          Text(self.directions[i]).padding()
        }
      }
    })
  }
}

struct MapView: UIViewRepresentable {

  typealias UIViewType = MKMapView

  @Binding var directions: [String]
    @Binding var outputData: OutputData
    @State var userLat: Double
    @State var userLong: Double
  func makeCoordinator() -> MapViewCoordinator {
      
    return MapViewCoordinator()
  }

  func makeUIView(context: Context) -> MKMapView {
      print("output data trong mapview", self.outputData)
    let mapView = MKMapView()
    mapView.delegate = context.coordinator

    let region = MKCoordinateRegion(
      center: CLLocationCoordinate2D(latitude: 40.71, longitude: -74),
      span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    mapView.setRegion(region, animated: true)

    // trạm xuất phát
      let p1 = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: self.outputData.stationStartLat, longitude: self.outputData.stationStartLong))
      // đánh dấu marker để hiển thị tên địa điểm
      let p1Annotation = MKPointAnnotation()
             p1Annotation.coordinate = CLLocationCoordinate2D(latitude: self.outputData.stationStartLat, longitude: self.outputData.stationStartLong)
             p1Annotation.title = "Start Station"
             mapView.addAnnotation(p1Annotation)

      
     
    // trạm đích
      let p2 = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: self.outputData.stationEndLat, longitude: self.outputData.stationEndLong))

      let p2Annotation = MKPointAnnotation()
              p2Annotation.coordinate = CLLocationCoordinate2D(latitude: self.outputData.stationEndLat, longitude: self.outputData.stationEndLong)
              p2Annotation.title = "End Station"
              mapView.addAnnotation(p2Annotation)
      
      // vị trí hiện tại của người dùng
      let p3 = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: userLat, longitude: userLong))
      let p3Annotation = MKPointAnnotation()
              p3Annotation.coordinate = CLLocationCoordinate2D(latitude: userLat, longitude: userLong)
              p3Annotation.title = "Your Location"
              mapView.addAnnotation(p3Annotation)
      
    let request = MKDirections.Request()
    request.source = MKMapItem(placemark: p3)
    request.destination = MKMapItem(placemark: p1)
    request.transportType = .automobile

    let directions = MKDirections(request: request)
    directions.calculate { response, error in
      guard let route = response?.routes.first else { return }
      //mapView.addAnnotations([p3, p1, p2])
      mapView.addOverlay(route.polyline)
      mapView.setVisibleMapRect(
        route.polyline.boundingMapRect,
        edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20),
        animated: true)
      self.directions = route.steps.map { $0.instructions }.filter { !$0.isEmpty }
    }
    return mapView
  }

  func updateUIView(_ uiView: MKMapView, context: Context) {
  }

  class MapViewCoordinator: NSObject, MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
      let renderer = MKPolylineRenderer(overlay: overlay)
      renderer.strokeColor = .systemBlue
      renderer.lineWidth = 5
      return renderer
    }
  }
}

