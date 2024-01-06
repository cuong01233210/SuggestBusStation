//
//  ShowDataBusStation.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 06/01/2024.
//

import SwiftUI

struct ShowDataBusStation: View {
    @Binding var showDataBusStation: Bool
     var busStation: BusStation
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Tên trạm")){
                    Text(busStation.name)
                }
                Section(header: Text("Các tuyến xe buýt đi qua")){
                    ForEach(0..<busStation.bus.count, id: \.self) { index in
                        if index % 5 == 0 {
                            let endIndex = Swift.min(index + 5, busStation.bus.count)
                            let chunk = busStation.bus[index..<endIndex]
                            Text("Bus List: \(chunk.joined(separator: ", "))")
                            // .foregroundColor(.gray) // Tùy chỉnh màu sắc nếu cần
                        }
                    }
                }
                Section(header: Text("Toạ độ của trạm")){
                    Text("Toạ độ latitude: \(busStation.lat)")
                    Text("Toạ độ longitude: \(busStation.long)")
                }
                Section(header: Text("Khu vực")){
                    Text("Quận: \(busStation.district)")
                }
                
               
            }
            .navigationTitle("Thông tin chi tiết")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        showDataBusStation.toggle()
                    } label: {
                        Image(systemName: "arrowshape.backward.fill")
                    }
                }
            }.accentColor(.red)
        }
    }
}

//#Preview {
//    ShowDataBusStation()
//}
