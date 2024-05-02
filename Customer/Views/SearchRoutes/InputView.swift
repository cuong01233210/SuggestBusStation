//
//  InputView.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 02/05/2024.
//

import SwiftUI

struct InputView: View {
    @Binding var showInputView : Bool
    //@Binding var suggestPlaces : SuggestPlaces
    @State private var searchText = ""
    @EnvironmentObject var appData: AppData
    @State private var showLocationPicker = false
    @State private var placeFlag = 0
    @State private var showCategoryInputView = false
    var filteredPlaces: [Place] {
        if searchText.isEmpty {
            return []
        } else {
            return appData.suggestPlaces.places.filter { place in
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
                
                if searchText.isEmpty {
                    List {
                        Section {
                            Text("Bến xe - Nhà ga")
                                .onTapGesture {
                                    placeFlag = 1
                                    showCategoryInputView = true
                                }
                                .fullScreenCover(isPresented: $showCategoryInputView) {
                                    CategoryInputView(showCategoryInputView: $showCategoryInputView, placeFlag: $placeFlag, showInputView: $showInputView)
                                }
                            Text("Cơ sở giáo dục")
                                .onTapGesture {
                                    placeFlag = 2
                                    showCategoryInputView = true
                                }
                                .fullScreenCover(isPresented: $showCategoryInputView) {
                                    CategoryInputView(showCategoryInputView: $showCategoryInputView, placeFlag: $placeFlag, showInputView: $showInputView)
                                }
                            Text("Bệnh viện")
                                .onTapGesture {
                                    placeFlag = 3
                                    showCategoryInputView = true
                                }
                                .fullScreenCover(isPresented: $showCategoryInputView) {
                                    CategoryInputView(showCategoryInputView: $showCategoryInputView, placeFlag: $placeFlag, showInputView: $showInputView)
                                }
                            Text("Chợ - Siêu thị")
                                .onTapGesture {
                                    placeFlag = 4
                                    showCategoryInputView = true
                                }
                                .fullScreenCover(isPresented: $showCategoryInputView) {
                                    CategoryInputView(showCategoryInputView: $showCategoryInputView, placeFlag: $placeFlag, showInputView: $showInputView)
                                }
                            Text("Nhà sách")
                                .onTapGesture {
                                    placeFlag = 5
                                    showCategoryInputView = true
                                }
                                .fullScreenCover(isPresented: $showCategoryInputView) {
                                    CategoryInputView(showCategoryInputView: $showCategoryInputView, placeFlag: $placeFlag, showInputView: $showInputView)
                                }
                            Text("Công viên")
                                .onTapGesture {
                                    placeFlag = 6
                                    showCategoryInputView = true
                                }
                                .fullScreenCover(isPresented: $showCategoryInputView) {
                                    CategoryInputView(showCategoryInputView: $showCategoryInputView, placeFlag: $placeFlag, showInputView: $showInputView)
                                }
                            Text("Cơ sở tôn giáo")
                                .onTapGesture {
                                    placeFlag = 7
                                    showCategoryInputView = true
                                }
                                .fullScreenCover(isPresented: $showCategoryInputView) {
                                    CategoryInputView(showCategoryInputView: $showCategoryInputView, placeFlag: $placeFlag, showInputView: $showInputView)
                                }
                            Text("Bảo tàng")
                                .onTapGesture {
                                    placeFlag = 8
                                    showCategoryInputView = true
                                }
                                .fullScreenCover(isPresented: $showCategoryInputView) {
                                    CategoryInputView(showCategoryInputView: $showCategoryInputView, placeFlag: $placeFlag, showInputView: $showInputView)
                                }
                            Text("Khác")
                                .onTapGesture {
                                    placeFlag = 9
                                    showCategoryInputView = true
                                }
                                .fullScreenCover(isPresented: $showCategoryInputView) {
                                    CategoryInputView(showCategoryInputView: $showCategoryInputView, placeFlag: $placeFlag, showInputView: $showInputView)
                                }
                        } header: {
                            Text("Danh mục địa điểm")
                        }
                        
                        Section {
                            Text("Chọn địa điểm trên bản đồ")
                               // .background(Color.green)
                                .foregroundColor(Color.green)
                                .onTapGesture {
                                    showLocationPicker = true
                                }
                                .fullScreenCover(isPresented: $showLocationPicker) {
                                    LocationPickerView(showInputView: $showInputView, showLocationPicker: $showLocationPicker)
                                }
                        } header: {
                            Text("Chọn địa điểm trên bản đồ")
                                
                        }
                    }
                } else {
                    List(filteredPlaces, id: \.id) { place in
                        VStack(alignment: .leading) {
                            Text(place.name).bold()
                            Text(place.category)
                                .foregroundColor(.gray)
//                            Text("Latitude: \(place.lat), Longitude: \(place.long)")
//                                .font(.system(size: 12))
//                                .foregroundColor(.blue)
                        }.onTapGesture {
                            if appData.inputFlag == 1 {
                                appData.startPlace = place
                            } else {
                                appData.endPlace = place
                            }
                            appData.inputFlag = 0 // chưa lựa chọn cập nhật dữ liệu startPlace hay endPlace
                            showInputView.toggle()
                        }
                    }
                }
            }
            .navigationTitle("Bạn muốn đến đâu?")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        showInputView.toggle()
                    } label: {
                        Image(systemName: "arrowshape.backward.fill")
                    }
                }
            }
            .accentColor(.red)
        }
    }
}

