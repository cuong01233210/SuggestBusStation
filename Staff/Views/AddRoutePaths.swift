//
//  AddRoutePaths.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 19/6/24.
//

import SwiftUI

struct AddRoutePaths: View {
    @Binding var addRoutePaths: Bool
    @Binding var direction: Bool
    @Binding var chieuDi: [BusStation]
    @Binding var chieuVe: [BusStation]
    @State var addPath : Bool = false
    @EnvironmentObject var appData: AppData

    var showingArray: [BusStation] {
        return direction ? chieuVe : chieuDi
    }

    var body: some View {
        NavigationView {
            Group {
                if showingArray.isEmpty {
                    Text("Hãy bổ sung một vài trạm nào")
                } else {
                    List {
                        ForEach(showingArray) { station in
                            Text("\(station.name)")
                        }
                        .onDelete(perform: deleteStation)
                    }
                }
            } .navigationTitle("Bổ sung trạm cho lộ trình")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            addRoutePaths.toggle()
                        } label: {
                            Image(systemName: "arrowshape.backward.fill")
                        }.accentColor(.red)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            addPath.toggle()
                        } label: {
                            Text("Thêm trạm")
                        }
                    }
                }
                .fullScreenCover(isPresented: $addPath, content: {
                    AddPath(addPath: $addPath, direction: $direction, chieuDi: $chieuDi, chieuVe: $chieuVe)
                })
        }
        
    }
    private func deleteStation(at offsets: IndexSet) {
            if direction {
                chieuVe.remove(atOffsets: offsets)
            } else {
                chieuDi.remove(atOffsets: offsets)
            }
        }
}
