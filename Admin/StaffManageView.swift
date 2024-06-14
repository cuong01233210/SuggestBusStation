//
//  StaffManageView.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 14/6/24.
//

import SwiftUI

struct StaffManageView: View {
    @Binding var presentStaffManageView : Bool
    var body: some View {
        NavigationView {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                .navigationTitle("Admin")
                .toolbar{
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button{
                            presentStaffManageView.toggle()
                        } label: {
                            Image(systemName: "arrowshape.backward.fill")
                        }
                    }
                }
                .accentColor(.red)
        }
        
    }
}


