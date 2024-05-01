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
    @State private var role: String = ""
    @State private var suggestPlaces : SuggestPlaces = SuggestPlaces(places: [], stations: [], schools: [], hospitals: [], markets: [], bookstores: [], parks: [], pagodas: [], museums: [], diffPlaces: [])
    var body: some View {
        if isLoggedIn {
            //MainScreen(isLoggedIn: $isLoggedIn, token: $token, email: $email)
            if role == "0"{
                MainScreen(email: $email, token: $token, isLoggedIn: $isLoggedIn, suggestPlaces: $suggestPlaces)
            } else {
                StaffDashBoard(isLoggedIn: $isLoggedIn)
            }
        } else {
            AuthenticationView(isLoggedIn: $isLoggedIn, token: $token, email: $email, role: $role, suggestPlaces: $suggestPlaces)
        }
    }
}
