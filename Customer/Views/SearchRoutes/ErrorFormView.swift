import SwiftUI
struct ErrorFormView: View {
    let returnRoute: ReturnRoute
    @State private var errorDescription: String = ""
    @State private var successAlert = false
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Thông tin trạm")) {
                    Text("Tên trạm xuất phát: \(returnRoute.source)")
                    Text("Tên trạm đi đến: \(returnRoute.destination)")
                    if returnRoute.buses[0] == "walk" || returnRoute.buses[0] == "Walk" {
                        Text("Tuyến báo lỗi: Đi bộ")
                    } else {
                        Text("Tuyến báo lỗi: \(returnRoute.buses[0])")
                    }
                    Text("Ngày báo lỗi: \(Date(), formatter: DateFormatter.shortDate)")
                    Text("Thời gian báo lỗi: \(Date(), formatter: DateFormatter.shortTime)")
                }
                
                Section(header: Text("Mô tả lỗi")) {
                    TextEditor(text: $errorDescription)
                        .frame(height: 200)
                }
                
                Button(action: {
                    Task {
                        do {
                            try await postError()
                            successAlert = true
                        } catch {
                            print("error")
                        }
                    }
                }) {
                    Text("Gửi báo lỗi")
                }
                .alert(isPresented: $successAlert) {
                    Alert(
                        title: Text("Thành công"),
                        message: Text("Báo lỗi của bạn đã được gửi thành công."),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
            .navigationTitle("Báo lỗi trạm")
        }
    }
    
    func postError() async throws {
        let date = Date()
        let errorForm: ErrorForm = ErrorForm(
            id: "",
            source: returnRoute.source,
            destination: returnRoute.destination,
            busName: returnRoute.buses[0],
            time: DateFormatter.shortTime.string(from: date),
            date: DateFormatter.shortDate.string(from: date),
            errorDescription: errorDescription
        )
        let url = URL(string: "http://localhost:8000/add-error-form")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let encoded = try? JSONEncoder().encode(errorForm) else {
            return
        }
        let (data, response) = try await URLSession.shared.upload(for: urlRequest, from: encoded)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            let errorData = try JSONDecoder().decode(ErrorData.self, from: data).message
            print("Error \(errorData)")
            throw URLError(.cannotParseResponse)
        }
        let jsonData = try JSONDecoder().decode(Message.self, from: data)
        print(jsonData.message)
        
        // Nếu thành công, đặt successAlert thành true
        DispatchQueue.main.async {
            self.successAlert = true
        }
    }
}
