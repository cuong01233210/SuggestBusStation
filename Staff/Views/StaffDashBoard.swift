//
//  StaffDashBoard.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 28/12/2023.
//

import SwiftUI

struct StaffDashBoard: View {
    @Binding var isLoggedIn : Bool
    @State var checkComment: Bool = false
    let sampleProducts = (1...50).map { Product(id: $0, name: "Product \($0)") }
    var body: some View {
        NavigationView{
            VStack {
                List {
                    ItemView(name: "Hiển thị đánh giá người dùng", systemName: "doc.append")
                        .onTapGesture {
                        checkComment.toggle()
                    }
                        .fullScreenCover(isPresented: $checkComment) {
                            CheckComment(products: sampleProducts, checkComment: $checkComment)
                           // AnotherView1(isPresentingAnotherView1: $isPresentingAnotherView1)
                    }
                    
                    ItemView(name: "Tuyến đường giờ cao điểm bị tắc")
                    ItemView(name: "Thông tin các tuyến xe buýt")
                    ItemView(name: "Yêu thích")
                    ItemView(name: "Thông tin về app")
                }
                
            }
                .navigationTitle("Xin chào!")
                .toolbar{
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button{
                            isLoggedIn.toggle()
                        } label: {
                            Image(systemName: "arrowshape.backward.fill")
                        }
                    }
                }
                .accentColor(.red)
        }
        
    
        .ignoresSafeArea()
    
    }
}

//#Preview {
//    StaffDashBoard()
//}
