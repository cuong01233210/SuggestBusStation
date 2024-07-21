//
//  LoginView.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 28/09/2023.
//

import SwiftUI



struct AuthenticationView: View {
    @State private var showSignUp = true
    @State private var nameField: String = ""
    @State private var emailField : String = ""
    @State private var passwordField : String = ""
    @State private var loginUser: LoginUser? = nil
    
    @Binding var isLoggedIn: Bool
    @Binding var token : String
    @State var showPass: Bool = false
    @Binding var email: String
    @State var showingAlert: Bool = false
    @State var errorMessage = "Bạn đã đăng nhập thất bại"
//    @Binding var role: String
    @EnvironmentObject var appData: AppData
    var body: some View {
        VStack {
            Button(action: {
                showSignUp.toggle()
            }) {
                Text(showSignUp ? "Nếu đã có tài khoản" : "Nếu chưa có tài khoản")
                    .font(.title) // You can adjust the font size as needed
                    .foregroundColor(.blue) // You can set the text color as needed
            }

            
            if showSignUp {
                TextField("Name", text: $nameField)
                    .padding()
                    .font(.system(size: 20))
            }
            
            TextField("Email", text: $emailField)
                .padding()
                .font(.system(size: 20))
                .autocapitalization(.none)
            
            ZStack (alignment: .trailing){
                Group {
                    if showPass{
                        TextField("Password", text: $passwordField)
                            .padding()
                            .font(.system(size: 20))
                            .autocapitalization(.none)
                    } else {
                        SecureField("Password", text: $passwordField)
                            .padding()
                            .font(.system(size: 20))
                            .autocapitalization(.none)
                    }
                }
                Button(action: {
                    showPass.toggle()
                }) {
                    Image(systemName: self.showPass ? "eye.slash" : "eye")
                        .accentColor(.gray)
                }
            }.padding(.trailing, 32)
            

            Button(action: {
                if showSignUp {
                    loginUser = LoginUser(name: nameField, email: emailField, password: passwordField)
                    Task {
                        do {
                            try await signUpHandler()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                } else {
                    loginUser = LoginUser(email: emailField, password: passwordField)
                    Task {
                        do {
                            try await loginHandler()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }) {
                Text(showSignUp ? "Đăng ký" : "Đăng nhập")
                    .font(.title) // You can adjust the font size as needed
            }
            .buttonStyle(.bordered)

        }
        .onAppear {
            Task {
                do {
                    try await getPlaces()
                } catch {
                    print("Failed to load places: \(error)")
                }
            }
        }
        .alert($errorMessage.wrappedValue, isPresented: $showingAlert) {
            Button("OK", role: .cancel) {
                showingAlert = false
            }
        }
    }
       
    private func loginHandler() async throws {
        //let url = URL(string: "http://localhost:8000/auth/login")!
        let url = URL(string: "https://bus-station-server-production.up.railway.app/auth/login")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let encoded = try? JSONEncoder().encode(loginUser) else {
            return
        }
        let (data, response) = try await URLSession.shared.upload(for: urlRequest, from: encoded)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            let errorData = try JSONDecoder().decode(AuthenticationErrorData.self, from: data).message
            showingAlert.toggle()
            errorMessage = errorData
            print("Error \(errorData)")
            throw URLError(.cannotParseResponse)
        }
//        if let jsonString = String(data: data, encoding: .utf8) {
//            print(jsonString)
//        }
//        print("data: \(data)")
        let jsonData = try JSONDecoder().decode(LoggedInUser.self, from: data)
//        role = jsonData.role
        appData.userRole = jsonData.role
        appData.token = jsonData.token
        isLoggedIn = true
        email = loginUser?.email ?? ""
    }
    private func signUpHandler() async throws {
        //let url = URL(string: "http://localhost:8000/auth/signup")!
        let url = URL(string: "https://bus-station-server-production.up.railway.app/auth/signup")!
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = "PUT"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let encoded = try? JSONEncoder().encode(loginUser) else {
            return
        }
        let (data, response) = try await URLSession.shared.upload(for: urlRequest, from: encoded)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            let errorData = try JSONDecoder().decode(AuthenticationErrorData.self, from: data).message
            print("Error \(errorData)")
            throw URLError(.cannotParseResponse)
        }
        if let jsonString = String(data: data, encoding: .utf8) {
            print(jsonString)
        }
        print("data: \(data)")
        let jsonData = try JSONDecoder().decode(LoggedInUser.self, from: data)
        
        appData.token = jsonData.token
        isLoggedIn = true
        //role = jsonData.role
        appData.userRole = jsonData.role
        email = loginUser?.email ?? ""
    }
    
    func getPlaces() async throws{
            let url = URL(string: "https://bus-station-server-production.up.railway.app/get-places")!
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "GET"
            //urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization");
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type");
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                let errorData = try JSONDecoder().decode(ErrorData.self, from: data).message
                print("Error \(errorData)")
                throw URLError(.cannotParseResponse)
            }

        appData.suggestPlaces = try JSONDecoder().decode(SuggestPlaces.self, from: data)
        
           // print("jsonData")
        //print(appData.suggestPlaces.schools)
        }
}
