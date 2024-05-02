//
//  UserInputLocation.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 18/07/2023.
//

import Foundation
struct UserStartString: Codable{
    var id: String
    var startString: String
    
    init(id: String, startString: String) {
        self.id = id
        self.startString = startString
    }
}

struct UserEndString: Codable{
    var id: String
    var endString: String
    
    init(id: String, endString: String) {
        self.id = id
        self.endString = endString
    }
}

struct UserString: Codable{
    var id: String
    var startString: String
    var endString: String
    var userKm: Double
    
    init(id: String, startString: String, endString: String, userKm: Double) {
        self.id = id
        self.startString = startString
        self.endString = endString
        self.userKm = userKm
    }
}
