//
//  SearchView.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 26/02/2024.
//

import SwiftUI

struct SearchView: View {
    @Binding var isSearchView : Bool
    @Binding var suggestPlaces : SuggestPlaces
    @State private var searchText = ""
    
    @State private var showingLocationPicker = false
    var filteredPlaces: [Place] {
        if searchText.isEmpty {
            return []
        } else {
            return suggestPlaces.places.filter { place in
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
                            Text("Cơ sở giáo dục")
                            Text("Bệnh viện")
                            Text("Chợ - Siêu thị")
                            Text("Nhà sách")
                            Text("Công viên")
                            Text("Cơ sở tôn giáo")
                            Text("Bảo tàng")
                            Text("Khác")
                        } header: {
                            Text("Danh mục địa điểm")
                        }
                        
                        Section {
                            Text("Chọn địa điểm trên bản đồ")
                                .onTapGesture {
                                    showingLocationPicker = true
                                }
                                .sheet(isPresented: $showingLocationPicker) {
                                                LocationPickerView()
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
                            Text("Latitude: \(place.lat), Longitude: \(place.long)")
                                .font(.system(size: 12))
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                
                
            }
            .navigationTitle("Bạn muốn đến đâu?")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        isSearchView.toggle()
                    } label: {
                        Image(systemName: "arrowshape.backward.fill")
                    }
                }
            }
            .accentColor(.red)
        }
    }
}
