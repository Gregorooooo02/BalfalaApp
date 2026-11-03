import SwiftUI
import SwiftData

struct HouseOccupancyBannerView: View {
    var occupiedCount: Int
    var totalCount: Int = 6
    
    var body: some View {
        HStack {
            Image(systemName: "house")
                .foregroundStyle(Color.appPrimaryBlue)
                .padding(8)
                .cornerRadius(8)
            
            Text("\(occupiedCount) z \(totalCount) domków obecnie zajętych")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(Color.appPrimaryBlue)
            
            Spacer()
        }
        .padding(8)
        .background(Color.appSecondaryBlue)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 2)
    }
}
