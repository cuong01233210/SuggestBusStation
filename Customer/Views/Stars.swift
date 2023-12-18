//
//  Stars.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 04/10/2023.
//

import SwiftUI

struct Stars: View {
    @Binding var rating: Int
    var body: some View {
        ZStack {
            starsView
                .overlay(overlayView.mask(starsView))
        }
    }
    private var overlayView: some View {
        GeometryReader(content: { geometry in
            ZStack (alignment: .leading){
                Rectangle()
                    //.foregroundColor(.yellow)
                    .fill(LinearGradient(gradient: Gradient(colors: [Color.red, Color.blue]), startPoint: .leading, endPoint: .trailing))
                    .frame(width: CGFloat(rating) / 5 * geometry.size.width)
                    //.mask(starsView)
            }
        })
        .allowsHitTesting(false)
    }
    private var starsView: some View {
        HStack {
            ForEach(1..<6){ index in
                Image(systemName: "star.fill")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            rating = index
                        }
                        
                       // print(rating)
                    }
            }
        }
    }
    
}
