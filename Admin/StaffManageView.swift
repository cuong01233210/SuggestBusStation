//
//  StaffManageView.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 14/6/24.
//

import SwiftUI

struct StaffManageView: View {
    @Binding var presentStaffManageView : Bool
    @EnvironmentObject var appData: AppData
    @State var staffs: [Account] = []
    var body: some View {
        if appData.needGetStaff == true {
            NavigationView{
                ProgressView("Loading ...")
                    .onAppear {
                        Task {
                            do {
                                try await getBuses()
                                // Set hasReceivedData only after the data is received
                                appData.needGetStaff = false
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarLeading) {
                            Button {
                                presentStaffManageView.toggle()
                            } label: {
                                Image(systemName: "arrowshape.backward.fill")
                            }
                        }
                    }.accentColor(.red)
            }
        } else{
            NavigationView {
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                    .navigationTitle("Admin")
                    .toolbar{
                        ToolbarItemGroup(placement: .navigationBarLeading) {
                            Button{
                                presentStaffManageView.toggle()
                            } label: {
                                Image(systemName: "arrowshape.backward.fill")
                            }
                        }
                    }
                    .accentColor(.red)
            }
        }
        
        
    }
    func getBuses() async throws{
        staffs = []
        let url = URL(string: "http://localhost:8000/auth/get-staffs")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Bearer \(appData.token)", forHTTPHeaderField: "Authorization");
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type");
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            let errorData = try JSONDecoder().decode(ErrorData.self, from: data).message
            print("Error \(errorData)")
            throw URLError(.cannotParseResponse)
        }
//        if let jsonString = String(data: data, encoding: .utf8) {
//            print("Response JSON: \(jsonString)")
//        }

        let jsonData = try JSONDecoder().decode([Account].self, from: data)
       // print("jsonData")
        staffs.append(contentsOf: jsonData)
        print(staffs)
    }
    
}


