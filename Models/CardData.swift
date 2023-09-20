//
//  CardData.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 20/09/2023.
//

import Foundation
struct PresentData {
    var startLocation: String
    var startDistance: Double
    var route: String
    var endStation: String
    
    init(startLocation: String, startDistance:Double, route: String, endStation: String){
        self.startLocation = startLocation
        self.startDistance = startDistance
        self.route = route
        self.endStation = endStation
    }
}
