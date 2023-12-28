//
//  ChangeNormalIn4.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 24/12/2023.
//


import SwiftUI

struct RadioButton {
    @State var flagA = false
    @State var flagB = false
    
    var body: some View{
        VStack{
            List{
                HStack {
                    Image(systemName: flagA ?
                          "checkmark.circle.fill": "circle")
                    Text("Male");
                }.onTapGesture {
                    flagA = true
                    flagB = false
                }
                
                HStack {
                    Image(systemName: flagB ?
                          "checkmark.circle.fill": "circle")
                    Text("Female");
                }.onTapGesture {
                    flagB = true
                    flagA = false
                }
            }
        }
    }
}
struct ChangeNormalIn4: View {
    @State private var name = ""
    @State private var sex = ""
    @State private var birthdate = Date()
    @State private var shouldSendNewsletter = false
    @State private var numberOfLikes = 1
    @State private var phoneNumber = ""
    @State var isPresentingChangePass: Bool = false
    @Binding var email: String
    @Binding var token: String
    
    @State var showChangeDb = false
    @State var male = false
    @State var female = false
    @Binding var isChangePersonIn4 : Bool
    @Binding var hasReceivedData : Bool
    
    @State private var alertMessage: String?
    @State private var isShowingAlert = false
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Họ và tên", text: $name)
                    Text("Giới tính")
//                    VStack{
//                        List{
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
//                            }
//                        }
                    }
                    DatePicker("Ngày sinh", selection: $birthdate, displayedComponents: .date)
                    TextField("Số điện thoại", text: $phoneNumber)
                } header: {
                    Text("Personal Information")
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
                    
                    //Button("Save", action: saveUser)
                    Button {
                        Task {
                            do {
                                try await saveUser()
                            }catch {
                                
                            }
                        }
                    } label: {
                        Text("Save")
                    }
                    // Hiển thị cảnh báo
                            .alert(isPresented: $isShowingAlert) {
                                Alert(
                                    title: Text("Thông báo"),
                                    message: Text(alertMessage ?? ""), // Hiển thị thông báo thành công hoặc lỗi
                                    dismissButton: .default(Text("OK"))
                                )
                            }

                }
                
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button{
                        isChangePersonIn4.toggle()
                        hasReceivedData.toggle()
                    } label: {
                        Image(systemName: "arrowshape.backward.fill")
                    }
                }
            }
            
            .accentColor(.red)
        }
        
    }
    func saveUser() async throws{
        //print("User Saved")
        //print(name)
        if male {
            sex = "Male"
            print("male")
        } else {
            sex = "Female"
            print("female")
        }
        //print(birthdate)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let formattedDate = dateFormatter.string(from: birthdate)
       // print("Ngày: \(formattedDate)")
        //print(phoneNumber)
        
        var userIn4: UserIn4 = UserIn4(
            name: name,
            sex: sex,
            dateOfBirth: formattedDate,
            phoneNumber: phoneNumber,
            email: email
        )
        print(userIn4)
        let url = URL(string: "http://localhost:8000/update-user-infor")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PATCH"
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization");
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type");
        
        guard let encoded = try? JSONEncoder().encode(userIn4) else {
            return
        }
        let (data, response) = try await URLSession.shared.upload(for: urlRequest, from: encoded)
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    let errorData = try JSONDecoder().decode(ErrorData.self, from: data).message
                    
                    print("Error \(errorData)")
                    alertMessage = errorData
                    isShowingAlert.toggle()
                    throw URLError(.cannotParseResponse)
                }
        let jsonData =  try JSONDecoder().decode(Message.self, from: data)
                print(jsonData.message)
        alertMessage = jsonData.message
        isShowingAlert.toggle()
        
    }
}

