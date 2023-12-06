//
//  PersonalIn4.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 06/12/2023.
//

import SwiftUI

struct PersonalIn4: View {
    @Binding var isPresentingPersonalIn4: Bool

    var body: some View {
        VStack {
            Text("Thông tin cá nhân")
            List {
                Section{
                    HStack {
                        Text("Họ")
                        Spacer()
                        Text("xxx")
                        Button("Thay đổi"){
                            
                        }
                    }
                }.listSectionSeparator(.hidden)
                   // .background(.red)
                Section{
                    HStack {
                        Text("Tên")
                        Spacer()
                        Text("yyy")
                        Button("Thay đổi"){
                            
                        }
                    }
                }.listSectionSeparator(.hidden)
                Section{
                    HStack {
                        Text("Giới tính")
                        Spacer()
                        Text("xxx")
                        Button("Thay đổi"){
                            
                        }
                    }
                }.listSectionSeparator(.hidden)
                Section{
                    HStack {
                        Text("Ngày sinh")
                        Spacer()
                        Text("xxx")
                        Button("Thay đổi"){
                            
                        }
                    }
                }.listSectionSeparator(.hidden)
                Section{
                    HStack {
                        Text("Số điện thoại")
                        Spacer()
                        Text("Chưa có")
                        Button("Thay đổi/Thêm"){
                            
                        }
                    }
                }.listSectionSeparator(.hidden)
                Section{
                    HStack {
                        Text("Email")
                        Spacer()
                        Text("xxx")
                        Button("Không cần thay đổi"){
                            
                        }
                    }
                }.listSectionSeparator(.hidden)
            }
            .scrollContentBackground(.hidden)
                .background(Color.mint.edgesIgnoringSafeArea(.all))
            Button("Đóng") {
                isPresentingPersonalIn4 = false
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}
//
//#Preview {
//    PersonalIn4()
//}
