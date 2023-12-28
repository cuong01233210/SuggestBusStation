//
//  UserIn4.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 24/12/2023.
//

import SwiftUI

import Foundation

struct UserInfo: Codable {
    var userIn4: UserIn4
}

struct UserIn4: Codable {
    var name: String
    var sex: String
    var dateOfBirth: String
    var phoneNumber: String
    var email: String
}
