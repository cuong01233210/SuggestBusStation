import SwiftUI

struct ErrorFormManage: View {
    @State private var errorForms: [ErrorForm] = []
    @State private var showDataErrorForm = false
    @State private var selectedErrorForm: ErrorForm?
    @Binding var errorFormManage: Bool
    
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var showStartDatePicker = false
    @State private var showEndDatePicker = false
    @State private var errorFormsFiltered: [ErrorForm] = []

    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    inputFields()
                    
                    Button(action: {
                        showStartDatePicker = true
                    }) {
                        Text("Chọn ngày")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()
                
                TabView {
                    let pageNum = (errorFormsFiltered.count + 9) / 10
                    
                    ForEach(0..<pageNum, id: \.self) { pageIndex in
                        let startIndex = pageIndex * 10
                        let endIndex = min(startIndex + 10, errorFormsFiltered.count)
                        
                        List(startIndex..<endIndex, id: \.self) { index in
                            VStack(alignment: .leading) {
                                if errorFormsFiltered[index].busName == "Walk" || errorFormsFiltered[index].busName == "walk"{
                                    Text("Tuyến xe: Đi bộ")
                                        .font(.headline)
                                } else {
                                    Text("Tuyến xe: \(errorFormsFiltered[index].busName)")
                                        .font(.headline)
                                }
                               
                                Text("Bắt đầu từ trạm: \(errorFormsFiltered[index].source)")
                                    .font(.subheadline)
                                Text("Đi tới trạm: \(errorFormsFiltered[index].destination)")
                                    .font(.subheadline)
                                Text("Thời gian: \(errorFormsFiltered[index].time) on \(errorFormsFiltered[index].date)")
                                    .font(.subheadline)
                                Text("Lỗi: \(errorFormsFiltered[index].errorDescription)")
                                    .font(.body)
                                    .foregroundColor(.red)
                            }
                            .padding()
                        }
                        .tabItem {
                            Text("Page \(pageIndex + 1)")
                        }
                        .tag(pageIndex)
                    }
                }
                .navigationTitle("Danh sách báo lỗi về gợi ý của người dùng")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button {
                            errorFormManage.toggle()
                        } label: {
                            Image(systemName: "arrowshape.backward.fill")
                        }
                    }
                }
                .accentColor(.red)
                .fullScreenCover(isPresented: $showDataErrorForm) {
                    if let errorForm = selectedErrorForm {
                        ErrorFormDetailView(errorForm: errorForm, isPresented: $showDataErrorForm)
                    }
                }
            }
        }
        .sheet(isPresented: $showStartDatePicker) {
            NavigationView {
                VStack {
                    DatePicker("Ngày bắt đầu", selection: $startDate, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding()
                    
                    
                } .navigationTitle("Ngày bắt đầu")
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarLeading) {
                            Button {
                                showStartDatePicker.toggle()
                            } label: {
                                Image(systemName: "arrowshape.backward.fill")
                            }
                        }
                    }.accentColor(.red)
            }
            
        }
        .sheet(isPresented: $showEndDatePicker) {
            NavigationView {
                VStack {
                    DatePicker("Ngày kết thúc", selection: $endDate, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding()
                    
                   
                    
                }.navigationTitle("Ngày kết thúc")
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarLeading) {
                            Button {
                                showEndDatePicker.toggle()
                            } label: {
                                Image(systemName: "arrowshape.backward.fill")
                            }
                        }
                    }.accentColor(.red)
            }
            
        }
        .onChange(of: startDate) { _ in
            filterErrorForms()
        }
        .onChange(of: endDate) { _ in
            filterErrorForms()
        }
        .onAppear {
            Task {
                do {
                    try await getErrorForms()
                } catch {
                    print("error")
                }
            }
        }
    }
    
    private func inputFields() -> some View {
        VStack(spacing: 0) {
            inputField(text: "Ngày bắt đầu: \(DateFormatter.shortDate.string(from: startDate))", flag: 1)
            inputField(text: "Ngày kết thúc: \(DateFormatter.shortDate.string(from: endDate))", flag: 2)
        }
    }
    
    private func inputField(text: String, flag: Int) -> some View {
        HStack {
            Text(text)
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(4)
        .onTapGesture {
            if flag == 1 {
                showStartDatePicker = true
            } else if flag == 2 {
                showEndDatePicker = true
            }
        }
    }
    
    func filterErrorForms() {
        let startOfDay = Calendar.current.startOfDay(for: startDate)
        let endOfDay = Calendar.current.startOfDay(for: endDate).addingTimeInterval(86400 - 1)
        
        print("Filtering from \(startOfDay) to \(endOfDay)")
        
        errorFormsFiltered = errorForms.filter { errorForm in
            if let date = DateFormatter.shortDate.date(from: errorForm.date) {
                print("Checking date \(date)")
                return date >= startOfDay && date <= endOfDay
            }
            return false
        }
        print("Filtered results: \(errorFormsFiltered)")
        if errorFormsFiltered.isEmpty {
            errorFormsFiltered = errorForms
        }
    }
    
    func getErrorForms() async throws {
        errorForms = []
        let url = URL(string: "http://localhost:8000/get-all-error-forms")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            let errorData = try JSONDecoder().decode(ErrorData.self, from: data).message
            print("Error \(errorData)")
            throw URLError(.cannotParseResponse)
        }
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Response JSON: \(jsonString)")
        }
        let jsonData = try JSONDecoder().decode([ErrorForm].self, from: data)
        
        print("jsonData: \(jsonData)")
        errorForms.append(contentsOf: jsonData)
        print("errorForms: \(errorForms)")
        filterErrorForms() // Filter after loading data
    }
}

struct ErrorFormDetailView: View {
    let errorForm: ErrorForm
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Bus: \(errorForm.busName)")
                .font(.headline)
            Text("Source: \(errorForm.source) -> Destination: \(errorForm.destination)")
                .font(.subheadline)
            Text("Time: \(errorForm.time) on \(errorForm.date)")
                .font(.subheadline)
            Text("Error: \(errorForm.errorDescription)")
                .font(.body)
                .foregroundColor(.red)
            Spacer()
            Button("Close") {
                isPresented = false
            }
            .padding()
        }
        .padding()
        .navigationTitle("Error Form Details")
    }
}
