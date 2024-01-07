//
//  MainScreenItemView.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 27/09/2023.
//

import SwiftUI

struct ItemView: View {
    
    var width: CGFloat = 200
    var height: CGFloat = 100
    var name = ""
    var systemName = ""
    var backgroundColor: Color = .blue
    
    var body: some View {
        HStack{
            Image(systemName: systemName)
            Text(name)
        }
        .padding()
           // .foregroundColor(Color.white)
            //.frame(width: width, height: height, alignment: .center)
            //background(backgroundColor)
           // .padding(.all, 1.0)
    }
}
