//
//  ChangePassword.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 06/12/2023.
//

import SwiftUI
struct PatchPassword : Codable {
    var email: String
    var oldPassword: String
    var newPassword: String
    var reNewPassword: String
    
    enum CodingKeys : CodingKey {
        case email
        case oldPassword
        case newPassword
        case reNewPassword
    }
}
struct ChangePassword: View {
    @State private var oldPassword: String = ""
    @State private var newPassword: String = ""
    @State private var reNewPassword: String = ""
    @Binding var email: String
    
    @State private var showOldPass: Bool = true
    @State private var showNewPass: Bool = true
    @State private var showReNewPass: Bool = true
    @State private var showingChangeMessageAlert = false
    @State private var changeMessage: String = ""
    @State private var showConfirmationAlert = false
    @Binding var isPresentingChangePass: Bool
    @EnvironmentObject var appData: AppData
   
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section {
                        ZStack(alignment: .trailing) {
                            Group {
                                if showOldPass {
                                    SecureField("Nhập mật khẩu hiện tại", text: $oldPassword)
                                } else {
                                    TextField("Nhập mật khẩu hiện tại", text: $oldPassword)
                                }
                            }.padding(.trailing, 32)
                            
                            Button(action: {
                                showOldPass.toggle()
                            }) {
                                Image(systemName: self.showOldPass ? "eye.slash" : "eye")
                                    .accentColor(.gray)
                            }
                        }
                    } header: {
                        Text("Nhập mật khẩu hiện tại")
                    }
                    
                    Section {
                        ZStack(alignment: .trailing) {
                            Group {
                                if showNewPass {
                                    SecureField("Nhập mật khẩu mới", text: $newPassword)
                                } else {
                                    TextField("Nhập mật khẩu mới", text: $newPassword)
                                }
                            }.padding(.trailing, 32)
                            
                            Button(action: {
                                showNewPass.toggle()
                            }) {
                                Image(systemName: self.showNewPass ? "eye.slash" : "eye")
                                    .accentColor(.gray)
                            }
                        }
                    } header: {
                        Text("Nhập mật khẩu mới")
                    }
                    
                    Section {
                        ZStack(alignment: .trailing) {
                            Group {
                                if showReNewPass {
                                    SecureField("Nhập lại mật khẩu mới", text: $reNewPassword)
                                } else {
                                    TextField("Nhập lại mật khẩu mới", text: $reNewPassword)
                                }
                            }.padding(.trailing, 32)
                            
                            Button(action: {
                                showReNewPass.toggle()
                            }) {
                                Image(systemName: self.showReNewPass ? "eye.slash" : "eye")
                                    .accentColor(.gray)
                            }
                        }
                    } header: {
                        Text("Nhập lại mật khẩu mới")
                    }
                }
            }
            .alert($changeMessage.wrappedValue, isPresented: $showingChangeMessageAlert) {
                Button("OK", role: .cancel) {
                    showingChangeMessageAlert = false
                }
            }
            .alert(isPresented: $showConfirmationAlert) {
                Alert(
                    title: Text("Xác nhận thay đổi"),
                    message: Text("Bạn có chắc chắn muốn thay đổi mật khẩu?"),
                    primaryButton: .destructive(Text("Đồng ý")) {
                        Task {
                            let patchPassword = PatchPassword(email: email, oldPassword: oldPassword, newPassword: newPassword, reNewPassword: reNewPassword)
                           
                            do {
                                try await changePass(patchPassword: patchPassword)
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    },
                    secondaryButton: .cancel(Text("Không"))
                )
            }
            .navigationTitle("Thay đổi mật khẩu")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        isPresentingChangePass = false
                    } label: {
                        Image(systemName: "arrowshape.backward.fill")
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        showConfirmationAlert = true
                    } label: {
                        Text("Lưu thay đổi")
                    }
                }
            }
            .accentColor(.red)
        }
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
        appData.token = jsonData.token
        changeMessage = "Đổi mật khẩu thành công"
        showingChangeMessageAlert = true
    }
}
