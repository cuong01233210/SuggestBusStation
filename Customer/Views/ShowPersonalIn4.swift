//
//  ShowPersonalIn4.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 24/12/2023.
//

import SwiftUI

struct ShowPersonalIn4: View {
    @Binding var isPresentingPersonalIn4: Bool
    @State private var fullName = "fullName"
    @State private var sex = "Sex"
    @State private var birthdate = "Date"
    @State private var phoneNumber = "01234556"
    @State var isPresentingChangePass: Bool = false
    @State var isChangePersonIn4 : Bool = false
    @Binding var email: String
    @Binding var token: String
    
    @State var showChangeDb = false
    @State private var hasReceivedData = false
    var body: some View {
        if !hasReceivedData {
            ProgressView("Loading...")
                .onAppear {
                    Task {
                        do {
                            try await getInfor()
                            hasReceivedData = true
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
        } else {
            NavigationView {
                Form {
                    Section {
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
                                    ChangeNormalIn4(email: $email, token: $token, isChangePersonIn4: $isChangePersonIn4, hasReceivedData: $hasReceivedData)
                                }
                        }
                        
                        HStack {
                            Image(systemName: "bus.fill")
                            Text("Đổi mật khẩu")
                                .onTapGesture {
                                    isPresentingChangePass.toggle()
                                }
                                .fullScreenCover(isPresented: $isPresentingChangePass) {
                                    ChangePassword(email: $email, token: $token, isPresentingChangePass: $isPresentingChangePass)
                                }
                        }
                        
                        
                    } header: {
                        Text("Thay đổi thông tin")
                    }
                    
                }
                //            .onAppear {
                //                Task {
                //                    do {
                //                        try await getInfor()
                //                    } catch {
                //                        print(error.localizedDescription)
                //                    }
                //                }
                //            }
                .task  {
                    do {
                        try await getInfor()
                        hasReceivedData = true
                    } catch {
                        //showError = true
                        print(error.localizedDescription)
                        
                    }
                    
                }
                .accentColor(.red)
                .navigationTitle("Account")
                .toolbar{
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button{
                            print("hello")
                        } label: {
                            Image(systemName: "keyboard.chevron.compact.down")
                        }
                        
                        Button("Save") {
                            Task {
                                do {
                                    try await getInfor()
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        }
                        
                    }
                    
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button{
                            isPresentingPersonalIn4.toggle()
                            hasReceivedData.toggle()
                        } label: {
                            Image(systemName: "arrowshape.backward.fill")
                        }
                    }
                }
                .accentColor(.red)
            }
        }
    }
    func getInfor() async throws{
        let url = URL(string: "http://localhost:8000/getInfor")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization");
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type");
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
        print("jsonData")
        print(jsonData)
        $fullName.wrappedValue = jsonData.name
        $sex.wrappedValue = jsonData.sex
        $birthdate.wrappedValue = jsonData.dateOfBirth
        $phoneNumber.wrappedValue = jsonData.phoneNumber
    }
    func saveUser(){
        print("User Saved")
    }
}


//#Preview {
//    ShowPersonalIn4()
//}
