//
//  MainScreen.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 27/09/2023.
//

import SwiftUI

struct MainScreen: View {
    @State var choiceMade = "Options"
    @State var showBuses = false
    @State var isPresentingPersonalIn4: Bool = false
    @State var isPresentingCommentView: Bool = false
    @State var busStationsManageV2 : Bool = false
    @State var showPreferenceStations: Bool = false
    @State var showSearchView : Bool = false
    
    @Binding var email : String
    @Binding var token: String
    var width: CGFloat = 200
    var height: CGFloat = 100
    var name = ""
    var backgroundColor: Color = .blue
    @Binding var isLoggedIn : Bool
    @State var showPreferenceBuses = false
    //@Binding var suggestPlaces: SuggestPlaces
    //@State private var isPresentingAnotherView = false
    var body: some View {
        NavigationView{
            VStack {
                List {
                    ItemView(name: "Tìm kiếm tuyến đường", systemName: "bus.fill")
                        .onTapGesture {
                        showSearchView.toggle()
                    }

                        .fullScreenCover(isPresented: $showSearchView) {
                           SearchView(showSearchView: $showSearchView)
                        }
                    
                    
                    ItemView(name: "Thông tin cá nhân", systemName: "person.circle")
                        .onTapGesture {
                            isPresentingPersonalIn4.toggle()
                        }
                        .fullScreenCover(isPresented: $isPresentingPersonalIn4) {
                            ShowPersonalIn4(isPresentingPersonalIn4: $isPresentingPersonalIn4,  email: $email, token: $token)
                        }
                    ItemView(name: "Đánh giá / Góp ý", systemName: "envelope.badge.person.crop")
                        .onTapGesture {
                            isPresentingCommentView.toggle()
                        }
                        .fullScreenCover(isPresented : $isPresentingCommentView) {
                            CommentView(isPresentingCommentView: $isPresentingCommentView, token: $token, isLoggedIn: $isLoggedIn)
                        }
                    ItemView(name: "Tuyến đường giờ cao điểm bị tắc")
                    ItemView(name: "Thông tin các tuyến xe buýt", systemName: "bus.doubledecker")
                        .onTapGesture {
                            showBuses.toggle()
                        }
                        .fullScreenCover(isPresented: $showBuses) {
                            ShowBuses( showBuses: $showBuses, token: $token)
                        }
                    ItemView(name: "Tuyến xe buýt yêu thích", systemName: "bus.doubledecker")
                        .onTapGesture {
                            showPreferenceBuses.toggle()
                        }
                        .fullScreenCover(isPresented: $showPreferenceBuses) {
                            PreferenceBuses(showPreferenceBuses: $showPreferenceBuses, token: $token)
                        }
                    ItemView(name: "Thông tin các trạm xe buýt", systemName: "house.and.flag.fill")
                        .onTapGesture {
                            busStationsManageV2.toggle()
                        }
                        .fullScreenCover(isPresented: $busStationsManageV2) {
                            BusStationsManageV2(busStationsManageV2: $busStationsManageV2, token: $token)
                        }
                    ItemView(name: "Trạm xe buýt yêu thích", systemName: "house.and.flag.fill")
                        .onTapGesture {
                            showPreferenceStations.toggle()
                        }
                        .fullScreenCover(isPresented: $showPreferenceStations) {
                            PreferenceStations(showPreferenceStations: $showPreferenceStations, token: $token)
                        }
                    ItemView(name: "Thông tin về app")
                }
                
            }
            
            .navigationTitle("Xin chào!")
            .toolbar{
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button{
                        isLoggedIn.toggle()
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

struct AnotherView1: View {
    @Binding var isPresentingAnotherView1: Bool

    var body: some View {
        VStack {
            Text("Another View")
            Button("Đóng") {
                isPresentingAnotherView1 = false
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}
struct AnotherView2: View {
    @Binding var isPresentingAnotherView2: Bool

    var body: some View {
        VStack {
            Text("Another View2")
            Button("Đóng") {
                isPresentingAnotherView2 = false
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}



//            List {
//                Text("Tìm kiếm trạm và tuyến đường")
//                    .onTapGesture {
//                        isPresentingAnotherView.toggle()
//                    }
//                    .fullScreenCover(isPresented: $isPresentingAnotherView) {
//                        AnotherView(isPresentingAnotherView: $isPresentingAnotherView)
//                    }
//                padding()
//                Text("Đánh giá")
//                    .onTapGesture {
//                        isPresentingAnotherView2.toggle()
//                    }
//                    .fullScreenCover(isPresented: $isPresentingAnotherView2) {
//                        AnotherView2(isPresentingAnotherView2: $isPresentingAnotherView2)
//                    }
//                Text("Thông tin cá nhân")
//            }
