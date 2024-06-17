//
//  PlusStaff.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 16/6/24.
//

import SwiftUI

struct PlusStaff: View {
    @State var email = ""
    @State var password = ""
    @State var name = ""
    @State var sex = ""
    @State private var birthdate = Date()
    @State private var phoneNumber = ""
    @Binding var plusStaff : Bool
    @EnvironmentObject var appData : AppData
    @State var successAlert: Bool = false
    @State var showPass = false
    @State var male = false
    @State var female = false
    @State var errorMessage = ""
    @State var showingErrorMessageAlert = false
    var body: some View {
        NavigationView{
            List {
                Section {
                    TextField("Nhập email", text: $email)
                } header: {
                    Text("Nhập email")
                }
                Section {
                    ZStack(alignment: .trailing) {
                        Group {
                            if showPass {
                                SecureField("Nhập mật khẩu", text: $password)
                            } else {
                                TextField("Nhập mật khẩu", text: $password)
                            }
                        }.padding(.trailing, 32)
                        
                        Button(action: {
                            showPass.toggle()
                        }) {
                            Image(systemName: self.showPass ? "eye.slash" : "eye")
                                .accentColor(.gray)
                        }
                    }
                } header: {
                    Text("Nhập mật khẩu")
                }
                Section {
                    TextField("Nhập họ tên nhân viên", text: $name)
                } header: {
                    Text("Nhập họ tên nhân viên")
                }
                Section {
                    Text("Giới tính")
                    
                    HStack {
                        Image(systemName: male ?
                              "checkmark.circle.fill": "circle")
                        Text("Male");
                    }.onTapGesture {
                        male = true
                        female = false
                    }
                    
                    HStack {
                        Image(systemName: female ?
                              "checkmark.circle.fill": "circle")
                        Text("Female");
                    }.onTapGesture {
                        male = false
                        female = true
                        
                    }
                } header: {
                    Text("Lựa chọn giới tính")
                }
                Section {
                    DatePicker("Ngày sinh", selection: $birthdate, displayedComponents: .date)
                } header: {
                    Text("Nhập ngày sinh")
                }
                Section {
                    TextField("Nhập số điện thoại", text: $phoneNumber)
                } header: {
                    Text("Nhập số điện thoại")
                }
            } .navigationTitle("Thêm nhân viên")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button {
                            plusStaff.toggle()
                        } label : {
                            Image(systemName: "arrowshape.backward.fill")
                        }
                    }
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button {
                            Task {
                                do {
                                    try await createNewStaff()
                                } catch {
                                    print("Error: \(error)")
                                }
                            }
                        } label: {
                            Text("Lưu")
                        }
                    }
                }.accentColor(.red)
                .alert(isPresented: $successAlert) {
                    Alert(
                        title: Text("Thông báo"),
                        message: Text("Bạn đã thêm một nhân viên thành công"),
                        dismissButton: .default(Text("OK"))
                    )
                }
                .alert($errorMessage.wrappedValue, isPresented: $showingErrorMessageAlert) {
                    Button("OK", role: .cancel) {
                        showingErrorMessageAlert = false
                    }
                }
        }
    }
    
    func createNewStaff() async throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let dateOfBirth = dateFormatter.string(from: birthdate)
        
        if male == true {
            sex = "Nam"
        } else {
            sex = "Nữ"
        }
        let url = URL(string: "http://localhost:8000/auth/add-staff")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var newStaff = FullAccountInfo(id: "", email: email, password: password, role: "1", name: name, sex: sex, dateOfBirth: dateOfBirth, phoneNumber: phoneNumber)
        guard let encoded = try? JSONEncoder().encode(newStaff) else {
            return
        }
        let (data, response) = try await URLSession.shared.upload(for: urlRequest, from: encoded)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            let errorData = try JSONDecoder().decode(ErrorData.self, from: data).message
            print("Error \(errorData)")
            errorMessage = errorData
            showingErrorMessageAlert.toggle()
            throw URLError(.cannotParseResponse)
        }
        let jsonData = try JSONDecoder().decode(Message.self, from: data)
        appData.needGetStaff = true
        
        successAlert = true
        
    }
}

