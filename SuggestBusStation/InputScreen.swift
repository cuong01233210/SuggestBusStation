
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


class AppData: ObservableObject {
    @Published var outputData: OutputData
    @Published var userLat: Double
    @Published var userLong: Double

    init() {
        self.outputData = OutputData(
            route: "test",
            stationStartName: "test",
            stationEndName: "test",
            distanceInMeters: 0,
            stationStartLat: 21.0,
            stationStartLong: 105.0,
            stationEndLat: 21.1,
            stationEndLong: 105.1
        )
        self.userLat = 21
        self.userLong = 105
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
struct HomeView: View{
    
    @EnvironmentObject var appData: AppData
    @ObservedObject var locationManager = LocationManager.shared
    @Binding var isLoggedIn : Bool
    @Binding var token: String
    var body: some View{
        Group {
            if locationManager.userLocation == nil {
                LocationRequestView()
            }
            else {
                if let location = locationManager.userLocation {
//                MainScreen()
//                    VStack {
//                        InputScreen(outputData: $outputData, outputData2: $outputData2)
//                    }
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
    @Binding var outputData2: OutputData2
    @EnvironmentObject var appData: AppData
    @State private var isPresentingAnotherView = false
    @State private var isPresentingContentMapView2 = false
    @State var presentDatas : [PresentData] = []
    @State var selectedIndex = 0
    
    @Binding var isPresentingInputScreen: Bool
    
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
                            presentDatas = []
                            if let userKm1 = Double(inputUserKm){
                                userKm = userKm1
                            }
                            else {
                                userKm = 10000
                            }
                            let userString = UserString(id: "1", startString: startString, endString: endString, userKm: userKm)
                            do{
                                try await findBusStations(userString: userString)
                                //appData.outputData = self.outputData
                            }
                            catch{
                                print("Error: \(error)")
                            }
                        }
                        
                    }
                    
                  
//                    Text("Trạm xuất phát: \(startStationText)")
//                        .bold()
//                        .padding()
//
//                    Text("Trạm đích đến: \(endStationText)")
//                        .bold()
//                        .padding()

                    List (0..<presentDatas.count, id: \.self) { i in
                        CardView(presentData: presentDatas[i], isPresentingContentMapView2: $isPresentingContentMapView2)
                            .onTapGesture {
                                    // Here, capture the current 'i' for the selected element
                                selectedIndex = i
                                    isPresentingContentMapView2 = true // Trigger the sheet
                                }
                    }
                    .fullScreenCover(isPresented: $isPresentingContentMapView2) {
                        ContentMapView2(isPresentingContentMapView2: $isPresentingContentMapView2, presentData: presentDatas[selectedIndex])
                    }
                }
            }
            Spacer()
            Button("Quay lại trang chủ") {
                isPresentingInputScreen = false
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text(alertTitle), message: Text(alertText))
        }
    }
  func findBusStations(userString: UserString){
        let url = URL(string: "http://localhost:8000/find-bus-station-v1")!
        
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
                        let outputData2 = try JSONDecoder().decode(OutputData2.self, from: data)
                        // print("Updated user data: \(updatedUserString)")
                        
                        self.outputData2 = outputData2
                       // appData.outputData = outputData
                        print("Output data: \(self.outputData2)")
                        for index in 0..<outputData2.minDistancesStations.count {
                           // print(index)
                            var presentData : PresentData = PresentData(startLocation: outputData2.startLocation, startDistance: outputData2.startDistance, route: outputData2.minRoutes[index], endStation: outputData2.minDistancesStations[index], startLocationLat: outputData2.startLocationLat, startLocationLong: outputData2.startLocationLong, startStationLat: outputData2.startStationLat, startStationLong: outputData2.startStationLong)
                            presentDatas.append(presentData)
                        }
                        print(presentDatas)
                       // self.startStationText = self.outputData.stationStartName
                      //  self.endStationText = self.outputData.stationEndName
 
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
    @EnvironmentObject var appData: AppData
    @Binding var outputData: OutputData
    @Binding var outputData2: OutputData2
    @State var userLat: Double
    @State var userLong: Double
  @State var presentDatas: [PresentData] = []
 
  var body: some View {
    VStack {
      MapView(directions: $directions, userLat: userLat, userLong: userLong, outputData: outputData)
            
      Button(action: {
        self.showDirections.toggle()
      }, label: {
        Text("Hiển thị đường đi")
      })
      .disabled(directions.isEmpty)
      .padding()
    }.sheet(isPresented: $showDirections, content: {
      VStack(spacing: 0) {
        Text("Đường đi")
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
    @EnvironmentObject var appData: AppData
  @Binding var directions: [String]
    @State var userLat: Double
    @State var userLong: Double
    @State var outputData: OutputData
    
    
  func makeCoordinator() -> MapViewCoordinator {
    return MapViewCoordinator()
  }

  func makeUIView(context: Context) -> MKMapView {
      print("user lat long", userLat, userLong)
      print("outputData: ", outputData)
    let mapView = MKMapView()
    mapView.delegate = context.coordinator

    let region = MKCoordinateRegion(
      center: CLLocationCoordinate2D(latitude: 21, longitude: 105),
      span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    mapView.setRegion(region, animated: true)

    // start location
      let p1Coordinate = CLLocationCoordinate2D(latitude: userLat, longitude: userLong)
      let p1 = MKPlacemark(coordinate: p1Coordinate)

      let p1Annotation = MKPointAnnotation()
      p1Annotation.coordinate = p1Coordinate
      p1Annotation.title = "Start Location"

      // Sau đó, thêm p1Annotation vào bản đồ của bạn
      mapView.addAnnotation(p1Annotation)
      mapView.showsPointsOfInterest = true

      
    // end location
      let p2Coordinate = CLLocationCoordinate2D(latitude: outputData.stationStartLat, longitude: outputData.stationStartLong)
      let p2 = MKPlacemark(coordinate: p2Coordinate)

      let p2Annotation = MKPointAnnotation()
      p2Annotation.coordinate = p2Coordinate
      p2Annotation.title = "Start Station"

      // Sau đó, thêm p2Annotation vào bản đồ của bạn
      mapView.addAnnotation(p2Annotation)

   

      mapView.showsPointsOfInterest = true
      mapView.showsUserLocation = true

    let request = MKDirections.Request()
    request.source = MKMapItem(placemark: p1)
    request.destination = MKMapItem(placemark: p2)
      request.transportType = .automobile

    let directions = MKDirections(request: request)
    directions.calculate { response, error in
      guard let route = response?.routes.first else { return }
     // mapView.addAnnotations([p1, p2])
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
    // Lớp coordinator để xử lý sự kiện của bản đồ
  class MapViewCoordinator: NSObject, MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        // Tạo renderer để vẽ overlay là đường đi trên bản đồ
      let renderer = MKPolylineRenderer(overlay: overlay)
      renderer.strokeColor = .systemBlue  // Màu sắc của đường đi
      renderer.lineWidth = 5 // Độ rộng của đường đi
      return renderer
    }
  }
}
