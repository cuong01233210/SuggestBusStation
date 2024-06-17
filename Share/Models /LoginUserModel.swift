//
//  LoginUserModel.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 16/6/24.
//

struct LoggedInUser: Codable {
    var token: String
    var userId: String
    var role: String
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

struct Account: Codable,  Identifiable{
    var id: String
    var email: String
    var password: String
    var role: String
}

struct FullAccountInfo: Codable {
    var id: String
    var email: String
    var password: String
    var role: String
    var name: String
    var sex: String
    var dateOfBirth: String
    var phoneNumber: String
}
