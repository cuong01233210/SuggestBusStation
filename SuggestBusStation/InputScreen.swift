//
//  ContentView.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 10/06/2023.
//

import SwiftUI
import GoogleMaps
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
struct ContentView: View{
    @State var outputData : OutputData
    var body: some View{
        
        NavigationView{
            VStack {
                InputScreen(outputData: $outputData)
                NavigationLink(destination: ContentMapView(outputData: $outputData), label: {Text("NextPage")})
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
    @State private var inputLatStr: String = ""
    @State private var inputLongStr : String = ""
    @State private var inputLat: Double = 0.0
    @State private var inputLong : Double = 0.0
    @State private var inputUserKm : String = ""
    @State private var userKm : Double = 0.0
    @State private var showingAlert : Bool = false
    @State private var alertTitle : String = ""
    @State private var alertText : String = ""
    
    @Binding var outputData: OutputData
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Tìm kiếm")) {
                    TextField("Nhập điểm đến", text: $startString)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    TextField("Nhập điểm đích", text: $endString)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    TextField("Nhập số Km cách trạm xe buýt tối đa cách điểm đến", text: $inputUserKm)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
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
                    
                    Text(searchText)
                        .bold()
                        .font(.title)
                        .padding()
                }
                
                Section(header: Text("Tìm kiếm theo tọa độ")) {
                    TextField("Nhập latitude", text: $inputLatStr)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    TextField("Nhập longitude", text: $inputLongStr)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Button("Search") {
                        // Xử lý khi nhấn nút Search theo tọa độ...
                        if let lat = Double(inputLatStr), let long = Double(inputLongStr) {
                            let userCoordinate = UserCoordinate(id: "change-coordinate", lat: lat, long: long)
                            
                            
                        }
                    }
                    
                    Text(searchText)
                        .bold()
                        .font(.title)
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
  var body: some View {
    VStack {
        MapView(directions: $directions, outputData: $outputData)

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

    // điểm xuất phát
      let p1 = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: self.outputData.stationStartLat, longitude: self.outputData.stationStartLong))

    // điểm đích
      let p2 = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: self.outputData.stationEndLat, longitude: self.outputData.stationEndLong))

    let request = MKDirections.Request()
    request.source = MKMapItem(placemark: p1)
    request.destination = MKMapItem(placemark: p2)
    request.transportType = .automobile

    let directions = MKDirections(request: request)
    directions.calculate { response, error in
      guard let route = response?.routes.first else { return }
      mapView.addAnnotations([p1, p2])
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
