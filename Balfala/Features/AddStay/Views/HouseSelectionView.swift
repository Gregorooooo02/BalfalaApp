import SwiftUI
import SwiftData

struct HouseSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Fetch all existing stays from SwiftData to check house collisions dynamically
    @Query private var allStays: [Stay]
    
    // Binding to pass selected house name back to AddStayView
    @Binding var selectedHouseName: String?
    
    // Information from current stay form to display in the header card
    var guestName: String
    var adultsCount: Int
    var childrenCount: Int
    var startDate: Date?
    var endDate: Date?
    
    // Internal state for temporary house selection
    @State private var tempSelectedHouse: String?
    
    init(selectedHouseName: Binding<String?>, guestName: String, adultsCount: Int, childrenCount: Int, startDate: Date?, endDate: Date?) {
        self._selectedHouseName = selectedHouseName
        self.guestName = guestName
        self.adultsCount = adultsCount
        self.childrenCount = childrenCount
        self.startDate = startDate
        self.endDate = endDate
        self._tempSelectedHouse = State(initialValue: selectedHouseName.wrappedValue)
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Background color (warm, sandy yellow)
                Color.appBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Header info card with stay summary (dates, guest, guests count)
                        staySummaryHeaderCard
                            .padding(.horizontal)
                            .padding(.top, 10)
                        
                        // House selection grid card with dynamic availability check
                        houseGridCard
                            .padding(.horizontal)
                        
                        // Selected house details card (if any house is selected)
                        if let houseId = tempSelectedHouse, let house = evaluatedHouses().first(where: { $0.id == houseId }) {
                            selectedHouseDetailsCard(house: house)
                                .padding(.horizontal)
                        }
                        
                        // Bottom spacing for smooth scrolling under the gradient mask
                        Spacer()
                            .frame(height: 120)
                    }
                    .padding(.vertical)
                }
                
                // Bottom confirmation button with background gradient
                bottomConfirmButton
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.appThirdBlue)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Wybierz domek")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.appThirdBlue)
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    // Header summary card matching Figma prototype
    private var staySummaryHeaderCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(formatDateRange(start: startDate, end: endDate))
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appThirdBlue)
                
                Spacer()
                
                // Available houses badge counting currently free houses
                let availableCount = evaluatedHouses().filter({ $0.isAvailable }).count
                Text("\(availableCount) dostępne")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appPrimaryBlue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.appSecondaryBlue)
                    .cornerRadius(12)
            }
            
            Text("\(guestName.isEmpty ? "Gość" : guestName) · \(adultsCount + childrenCount) osób · \(numberOfNights) noce")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.appCardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appCardBorder, lineWidth: 1)
        )
    }
    
    // Grid container representing the houses layout
    private var houseGridCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Dostępne domki")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(Color.appThirdBlue)
            
            // 2-column grid of 6 houses with dynamic availability status
            let houses = evaluatedHouses()
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                ForEach(houses, id: \.id) { house in
                    houseCell(house: house)
                }
            }
            
            // Legend
            HStack(spacing: 16) {
                legendItem(title: "Dostępne", color: .white, borderColor: Color.appCardBorder)
                legendItem(title: "Zajęte", color: Color.gray.opacity(0.2), borderColor: .clear)
                legendItem(title: "Wybrane", color: Color.appPrimaryBlue, borderColor: .clear)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color.appCardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appCardBorder, lineWidth: 1)
        )
    }
    
    // Individual house cell in the grid
    private func houseCell(house: (id: String, name: String, isAvailable: Bool)) -> some View {
        let isSelected = tempSelectedHouse == house.id
        
        return Button(action: {
            if house.isAvailable {
                tempSelectedHouse = house.id
            }
        }) {
            VStack(spacing: 4) {
                Text(house.id)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(isSelected ? .white : (house.isAvailable ? Color.appThirdBlue : .secondary))
                
                Text(house.name)
                    .font(.caption2)
                    .foregroundStyle(isSelected ? .white.opacity(0.8) : .secondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 70)
            .background(
                isSelected ? Color.appPrimaryBlue : (house.isAvailable ? Color.white : Color.gray.opacity(0.15))
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.appPrimaryBlue : Color.appCardBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(!house.isAvailable)
    }
    
    // Legend helper component
    private func legendItem(title: String, color: Color, borderColor: Color) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
                .overlay(Circle().stroke(borderColor, lineWidth: 1))
            
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
    
    // Card showing details of the currently selected house
    private func selectedHouseDetailsCard(house: (id: String, name: String, isAvailable: Bool)) -> some View {
        HStack(spacing: 16) {
            Text(house.id)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(Color.appPrimaryBlue)
                .frame(width: 50, height: 50)
                .background(Color.appSecondaryBlue)
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(house.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appThirdBlue)
                
                Text("Dostępny przez wszystkie \(numberOfNights) noce.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.title2)
                .foregroundStyle(Color.appPrimaryBlue)
        }
        .padding()
        .background(Color.appCardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appPrimaryBlue, lineWidth: 1.5)
        )
    }
    
    // Bottom confirmation button with background gradient
    private var bottomConfirmButton: some View {
        VStack {
            Button(action: {
                selectedHouseName = tempSelectedHouse
                dismiss()
            }) {
                Text(tempSelectedHouse != nil ? "Zatwierdź domek" : "Wybierz domek")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(tempSelectedHouse != nil ? Color.appPrimaryBlue : Color.gray.opacity(0.4))
                    .cornerRadius(14)
                    .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: -2)
            }
            .disabled(tempSelectedHouse == nil)
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .background(
            LinearGradient(
                colors: [
                    Color.appBackground.opacity(0.0),
                    Color.appBackground,
                    Color.appBackground
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 120)
            .ignoresSafeArea()
        )
    }
    
    // MARK: - Logic & Helpers
    
    // 235: Evaluates house availability dynamically based on selected date range and existing stays
    private func evaluatedHouses() -> [(id: String, name: String, isAvailable: Bool)] {
        let start = startDate ?? Date()
        let end = endDate ?? Date()
        
        let baseHouses = [
            (id: "01", name: "Bursztyn"),
            (id: "02", name: "Bryza"),
            (id: "03", name: "Mewa"),
            (id: "04", name: "Statua"),
            (id: "05", name: "Fale"),
            (id: "06", name: "Muszla")
        ]
        
        return baseHouses.map { houseInfo in
            let isOccupied = allStays.contains { (stay: Stay) in
                let matchesHouse = (stay.house?.name == houseInfo.name || stay.house?.id == houseInfo.id)
                guard matchesHouse else { return false }
                
                // Overlap condition: (StartA < EndB) && (EndA > StartB)
                let overlaps = (start < stay.endDate) && (end > stay.startDate)
                return overlaps
            }
            
            return (id: houseInfo.id, name: houseInfo.name, isAvailable: !isOccupied)
        }
    }
    
    private var numberOfNights: Int {
        guard let start = startDate, let end = endDate else { return 4 }
        let components = Calendar.current.dateComponents([.day], from: start, to: end)
        return max(1, components.day ?? 4)
    }
    
    private func formatDateRange(start: Date?, end: Date?) -> String {
        guard let start = start, let end = end else { return "Wybierz daty" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pl_PL")
        formatter.dateFormat = "d"
        let startDay = formatter.string(from: start)
        
        formatter.dateFormat = "d LLLL yyyy"
        let endString = formatter.string(from: end)
        
        return "\(startDay)–\(endString)"
    }
}
