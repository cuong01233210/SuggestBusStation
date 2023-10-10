//
//  LoginView.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 28/09/2023.
//

import SwiftUI

struct LoggedInUser: Codable {
    var token: String
    var userId: String
    
    enum CodingKeys: CodingKey {
        case token
        case userId
    }
}
struct AuthenticationErrorData : Codable {
    var message: String
    
    enum CodingKeys: String, CodingKey {
        case message
    }
}

struct LoginUser : Codable {
    var name: String?
    var email: String
    var password: String
    
    enum CodingKeys : CodingKey {
        case name
        case email
        case password
    }
}
struct MyApp: View {
    @State private var isLoggedIn = false
    @State private var token: String = ""
    
    var body: some View {
        if isLoggedIn {
            MainScreen(isLoggedIn: $isLoggedIn, token: $token)
        } else {
            AuthenticationView(isLoggedIn: $isLoggedIn, token: $token)
        }
    }
}

struct AuthenticationView: View {
    @State private var showSignUp = true
    @State private var nameField: String = ""
    @State private var emailField : String = ""
    @State private var passwordField : String = ""
    @State private var loginUser: LoginUser? = nil
    
    @Binding var isLoggedIn: Bool
    @Binding var token : String
    
    var body: some View {
        Button("toggle auth"){
            showSignUp.toggle()
        }
        
        if showSignUp {
            TextField("Name", text: $nameField)
                .padding()
        }
        
        TextField("Email", text: $emailField)
            .padding()
        TextField("Password", text: $passwordField)
            .padding()
        Button(showSignUp ? "SignUp" : "LogIn"){
            if showSignUp {
                loginUser = LoginUser(name: nameField, email: emailField, password: passwordField)
                Task {
                    do {
                        try await signUpHandler()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
             else {
                loginUser = LoginUser(email: emailField, password: passwordField)
                 Task {
                     do {
                         try await loginHandler()
                     } catch {
                         print(error.localizedDescription)
                     }
                 }
            }
        }
        .buttonStyle(.bordered)
    }
    private func loginHandler() async throws {
        let url = URL(string: "http://localhost:8000/auth/login")!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
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
        let jsonData = try JSONDecoder().decode(LoggedInUser.self, from: data)
        token = jsonData.token
        isLoggedIn = true
    }
    private func signUpHandler() async throws {
        let url = URL(string: "http://localhost:8000/auth/signup")!
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
        let jsonData = try JSONDecoder().decode(LoggedInUser.self, from: data)
        token = jsonData.token
        isLoggedIn = true
    }
}
