//
//  AdminDashBoard.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 14/6/24.
//

import SwiftUI

struct AdminDashBoard: View {
    @Binding var isLoggedIn : Bool
    @State var presentStaffManageView : Bool = false
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ItemView(name: "Quản lý nhân viên", systemName: "doc.append")
                        .onTapGesture {
                            presentStaffManageView.toggle()
                        }
                        .fullScreenCover(isPresented: $presentStaffManageView) {
                            StaffManageView(presentStaffManageView: $presentStaffManageView)
                        }
                }
                
            }
            .navigationTitle("Admin")
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
        
    }
}

