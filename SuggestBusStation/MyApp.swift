//
//  MyApp.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 18/12/2023.
//

import SwiftUI

struct MyApp: View {
    @State private var isLoggedIn = false
    @State private var token: String = ""
    @State private var email: String = ""
    var body: some View {
        if isLoggedIn {
            //MainScreen(isLoggedIn: $isLoggedIn, token: $token, email: $email)
            MainScreen(email: $email, token: $token, isLoggedIn: $isLoggedIn)
        } else {
            AuthenticationView(isLoggedIn: $isLoggedIn, token: $token, email: $email)
        }
    }
}
