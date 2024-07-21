//
//  SearchSetting.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 1/6/24.
//

import SwiftUI

struct SearchSetting: View {
   
    
    @State private var departNow = true
    @State private var customTime = false
    @State private var showPicker = false
    
    @EnvironmentObject var appData: AppData
    
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
            
            
            Toggle(isOn: $appData.isOneBusSearch) {
                VStack(alignment: .leading) {
                    Text("Tìm kiếm chỉ dùng 1 tuyến")
                        .font(.headline)
                    Text("Ứng dụng sẽ tìm kiếm xem có thể di chuyển mà chỉ cần dùng đúng 1 tuyến xe buýt không")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .onChange(of: appData.isOneBusSearch) { value in
                if value {
                    appData.isOneBusSearch = true
                    
                } else {
                    appData.isOneBusSearch = false
                    //oneBusSearch = true
                }
            }
            
            
            if appData.isOneBusSearch == false {
                Toggle(isOn: $appData.isNoWalkingSearch) {
                    VStack(alignment: .leading) {
                        Text("Tìm kiếm không đi bộ")
                            .font(.headline)
                        Text("Ứng dụng sẽ tìm kiếm tuyến đường mà bạn không cần đi bộ giữa các trạm. Tuy nhiên lộ trình có thể sẽ dài hơn so với tìm kiếm có đi bộ")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .onChange(of: appData.isNoWalkingSearch) { value in
                    if value {
                        appData.searchMode = 1
                        appData.isCombineWalkingSearch = false
                    } else {
                        appData.searchMode = 2
                        appData.isCombineWalkingSearch = true
                    }
                }
                
                Toggle(isOn: $appData.isCombineWalkingSearch) {
                    VStack(alignment: .leading) {
                        Text("Tìm kiếm kết hợp đi bộ")
                            .font(.headline)
                        Text("Ứng dụng sẽ tìm kiếm tuyến đường kết hợp việc đi bộ qua đường để tới được trạm tiếp theo cần nhảy tuyến nếu cần thiết. Kết quả tìm kiếm sẽ tối ưu quãng đường cần đi hơn.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .onChange(of: appData.isCombineWalkingSearch) { value in
                    if value {
                        appData.searchMode = 2
                        appData.isNoWalkingSearch = false
                    } else {
                        appData.searchMode = 1
                        appData.isNoWalkingSearch = true
                    }
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
            .onChange(of: departNow) { value in
                if value {
                    appData.userTimeMode = 0
                    customTime = false
                } else {
                    appData.userTimeMode = 1
                    customTime = true
                }
            }
            
            Toggle(isOn: $customTime) {
                Text("Tự chọn thời gian")
                    .font(.headline)
            }
            .onChange(of: customTime) { value in
                if value {
                    appData.userTimeMode = 1
                    departNow = false
                } else {
                    appData.userTimeMode = 0
                    departNow = true
                }
            }
            
            if customTime {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Khởi hành lúc")
                            .font(.headline)
                        Text("\(String(format: "%02d", appData.userInputHour)):\(String(format: "%02d", appData.userInputMinute))")
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
                    Picker(selection: $appData.userInputHour, label: Text("Hour")) {
                        ForEach(0..<24) { hour in
                            Text("\(hour)").tag(hour)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(maxWidth: .infinity)
                    
                    Picker(selection: $appData.userInputMinute, label: Text("Minute")) {
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


