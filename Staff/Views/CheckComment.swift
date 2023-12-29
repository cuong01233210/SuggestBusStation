//
//  CheckComment.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 29/12/2023.
//

import SwiftUI
struct Product: Identifiable {
    let id: Int
    let name: String
    // Thêm các thuộc tính khác của sản phẩm nếu cần
}
struct CheckComment: View {
    let products: [Product]
    @Binding var checkComment: Bool
    var body: some View {
        NavigationView {
                   TabView {
                       ForEach(0..<products.count / 10 + 1) { pageIndex in
                           let startIndex = pageIndex * 10
                           let endIndex = min((pageIndex + 1) * 10, products.count)
                           
                           let productsPage = Array(products[startIndex..<endIndex])
                           
                           ProductPageView(products: productsPage)
                               .tabItem {
                                   Text("Page \(pageIndex + 1)")
                               }
                               .tag(pageIndex)
                       }
                       
                       
                   }
                   .navigationTitle("Product Pages")
                   .toolbar{
                       ToolbarItemGroup(placement: .navigationBarLeading) {
                           Button{
                               checkComment.toggle()
                           } label: {
                               Image(systemName: "arrowshape.backward.fill")
                           }
                       }
                   }
                   .accentColor(.red)
               }
    }
}
struct ProductPageView: View {
    let products: [Product]

    var body: some View {
        List(products) { product in
            // Hiển thị thông tin sản phẩm, ví dụ:
            Text(product.name)
        }
    }
}



