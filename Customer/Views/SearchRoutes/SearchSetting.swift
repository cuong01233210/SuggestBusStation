//
//  SearchSetting.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 1/6/24.
//

import SwiftUI

struct SearchSetting: View {
    @State private var noWalkingSearch = false
    @State private var combineWalkingSearch = true
    @State private var departNow = true
    @State private var customTime = false
    @State private var showPicker = false
    @State private var selectedHour = 0
    @State private var selectedMinute = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Cài đặt")
                .font(.largeTitle)
                .bold()
                .padding(.bottom, 10)
            
            Text("Cài đặt tìm đường")
                .font(.title2)
                .foregroundColor(.green)
                .bold()
            
            Toggle(isOn: $noWalkingSearch) {
                VStack(alignment: .leading) {
                    Text("Tìm kiếm không đi bộ")
                        .font(.headline)
                    Text("Ứng dụng sẽ tìm kiếm tuyến đường mà bạn không cần đi bộ giữa các trạm. Tuy nhiên lộ trình có thể sẽ dài hơn so với tìm kiếm có đi bộ")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            Toggle(isOn: $combineWalkingSearch) {
                VStack(alignment: .leading) {
                    Text("Tìm kiếm kết hợp đi bộ")
                        .font(.headline)
                    Text("Ứng dụng sẽ tìm kiếm tuyến đường kết hợp việc đi bộ qua đường để tới được trạm tiếp theo cần nhảy tuyến nếu cần thiết. Kết quả tìm kiếm sẽ tối ưu quãng đường cần đi hơn.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            Text("Cài đặt thời gian gợi ý xe")
                .font(.title2)
                .foregroundColor(.green)
                .bold()
                .padding(.top, 20)
            
            Toggle(isOn: $departNow) {
                Text("Khởi hành bây giờ")
                    .font(.headline)
            }
            
            Toggle(isOn: $customTime) {
                Text("Tự chọn thời gian")
                    .font(.headline)
            }
            
            if customTime {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Khởi hành lúc")
                            .font(.headline)
                        Text("\(String(format: "%02d", selectedHour)):\(String(format: "%02d", selectedMinute))")
                            .font(.headline)
                            .bold()
                    }
                    Spacer()
                    Button("THAY ĐỔI") {
                        showPicker = true
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(5)
                }
            }
            
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showPicker) {
            VStack {
                Text("Lựa chọn thời gian xuất phát")
                    .font(.headline)
                    .padding()
                HStack {
                    Picker(selection: $selectedHour, label: Text("Hour")) {
                        ForEach(0..<24) { hour in
                            Text("\(hour)").tag(hour)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(maxWidth: .infinity)

                    Picker(selection: $selectedMinute, label: Text("Minute")) {
                        ForEach(0..<60) { minute in
                            Text("\(minute)").tag(minute)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(maxWidth: .infinity)
                }
                .frame(height: 150)
                Button("Xong") {
                    showPicker = false
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(5)
            }
            .padding()
        }
    }
}

