//
//  CardView.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 20/09/2023.
//

import SwiftUI
struct ShowCardView: View {
    let presentData: PresentData

    var body: some View {
        VStack(alignment: .leading) {
            HStack  {
                Image(systemName: "bus")
                Text("\(presentData.route)")
                Text("Chi phí: 7000 đ")
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            
            
            HStack {
                Image(systemName: "figure.walk")
                
                Text(String(format: "%.1f", presentData.startDistance) + " km")
            }
            Text("Đón tại trạm: \(presentData.startLocation)")
            
        }
    }
}

struct CardView : View{
    let presentData: PresentData
    //@State private var isShowingAnotherView = false
    @Binding var isPresentingContentMapView2: Bool
    var body: some View {
        
        VStack {
            ShowCardView(presentData: presentData)
        }
        .onTapGesture {
                    isPresentingContentMapView2.toggle()
                }
        .padding()
    }
}
struct AnotherView: View {
    @Binding var isPresentingAnotherView: Bool
    
    var body: some View {
        VStack {
            Text("Another View")
            Button("Đóng") {
                isPresentingAnotherView = false
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}
