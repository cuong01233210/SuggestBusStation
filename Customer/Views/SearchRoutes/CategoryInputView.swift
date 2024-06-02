//
//  CategoryInputView.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 02/05/2024.
//

import SwiftUI

struct CategoryInputView: View {
    @State private var searchText = ""
    @EnvironmentObject var appData: AppData
    @State private var showLocationPicker = false
    @Binding var showCategoryInputView : Bool
    @Binding var placeFlag : Int
    @Binding var showInputView : Bool
    @State var currentPlaces: [Place] = []
    @State var title: String = ""
    
    var filteredPlaces: [Place] {
        if searchText.isEmpty {
            return currentPlaces
        } else {
            return currentPlaces.filter { place in
                place.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            
            VStack {
                // Search Bar at the top
                
                TextField("Tìm điểm bạn muốn đến", text: $searchText)
                    .padding(7)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                
                
                List(filteredPlaces, id: \.id) { place in
                    VStack(alignment: .leading) {
                        Text(place.name).bold()
                        Text(place.category)
                            .foregroundColor(.gray)
                        
                    }.onTapGesture {
                        if appData.inputFlag == 1 {
                            appData.startPlace = place
                        } else {
                            appData.endPlace = place
                        }
                        appData.inputFlag = 0 // chưa lựa chọn cập nhật dữ liệu startPlace hay endPlace
                        showInputView.toggle()
                        showCategoryInputView.toggle()
                    }
                }
            }
            
            .navigationTitle(title)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        placeFlag = 0
                        showCategoryInputView.toggle()
                    } label: {
                        Image(systemName: "arrowshape.backward.fill")
                    }
                }
            }
            .accentColor(.red)
            .onAppear{
                if placeFlag == 1 {
                    title = "Bến xe - Nhà ga"
                    currentPlaces = appData.suggestPlaces.stations
                }
                if placeFlag == 2 {
                    title = "Cơ sở giáo dục"
                    currentPlaces = appData.suggestPlaces.schools
                }
                if placeFlag == 3 {
                    title = "Bệnh viện"
                    currentPlaces = appData.suggestPlaces.hospitals
                }
                if placeFlag == 4 {
                    title = "Chợ - Siêu thị"
                    currentPlaces = appData.suggestPlaces.markets
                }
                if placeFlag == 5 {
                    title = "Nhà sách"
                    currentPlaces = appData.suggestPlaces.bookstores
                }
                if placeFlag == 6 {
                    title = "Công viên"
                    currentPlaces = appData.suggestPlaces.parks
                }
                if placeFlag == 7 {
                    title = "Cơ sở tôn giáo"
                    currentPlaces = appData.suggestPlaces.pagodas
                }
                if placeFlag == 8 {
                    title = "Bảo tàng"
                    currentPlaces = appData.suggestPlaces.museums
                }
                if placeFlag == 9 {
                    title = "Trạm xe buýt"
                    currentPlaces = appData.suggestPlaces.busStations
                }
                if placeFlag == 10 {
                    title = "Khác"
                    currentPlaces = appData.suggestPlaces.diffPlaces
                }
            }
        }
    }
}

