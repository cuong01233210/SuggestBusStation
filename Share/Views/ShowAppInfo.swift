//
//  ShowAppInfo.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 17/6/24.
//

import SwiftUI

struct ShowAppInfo: View {
    @Binding var showAppInfo : Bool
    @State var hasReceiveData: Bool = false
    @State var version : String = ""
    @State var updated: String = ""
    @State var content: String = ""
    @State var isEditing : Bool = false
    @State var successAlert = false
    @State private var today = Date()
    @EnvironmentObject var appData: AppData
    var body: some View {
        if hasReceiveData == false {
            NavigationView{
                ProgressView("Loading ...")
                    .onAppear {
                        Task {
                            do {
                                try await getAppInfo()
                                // Set hasReceivedData only after the data is received
                                hasReceiveData = true
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }
                    .navigationTitle("Thông tin ứng dụng")
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarLeading) {
                            Button {
                                showAppInfo.toggle()
                            } label: {
                                Image(systemName: "arrowshape.backward.fill")
                            }
                        }
                    }.accentColor(.red)
            }
        } else {
            NavigationView {
                Group {
                    if isEditing == false {
                        showDataView
                    } else {
                        changeDataView
                    }
                }
                .navigationTitle("Thông tin ứng dụng")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button {
                            showAppInfo.toggle()
                        } label: {
                            Image(systemName: "arrowshape.backward.fill")
                        }
                    }
                    if appData.userRole == "1"{
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
                            Button {
                                isEditing.toggle()
                            } label: {
                                Image(systemName: "pencil.circle")
                            }
                            if isEditing == true {
                                Button {
                                    Task {
                                        do {
                                            try await update()
                                        } catch {
                                            print(error)
                                        }
                                    }
                                } label: {
                                    Text("Lưu thay đổi")
                                }
                            }
                        }
                    }
                    
                }.accentColor(.red)
                    .alert(isPresented: $successAlert) {
                        Alert(
                            title: Text("Thông báo"),
                            message: Text("Bạn đã thêm chỉnh sửa thông tin thành công"),
                            dismissButton: .default(Text("OK"))
                        )
                    }
            }
        }
    }
    private var showDataView : some View {
        List {
            Section {
                Text("\(content)")
                    .fixedSize(horizontal: false, vertical: true)
            } header: {
                Text("Mô tả ứng dụng")
            }
            Section {
                Text("\(version)")
            } header: {
                Text("Phiên bản")
            }
            Section {
                Text("\(updated)")
            } header: {
                Text("Ngày cập nhật")
            }
        }
    }
    
    private var changeDataView : some View {
        List {
            Section {
                TextEditor(text: $content)
                    .padding()
                    .frame(height: 200) // Đặt chiều cao phù hợp cho TextEditor
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .fixedSize(horizontal: false, vertical: true)
            } header: {
                Text("Mô tả ứng dụng")
            }
            Section {
                TextField("Nhập phiên bản", text: $version)
            } header: {
                Text("Phiên bản")
            }
            
        }
    }
    func getAppInfo() async throws {
        
        let url = URL(string: "http://localhost:8000/get-app-info")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type");
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            let errorData = try JSONDecoder().decode(ErrorData.self, from: data).message
            print("Error \(errorData)")
            throw URLError(.cannotParseResponse)
        }
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Response JSON: \(jsonString)")
        }
        
        let jsonData = try JSONDecoder().decode(AppInfo.self, from: data)
        // print("jsonData")
        version = jsonData.version
        content = jsonData.content
        updated = jsonData.updated
    }
    
    func update() async throws {
        let url = URL(string: "http://localhost:8000/update-app-info")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PATCH"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var todayString: String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy" // Định dạng ngày bạn muốn
            return dateFormatter.string(from: today)
        }
        let newInfo = AppInfo(version: version, updated: todayString, content: content)
        
        guard let encoded = try? JSONEncoder().encode(newInfo) else {
            return
        }
        
        let (data, response) = try await URLSession.shared.upload(for: urlRequest, from: encoded)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            let errorData = try JSONDecoder().decode(ErrorData.self, from: data).message
            print("Error \(errorData)")
            throw URLError(.cannotParseResponse)
        }
        
        successAlert = true
        isEditing = false
        
    }
}

