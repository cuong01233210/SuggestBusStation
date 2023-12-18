//
//  ChangePassword.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 06/12/2023.
//

import SwiftUI
struct PatchPassword : Codable{
    var email: String
    var oldPassword: String
    var newPassword: String
    
    enum CodingKeys : CodingKey {
        case email
        case oldPassword
        case newPassword
    }
}
struct ChangePassword: View {
    @State private var oldPassword: String = "";
    @State private var newPassword: String = "";
    @Binding private var email: String;
    @Binding private var token: String
    @State private var showOldPass: Bool = true
    @State private var showNewPass: Bool = true
    @State private var showingChangeMessageAlert = false
    @State private var changeMessage: String = ""
    @Binding private var isPresentingChangePass: Bool
   // @State private var patchPassword: PatchPassword? = nil
    init(email: Binding<String>, token: Binding<String>, isPresentingChangePass: Binding<Bool>) {
            self._email = email
            self._token = token
            self._isPresentingChangePass = isPresentingChangePass
        }
    var body: some View {
        
        VStack(alignment: .leading){
            Text("Nhập mật khẩu hiện tại")
                .font(.title) // Đặt kích thước font là title
            ZStack(alignment: .trailing){
                Group{
                    if showOldPass{
                        SecureField("Nhập mật khẩu hiện tại", text: $oldPassword)
                            .font(.title) // Đặt kích thước font là title
                            //.frame( height: 40) // Đặt kích thước theo ý muốn
                    }else {
                        TextField("Nhập mật khẩu hiện tại", text: $oldPassword)
                            .font(.title) // Đặt kích thước font là title
                           // .frame(height: 40) // Đặt kích thước theo ý muốn
                    }
                }.padding(.trailing, 32)
                
                Button(action: {
                    showOldPass.toggle()
                }) {
                    Image(systemName: self.showOldPass ? "eye.slash" : "eye")
                                    .accentColor(.gray)
                }
            }
        }
       // Spacer()
        VStack (alignment: .leading){
            Text("Nhập mật khẩu mới")
                .font(.title) // Đặt kích thước font là title
            ZStack(alignment: .trailing){
                Group{
                    if showNewPass{
                        SecureField("Nhập mật khẩu mới", text: $newPassword)
                            .font(.title) // Đặt kích thước font là title
                          //  .frame(height: 40) // Đặt kích thước theo ý muốn
                    }else {
                        TextField("Nhập mật khẩu mới", text: $newPassword)
                            .font(.title) // Đặt kích thước font là title
                            //.frame(height: 40) // Đặt kích thước theo ý muốn
                    }
                }.padding(.trailing, 32)
                
                Button(action: {
                    showNewPass.toggle()
                }) {
                    Image(systemName: self.showNewPass ? "eye.slash" : "eye")
                                    .accentColor(.gray)
                }
            }
        }
       // Spacer()
        Button {
            Task{
                let patchPassword = PatchPassword(email: email, oldPassword: oldPassword, newPassword: newPassword)
                print("old password: \(patchPassword.oldPassword)")
                print("new password: \(patchPassword.newPassword)")
                print("email: \(patchPassword.email)")
                do{
                    try await changePass(patchPassword: patchPassword)
                } catch {
                    print(error.localizedDescription)
                    //print("Change password error: \(error)")
                }
                
            }
        } label: {
            Text("Change password")
                .font(.title) // Đặt kích thước font là title
        }
        Button("Đóng") {
            isPresentingChangePass = false
        }
        .alert($changeMessage.wrappedValue, isPresented: $showingChangeMessageAlert) {
                    Button("OK", role: .cancel) {
                        showingChangeMessageAlert = false
                    }
                }
                   // Text("You entered: \(password)")
    }
    private func changePass(patchPassword: PatchPassword) async throws {
        let url = URL(string: "http://localhost:8000/change-password")!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PATCH"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let encoded = try? JSONEncoder().encode(patchPassword) else {
            return
        }
        let (data, response) = try await URLSession.shared.upload(for: urlRequest, from: encoded)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            let errorData = try JSONDecoder().decode(ErrorData.self, from: data).message
            changeMessage = errorData
            showingChangeMessageAlert = true
            print("Error \(errorData)")
            throw URLError(.cannotParseResponse)
        }
        let jsonData = try JSONDecoder().decode(LoggedInUser.self, from: data)
        token = jsonData.token
        changeMessage = "Đổi mật khẩu thành công"
        showingChangeMessageAlert = true

        //isLoggedIn = true
    }
    
}
