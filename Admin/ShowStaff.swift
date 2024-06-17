//
//  ShowStaff.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 17/6/24.
//

import SwiftUI

struct ShowStaff: View {
    @Binding var showStaff: Bool
    @State var hasReceivedData : Bool = false
    @State private var fullName = "fullName"
    @State private var sex = "Sex"
    @State private var birthdate = "Date"
    @State private var phoneNumber = "01234556"
    @EnvironmentObject var appData: AppData
    @Binding var selectedStaff : Account
    @State var showDeleteAlert = false
    @State var isChangePersonIn4 = false
    @State var isPresentingChangePass = false
    var body: some View {
        if hasReceivedData == false {
            NavigationView {
                ProgressView("Loading ...")
                    .onAppear {
                        Task {
                            do {
                                try await getInfor()
                                // Set hasReceivedData only after the data is received
                                hasReceivedData = true
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarLeading) {
                            Button {
                                showStaff.toggle()
                            } label: {
                                Image(systemName: "arrowshape.backward.fill")
                            }
                        }
                    }.accentColor(.red)
            }
        } else {
            NavigationView{
                Form {
                    Section {
                        Text("Email: \(selectedStaff.email)")
                        Text("Họ và tên: \(fullName)")
                        Text("Giới tính: \(sex)")
                        Text("Ngày sinh: \(birthdate)")
                        Text("Số điện thoại: \(phoneNumber)")
                        
                    } header: {
                        Text("Thông tin cơ bản")
                    }
                    Section{
                        HStack {
                            Image(systemName: "person")
                            Text("Thay đổi thông tin cơ bản")
                                .onTapGesture {
                                    isChangePersonIn4.toggle()
                                }
                                .fullScreenCover(isPresented: $isChangePersonIn4) {
                                    ChangeNormalIn4(email: $selectedStaff.email, token: $appData.token, isChangePersonIn4: $isChangePersonIn4, hasReceivedData: $hasReceivedData)
                                }
                        }
                        
                        HStack {
                            Image(systemName: "lock")
                            Text("Đổi mật khẩu")
                                .onTapGesture {
                                    isPresentingChangePass.toggle()
                                }
                                .fullScreenCover(isPresented: $isPresentingChangePass) {
                                    ChangePassword(email: $selectedStaff.email,  isPresentingChangePass: $isPresentingChangePass)
                                }
                        }
                        
                        
                    } header: {
                        Text("Thay đổi thông tin")
                    }
                    
                }
                    .navigationTitle("Thông tin nhân viên")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                showStaff.toggle()
                            } label: {
                                Image(systemName: "arrowshape.backward.fill")
                            }
                        }
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
                            Button {
                                showDeleteAlert.toggle()
                            } label: {
                                Image(systemName: "trash")
                            }
                            .alert(isPresented: $showDeleteAlert) {
                                Alert(
                                    title: Text("Xóa tuyến"),
                                    message: Text("Bạn có chắc muốn xóa tuyến này?"),
                                    primaryButton: .destructive(Text("OK")) {
                                        Task {
                                            do {
                                                try await deleteStaff()
                                            } catch {
                                                print("Error deleting: \(error)")
                                            }
                                        }
                                    },
                                    secondaryButton: .cancel()
                                )
                            }
                        }
                    }.accentColor(.red)
                    
            }
        }
    }
    
    func getInfor() async throws {
        let url = URL(string: "http://localhost:8000/auth/get-staff-infor")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST" // Changed to POST to match the backend route
        urlRequest.setValue("Bearer \(appData.token)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: String] = ["email": selectedStaff.email]
        guard let encoded = try? JSONSerialization.data(withJSONObject: requestBody) else {
            print("Failed to encode request body")
            return
        }
        urlRequest.httpBody = encoded

        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            let errorData = try JSONDecoder().decode(ErrorData.self, from: data).message
            print("Error \(errorData)")
            throw URLError(.cannotParseResponse)
        }
        print("data: \(data)")
        if let jsonString = String(data: data, encoding: .utf8) {
            print(jsonString)
        }

        let jsonData = try JSONDecoder().decode(UserIn4.self, from: data)
        $fullName.wrappedValue = jsonData.name
        $sex.wrappedValue = jsonData.sex
        $birthdate.wrappedValue = jsonData.dateOfBirth
        $phoneNumber.wrappedValue = jsonData.phoneNumber
        
        
       
    }

    func deleteStaff() async throws {
        let url = URL(string: "http://localhost:8000/auth/delete-staff")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(appData.token)", forHTTPHeaderField: "Authorization")
        let requestBody: [String: String] = ["email": selectedStaff.email]
        guard let encoded = try? JSONEncoder().encode(requestBody) else {
            print("Failed to encode request body")
            return
        }
        
        let (data, response) = try await URLSession.shared.upload(for: urlRequest, from: encoded)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let errorData = try JSONDecoder().decode(ErrorData.self, from: data).message
            print("Error \(errorData)")
            throw URLError(.cannotParseResponse)
        }
        
        let jsonData = try JSONDecoder().decode(Message.self, from: data)
      //  print(jsonData.message)
        appData.needGetStaff = true
        showStaff.toggle()
        appData.loadDataBusesManage = 0
    }
    
    
}

