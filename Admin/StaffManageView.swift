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
   
    @State var searchText: String = ""
    @State var plusStaff : Bool = false
    var body: some View {
        if appData.needGetStaff == true && plusStaff == false{
            NavigationView{
                ProgressView("Loading ...")
                    .onAppear {
                        Task {
                            do {
                                try await getStaffs()
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
                VStack {
                    TextField("Tìm kiếm tài khoản", text: $searchText)
                        .padding(7)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    
                    List {
                        Section(header: Text("Danh sách tài khoản")) {
                            ForEach(filteredStaffs) { staff in
                                VStack(alignment: .leading) {
                                    Text("\(staff.email)")
                                        .bold()
                                        .font(.system(size: 20))
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
                
                    .navigationTitle("Quản lý nhân viên")
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
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
                            Button {
                                plusStaff.toggle()
                            } label : {
                                Image(systemName: "plus.square.on.square")
                            }
                        }
                    }.accentColor(.red)
                    .fullScreenCover(isPresented: $plusStaff) {
                        PlusStaff(plusStaff: $plusStaff)
                    }
            }
        }
        
        
    }
    var filteredStaffs : [Account] {
        if searchText.isEmpty {
            return appData.staffs
        } else {
            return appData.staffs.filter { $0.email.lowercased().contains(searchText.lowercased()) }
        }
    }
   
    func getStaffs() async throws{
        appData.staffs = []
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
        appData.staffs.append(contentsOf: jsonData)
        
        
    }
    
    
    
}


