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
    @EnvironmentObject var appData: AppData
   
    var body: some View {
        if isLoggedIn {
            //MainScreen(isLoggedIn: $isLoggedIn, token: $token, email: $email)
            if appData.userRole == "0"{
                MainScreen(email: $email, token: $token, isLoggedIn: $isLoggedIn)
            } else {
                if appData.userRole == "1"{
                    StaffDashBoard(isLoggedIn: $isLoggedIn)
                } else {
                    AdminDashBoard(isLoggedIn: $isLoggedIn)
                }
                
            }
        } else {
            AuthenticationView(isLoggedIn: $isLoggedIn, token: $token, email: $email )
        }
    }
}
