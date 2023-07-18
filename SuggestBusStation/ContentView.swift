//
//  ContentView.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 10/06/2023.
//

import SwiftUI

struct BusStation: Codable {
    var name: String
    var bus: [String]
    var lat: Double
    var long: Double
    var district: String
    var id: String
}

struct BusStations: Codable {
    var busStations: [BusStation]
}

struct UserCoordinate: Codable {
    var id: String
    var lat: Double
    var long: Double
    
    init(id: String, lat: Double, long: Double) {
        self.id = id
        self.lat = lat
        self.long = long
    }
}

struct UserStartString: Codable{
    var id: String
    var startString: String
    
    init(id: String, startString: String) {
        self.id = id
        self.startString = startString
    }
}

struct UserEndString: Codable{
    var id: String
    var endString: String
    
    init(id: String, endString: String) {
        self.id = id
        self.endString = endString
    }
}
struct ContentView: View {
    @State private var busStations: BusStations?
    @State private var startString: String = ""
    @State private var endString: String = ""
    @State private var searchText: String = ""
    @State private var inputLatStr: String = ""
    @State private var inputLongStr : String = ""
    @State private var inputLat: Double = 0.0
    @State private var inputLong : Double = 0.0

    var body: some View {
        VStack(spacing: 20) {
            Text(busStations?.busStations[0].name ?? "bus station name")
                .bold()
                .font(.title)
            Text(busStations?.busStations[0].bus[0] ?? "unknown bus")
                .bold()
                .font(.title)
            Text(String(busStations?.busStations[0].lat ?? 0))
                .bold()
                .font(.title)

            Text("hello")
                .bold()
                .font(.title)
        }
        .padding()
        .task {
            do {
                busStations = try await getBusStations()
            } catch BSError.invalidURL {
                print("invalid url")
            } catch BSError.invalidResponse {
                print("invalid response")
            } catch BSError.invalidData {
                print("invalid data")
            } catch {
                print("unexpected error")
            }
        }
        
        VStack {
            TextField("Nhập điểm đến", text: $startString)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Nhập điểm đích", text: $endString)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Search") {
                searchText = "\(startString) - \(endString)"
                
                Task {
                        let userStartString = UserStartString(id: "1", startString: startString)
                        do {
                            try await patchUserStartString(userStartString: userStartString)
                        } catch {
                            print("Error: \(error)")
                        }
                    }
                Task {
                        let userEndString = UserEndString(id: "1", endString: endString)
                        do {
                            try await patchUserEndString(userEndString: userEndString)
                        } catch {
                            print("Error: \(error)")
                        }
                    }
            }
            Text(searchText)
                        .bold()
                        .font(.title)
                        .padding()
                
        }
        
        VStack {
            TextField("Nhập latitude", text: $inputLatStr)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Nhập longitude", text: $inputLongStr)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Search") {
                if let lat = Double(inputLatStr), let long = Double(inputLongStr) {
                    let userCoordinate = UserCoordinate(id: "change-coordinate", lat: lat, long: long)
                    
                    Task {
                        do {
                            try await patchUserCoordinate(userCoordinate: userCoordinate)
                        } catch {
                            print("Error: \(error)")
                        }
                    }
                }
            }

            Text(searchText)
                        .bold()
                        .font(.title)
                        .padding()
                
        }
    }
    
    func getBusStations() async throws -> BusStations {
        let endpoint = "http://127.0.0.1:8000/bus-stations-data"
        
        guard let url = URL(string: endpoint) else {
            throw BSError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw BSError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(BusStations.self, from: data)
        } catch {
            throw BSError.invalidData
        }
    }
    
    func patchUserCoordinate(userCoordinate: UserCoordinate) async throws {
        let url = URL(string: "http://localhost:8000/user-coordinate/\(userCoordinate.id)")!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PATCH"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let encodedUserCoordinate = try? JSONEncoder().encode(userCoordinate) else {
            return
        }
        
        let (data, response) = try await URLSession.shared.upload(for: urlRequest, from: encodedUserCoordinate)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw URLError(.cannotParseResponse)
        }
        
        let decoder = JSONDecoder()
        let updatedUserCoordinate = try decoder.decode(UserCoordinate.self, from: data)
        
        print("Updated user coordinate: \(updatedUserCoordinate)")
    }
    
    func patchUserStartString(userStartString: UserStartString) async throws {
            let url = URL(string: "http://localhost:8000/user-start-string/\(userStartString.id)")!
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "PATCH"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            guard let encodedUserStartString = try? JSONEncoder().encode(userStartString) else {
                return
            }
            
            let (data, response) = try await URLSession.shared.upload(for: urlRequest, from: encodedUserStartString)
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw URLError(.cannotParseResponse)
            }
            
            let decoder = JSONDecoder()
            let updatedUserStartString = try decoder.decode(UserStartString.self, from: data)
            
           // print("Updated user coordinate: \(updatedUserCoordinate)")
        }
    
    func patchUserEndString(userEndString: UserEndString) async throws {
                let url = URL(string: "http://localhost:8000/user-end-string/\(userEndString.id)")!
                
                var urlRequest = URLRequest(url: url)
                urlRequest.httpMethod = "PATCH"
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                guard let encodedUserEndString = try? JSONEncoder().encode(userEndString) else {
                    return
                }
                
                let (data, response) = try await URLSession.shared.upload(for: urlRequest, from: encodedUserEndString)
                
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw URLError(.cannotParseResponse)
                }
                
                let decoder = JSONDecoder()
                let updatedUserEndString = try decoder.decode(UserEndString.self, from: data)
                
               // print("Updated user coordinate: \(updatedUserCoordinate)")
            }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

enum BSError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}
