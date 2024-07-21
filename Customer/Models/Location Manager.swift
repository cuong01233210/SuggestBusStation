//
//  Location Manager.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 31/08/2023.
//

import CoreLocation

class LocationManager: NSObject, ObservableObject{
    private let manager = CLLocationManager()
    @Published var userLocation : CLLocation?
    static let shared = LocationManager()

    override init(){
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()
    }

    func requestLocation(){
        manager.requestWhenInUseAuthorization()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

        switch status {
        case .notDetermined:
            print("Debug: Not determinded")
        case .restricted:
            print("Debug: Restricted")
        case .denied:
            print("Debug: Denied")
        case .authorizedAlways:
            print("Debug: Auth always")
        case .authorizedWhenInUse:
            print("Debug: Auth when in use")
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return }
        self.userLocation = location
        print("Latitude: \(location.coordinate.latitude), Longitude: \(location.coordinate.longitude)")
        //print(self.userLocation)
    }
}


