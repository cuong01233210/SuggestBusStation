//
//  CommentView.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 04/10/2023.
//

import SwiftUI

struct CommentView: View {
    @State var suggestion: String = ""
    @State var rating: Int = 0
    @Binding var isPresentingCommentView: Bool
    @Binding var token: String
    @Binding var isLoggedIn : Bool
    @State private var showAlert = false
    @State private var alertMessage = ""
    var body: some View {
        
        List {
            Text("Hãy cho tôi biết ý kiến/ đề xuất của bạn ")
                .font(Font.custom("Arial", size: 20))
                .fontWeight(.bold)
            TextField("Ý kiến/ đề xuất", text: $suggestion, axis: .vertical)
                .frame(height: 100) // Điều chỉnh chiều cao tùy ý
                .lineLimit(5...20)
                .textFieldStyle(.roundedBorder)
                .padding(.bottom, 30)
            Text("Hãy đánh giá cho app 5 sao nhé!")
                .font(Font.custom("Arial", size: 20))
                .fontWeight(.bold)
            Stars(rating: $rating)
            HStack {
                Spacer()
                Button(action: {
                    Task {
                        print("Gửi")
                        print("Nội dung comment \(suggestion)")
                        print("Rating \(rating)")
                        var comment = Comment(suggestion: suggestion, date: "", rating: rating)
                        
                        do{
                            try await postComment(comment: comment)
                            alertMessage = "Comment sent successfully!"
                            showAlert = true // Hiển thị Alert khi thành công
                            //appData.outputData = self.outputData
                        }
                        catch{
                            print("Error: \(error)")
                            alertMessage = "An error occurred while sending the comment."
                            showAlert = true // Hiển thị Alert khi có lỗi
                        }
                    }
                    
                }, label: {
                    Label("Gửi", systemImage: "paperplane")
                }).buttonStyle(.bordered)
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Thông báo"),
                            message: Text(alertMessage),
                            dismissButton: .default(Text("OK"))
                        )
                }
            }
        }.listStyle(PlainListStyle())
            .padding(.top, 40)
        //List {
        
        Spacer()
        Button("Quay lại trang chủ") {
            isPresentingCommentView = false
        }
    }
    func postComment(comment: Comment) async throws{
        print("token: \(token)")
        let url = URL(string: "http://localhost:8000/add-comment")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization");
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type");
        
        guard let encodedComment = try? JSONEncoder().encode(comment) else {
            return
        }
        let (data, response) = try await URLSession.shared.upload(for: urlRequest, from: encodedComment)
        // từ dòng này chở xuống là nhận phản hồi thôi nên ko quan trọng lắm
        // có lẽ thay vì in ra các comment thì tạm thời làm alert thông báo thành công
        // nào rảnh thì làm list comment sau
        if let response = response as? HTTPURLResponse {
            
            if response.statusCode == 200 {
                let jsonData = try JSONDecoder().decode(Comment.self, from: data)
                // make alert thông báo thành công
                //print(jsonData)
            } else if response.statusCode == 401 {
                //token = ""
                //isLoggedIn = false
                print("Unauthenticated")
            } else {
                let errorData = try JSONDecoder().decode(ErrorData.self, from: data).message
                print("Error \(errorData)")
                throw URLError(.cannotParseResponse)
            }
        }
        
    }
}


