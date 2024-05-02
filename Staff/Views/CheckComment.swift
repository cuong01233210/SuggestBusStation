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
    @State private var hasReceivedData = false
    @State private var comments: [Comment] = []
    var body: some View {
        if !hasReceivedData {
                    ProgressView("Loading...")
                        .onAppear {
                            Task {
                                do {
                                    try await getAllComments()
                                    hasReceivedData = true
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        }
        }//else
//        {
//            NavigationView {
//                TabView {
////                            ForEach(comments.comments.chunked(into: 10), id: \.self) { chunkedComments in
//                                // Display each page of 10 comments
//                               // CommentPage(comments: chunkedComments)
//                            }
//                        }
//            }
//        }
        else{
            NavigationView {
                TabView {
                    let pageNum = comments.count / 6 + 1
                    ForEach(0..<pageNum) { pageIndex in
                        let startIndex = pageIndex * 6
                        let end = (pageIndex + 1) * 6
                        let endIndex = min((pageIndex + 1) * 6, comments.count)
                        
                        let productsPage = Array(comments[startIndex..<endIndex])
                        
                        CommentPageView(comments: productsPage)
                            .tabItem {
                                Text("Page \(pageIndex + 1)")
                            }
                            .tag(pageIndex)
                    }
                    
                    
                }
                .navigationTitle("Đánh giá của khách")
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
    func getAllComments() async throws{
        let url = URL(string: "http://localhost:8000/get-all-comments")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        //urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization");
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type");
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            let errorData = try JSONDecoder().decode(ErrorData.self, from: data).message
            print("Error \(errorData)")
            throw URLError(.cannotParseResponse)
        }
        //print("data: \(data)")
//        if let jsonString = String(data: data, encoding: .utf8) {
//            print(jsonString)
//        }

        let jsonData = try JSONDecoder().decode(Comments.self, from: data)
        //print("jsonData: \(jsonData)")
        comments.append(contentsOf: jsonData.comments)
        //print(comments)
    }
}
//struct CommentPage : View {
//    let comment: [Comment]
//    var body: some View {
//        
//    }
//}
struct CommentPageView: View {
    let comments: [Comment]

    var body: some View {
        List{
            // Hoặc sử dụng indices
            ForEach(comments.indices) { index in
                VStack (alignment: .leading) {
                    Text("Nội dụng comment: \(comments[index].suggestion)")
                    Text("Đánh giá app: \(comments[index].rating) sao")
                    Text(comments[index].date)
                }
                
            }
        }
    }
}



