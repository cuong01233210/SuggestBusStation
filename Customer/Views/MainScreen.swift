//
//  MainScreen.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 27/09/2023.
//

import SwiftUI

struct MainScreen: View {
    @State var choiceMade = "Options"
    @State var isPresentingAnotherView1: Bool = false
    @State var isPresentingAnotherView2: Bool = false
    @State var isPresentingPersonalIn4: Bool = false
    @State var isPresentingInputScreen : Bool = false
    @State var isPresentingCommentView: Bool = false
    @Binding var email : String
    @Binding var token: String
    @State var outputData : OutputData = OutputData(route: "test", stationStartName: "test", stationEndName: "test", distanceInMeters: 0, stationStartLat: 0.0, stationStartLong: 0.0, stationEndLat: 0.0, stationEndLong: 0.0)

    @State var outputData2 : OutputData2 = OutputData2(startLocation: "test", startLocationLat: 21, startLocationLong: 105, minDistances: [], minDistancesStations: [], minRoutes: [], startDistance: 0, startStationLat: 21.1, startStationLong: 105.1)
    var width: CGFloat = 200
    var height: CGFloat = 100
    var name = ""
    var backgroundColor: Color = .blue
    @Binding var isLoggedIn : Bool
    
    //@State private var isPresentingAnotherView = false
    var body: some View {
        NavigationView{
            VStack {
                List {
                    ItemView(name: "Tìm kiếm tuyến đường", systemName: "bus.fill")
                        .onTapGesture {
                        isPresentingInputScreen.toggle()
                    }
                        .fullScreenCover(isPresented: $isPresentingInputScreen) {
                            InputScreen(outputData: $outputData, outputData2: $outputData2, isPresentingInputScreen: $isPresentingInputScreen)
                           // AnotherView1(isPresentingAnotherView1: $isPresentingAnotherView1)
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
                    ItemView(name: "Thông tin các tuyến xe buýt")
                    ItemView(name: "Yêu thích")
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
