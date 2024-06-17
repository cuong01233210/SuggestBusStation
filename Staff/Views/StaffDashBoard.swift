//
//  StaffDashBoard.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 28/12/2023.
//

import SwiftUI

struct StaffDashBoard: View {
    @Binding var isLoggedIn : Bool
    @State var checkComment: Bool = false
    @State var busStationsManage : Bool = false
    @State var showBusesManage: Bool = false
    @EnvironmentObject var appData: AppData
    let sampleProducts = (1...50).map { Product(id: $0, name: "Product \($0)") }
    var body: some View {
        NavigationView{
            VStack {
                List {
                    ItemView(name: "Hiển thị đánh giá người dùng", systemName: "doc.append")
                        .onTapGesture {
                        checkComment.toggle()
                    }
                        .fullScreenCover(isPresented: $checkComment) {
                            CheckComment(products: sampleProducts, checkComment: $checkComment)
                           // AnotherView1(isPresentingAnotherView1: $isPresentingAnotherView1)
                    }
                    
                    ItemView(name: "Tuyến đường giờ cao điểm bị tắc")
                    ItemView(name: "Quản lý thông tin các tuyến xe buýt", systemName: "bus.doubledecker")
                        .onTapGesture {
                            showBusesManage.toggle()
                        }
                        .fullScreenCover(isPresented: $showBusesManage) {
                            BusesManage(showBusesManage: $showBusesManage)
                        }
                    ItemView(name: "Quản lý thông tin các trạm xe buýt", systemName: "house.and.flag.fill")
                        .onTapGesture {
                            busStationsManage.toggle()
                        }
                        .fullScreenCover(isPresented: $busStationsManage) {
                            BusStationsManage( busStationsManage: $busStationsManage)
                        }
                    ItemView(name: "Yêu thích")
                    ItemView(name: "Thông tin về app")
                }
                
            }
                .navigationTitle("Xin chào!")
                .toolbar{
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button{
                            isLoggedIn.toggle()
                            appData.loadDataBusesManage = 0 // chua load
                            appData.loadDataStationsManage = false
                            appData.userRole  = ""
                            appData.token = ""
                            appData.hasUpdatedPreStations  = false
                            appData.hasUpdatedPreBuses = false
                            
                      } label: {
                            Image(systemName: "arrowshape.backward.fill")
                        }
                    }
                }
                .accentColor(.red)
        }
        
    
        .ignoresSafeArea()
    
    }
}

//#Preview {
//    StaffDashBoard()
//}
