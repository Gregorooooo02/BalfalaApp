import SwiftUI

struct StayRowView: View {
    var stay: Stay

    var body: some View {
        HStack(spacing: 12) {
            // Inicjały gościa w awatarze (używamy appPrimaryBlue i appSecondaryBlue)
            Text(getInitials(for: stay.guestName))
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(Color.appPrimaryBlue)
                .frame(width: 40, height: 40)
                .background(Color.appSecondaryBlue)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(stay.guestName)
                    .font(.headline)
                    .foregroundStyle(Color.appThirdBlue)
                
                // Formatowanie zakresu dat i domu (używamy zmiennej house zamiast cabin)
                Text(formatDateRange(start: stay.startDate, end: stay.endDate) + (stay.house != nil ? " · \(stay.house!.name)" : ""))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color.appCardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.appCardBorder, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 1)
    }
    
    private func getInitials(for name: String) -> String {
        let components = name.split(separator: " ")
        if let first = components.first, let last = components.dropFirst().first {
            return "\(first.prefix(1))\(last.prefix(1))"
        }
        return String(name.prefix(2)).uppercased()
    }
    
    private func formatDateRange(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pl_PL")
        formatter.dateFormat = "d"
        let startDay = formatter.string(from: start)
        
        formatter.dateFormat = "d LLLL"
        let endMonth = formatter.string(from: end)
        
        return "\(startDay)–\(endMonth)"
    }
}
