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
    @State var showAppInfo : Bool = false
    @Binding var email : String
    //@Binding var token: String
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
                            ShowPersonalIn4(isPresentingPersonalIn4: $isPresentingPersonalIn4,  email: $email)
                        }
                    ItemView(name: "Đánh giá / Góp ý", systemName: "envelope.badge.person.crop")
                        .onTapGesture {
                            isPresentingCommentView.toggle()
                        }
                        .fullScreenCover(isPresented : $isPresentingCommentView) {
                            CommentView(isPresentingCommentView: $isPresentingCommentView,  isLoggedIn: $isLoggedIn)
                        }
                    
                    ItemView(name: "Thông tin các tuyến xe buýt", systemName: "bus.doubledecker")
                        .onTapGesture {
                            showBuses.toggle()
                        }
                        .fullScreenCover(isPresented: $showBuses) {
                            
                            BusesManage(showBusesManage: $showBuses)
                        }
                    ItemView(name: "Tuyến xe buýt yêu thích", systemName: "bus.doubledecker")
                        .onTapGesture {
                            showPreferenceBuses.toggle()
                        }
                        .fullScreenCover(isPresented: $showPreferenceBuses) {
                            PreferenceBuses(showPreferenceBuses: $showPreferenceBuses)
                        }
                    ItemView(name: "Thông tin các trạm xe buýt", systemName: "house.and.flag.fill")
                        .onTapGesture {
                            busStationsManageV2.toggle()
                        }
                        .fullScreenCover(isPresented: $busStationsManageV2) {
//                            BusStationsManageV2(busStationsManageV2: $busStationsManageV2, token: $token)
                            BusStationsManage(busStationsManage: $busStationsManageV2)
                        }
                    ItemView(name: "Trạm xe buýt yêu thích", systemName: "house.and.flag.fill")
                        .onTapGesture {
                            showPreferenceStations.toggle()
                        }
                        .fullScreenCover(isPresented: $showPreferenceStations) {
                            PreferenceStations(showPreferenceStations: $showPreferenceStations)
                        }
                    ItemView(name: "Thông tin về ứng dụng", systemName: "book.pages")
                        .onTapGesture {
                            showAppInfo.toggle()
                        }
                        .fullScreenCover(isPresented: $showAppInfo) {
                            ShowAppInfo(showAppInfo: $showAppInfo)
                        }
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

