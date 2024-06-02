import SwiftUI

struct ResultCard: View {
    let presentData: ResultRoute
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                ForEach(0..<presentData.buses.count, id: \.self) { index in
                    if presentData.buses[index] == "Walk" {
                        Image(systemName: "figure.walk")
                    } else {
                        Text(presentData.buses[index])
                            .foregroundColor(.blue) // Text color for bus numbers
                    }
                    // Display arrow except for the last item
                    if index < presentData.buses.count - 1 {
                        Image(systemName: "arrow.right")
                            .foregroundColor(.gray) // Color for arrow icons
                    }
                }
                Spacer()
            }
            
            HStack {
                Text("\(presentData.transportHour) giờ \(presentData.transportMinute) phút")
                    .foregroundColor(.black) // Primary text color
                Text(String(format: "%02d:%02d", presentData.startHour, presentData.startMinute))
                    .foregroundColor(.green)
                Image(systemName: "arrow.right")
                    .foregroundColor(.gray)
                Text(String(format: "%02d:%02d", presentData.endHour, presentData.endMinute))
                    .foregroundColor(.red)
            }
            
            Text("Trạm xuất phát: \(presentData.startStation)")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text("\(Int(presentData.cost)) đ")
                .foregroundColor(.green)
                .padding(.top, 8)
        }
        .padding() // Inner padding for content
        .background(Color.white) // Background color of the card
        .cornerRadius(10)
        .shadow(color: Color.gray.opacity(0.2), radius: 2, x: 0, y: 2)
        .padding(.horizontal, 5) // Outer padding to ensure 5px margin on both sides
    }
}
