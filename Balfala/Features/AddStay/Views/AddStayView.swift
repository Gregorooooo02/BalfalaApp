import SwiftUI
import SwiftData

struct AddStayView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // Form inputs
    @State private var guestName: String = ""
    @State private var adultsCount: Int = 0
    @State private var childrenCount: Int = 0
    
    @State private var startDate: Date? = nil
    @State private var endDate: Date? = nil
    
    @State private var notes: String = ""
    
    @Query private var houses: [House]
    
    // State of chosen house (connected via NavigationLink to HouseSelectionView)
    @State private var selectedHouseName: String? = nil
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color.appBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Section heading
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Nowe zameldowanie")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.appThirdBlue)
                            
                            Text("Krótka notatka pobytu")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        // 1. Name of the guest
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Imię gościa")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.appThirdBlue)
                            
                            TextField("Imię i nazwisko", text: $guestName)
                                .padding()
                                .background(.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            Color.appCardBorder,
                                            lineWidth: 1
                                        )
                                )
                        }
                        .padding(.horizontal)
                        
                        // 2. Number of adults and children
                        HStack(spacing: 16) {
                            // Adults
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Dorośli")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color.appThirdBlue)
                                
                                HStack {
                                    Image(systemName: "person")
                                        .foregroundStyle(Color.appPrimaryBlue)
                                    Picker("Dorośli", selection: $adultsCount) {
                                        ForEach(0...6, id: \.self) { number in
                                            Text("\(number)").tag(number)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .frame(
                                        maxWidth: .infinity,
                                        alignment: .leading
                                    )
                                }
                                .padding()
                                .background(.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            Color.appCardBorder,
                                            lineWidth: 1
                                        )
                                )
                            }
                            
                            // Children
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Dzieci")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color.appThirdBlue)
                                
                                HStack {
                                    Image(systemName: "teddybear")
                                        .foregroundStyle(Color.appPrimaryBlue)
                                    Picker(
                                        "Dzieci",
                                        selection: $childrenCount
                                    ) {
                                        ForEach(0...6, id: \.self) { number in
                                            Text("\(number)").tag(number)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .frame(
                                        maxWidth: .infinity,
                                        alignment: .leading
                                    )
                                }
                                .padding()
                                .background(.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            Color.appCardBorder,
                                            lineWidth: 1
                                        )
                                )
                            }
                        }
                        .padding(.horizontal)
                        
                        // 3. Date of visit (NavigationLink to DateSelectionView)
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Czas pobytu")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color.appThirdBlue)
                                
                                Spacer()
                                
                                if let start = startDate, let end = endDate {
                                    Text("\(numberOfNights(from: start, to: end)) noce")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            NavigationLink(destination: DateSelectionView(selectedStartDate: $startDate, selectedEndDate: $endDate)) {
                                HStack(spacing: 12) {
                                    Image(systemName: "calendar")
                                        .foregroundStyle(Color.appPrimaryBlue)
                                        .font(.title3)
                                    
                                    if let start = startDate, let end = endDate {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Przyjazd")
                                                .font(.caption2)
                                                .foregroundStyle(.secondary)
                                            Text(formatDate(start))
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundStyle(.primary)
                                        }
                                        
                                        Image(systemName: "arrow.right")
                                            .foregroundStyle(.secondary)
                                            .font(.caption)
                                            .padding(.horizontal, 4)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Wyjazd")
                                                .font(.caption2)
                                                .foregroundStyle(.secondary)
                                            Text(formatDate(end))
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundStyle(.primary)
                                        }
                                    } else {
                                        Text("Wybierz czas pobytu")
                                            .font(.subheadline)
                                            .fontWeight(.regular)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            Color.appCardBorder,
                                            lineWidth: 1
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal)
                        
                        // 4. Select house (NavigationLink to HouseSelectionView)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Domek")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.appThirdBlue)
                            
                            NavigationLink(destination: HouseSelectionView(
                                selectedHouseName: $selectedHouseName,
                                guestName: guestName,
                                adultsCount: adultsCount,
                                childrenCount: childrenCount,
                                startDate: startDate,
                                endDate: endDate
                            )) {
                                HStack {
                                    Image(systemName: "map")
                                        .foregroundStyle(Color.appPrimaryBlue)
                                        .font(.title3)
                                    
                                    Text(selectedHouseName != nil ? "Domek nr \(selectedHouseName!)" : "Wybierz na mapie")
                                        .font(.subheadline)
                                        .fontWeight(selectedHouseName == nil ? .regular : .semibold)
                                        .foregroundStyle(selectedHouseName == nil ? .secondary : .primary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(Color.appCardBackground)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            Color.appCardBorder,
                                            lineWidth: 1
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal)
                        
                        // 5. Notes
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Notatki")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color.appThirdBlue)
                                
                                Spacer()
                                
                                Text("Opcjonalne")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            
                            TextEditor(text: $notes)
                                .frame(height: 80)
                                .padding(8)
                                .background(.white)
                                .scrollContentBackground(.hidden)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            Color.appCardBorder,
                                            lineWidth: 1
                                        )
                                )
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                            .frame(height: 80)
                    }
                    .padding(.vertical)
                }
                        
                // Save button on the bottom of the view
                VStack {
                    Button(action: {
                        saveStay()
                    }) {
                        Label("Zapisz pobyt", systemImage: "checkmark")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isFormValid ? Color.appPrimaryBlue : Color.gray.opacity(0.4))
                            .cornerRadius(14)
                            .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: -2)
                    }
                    .disabled(!isFormValid)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                .background(
                    LinearGradient(
                        colors: [
                            Color.appBackground.opacity(0),
                            Color.appBackground
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 90)
                    .ignoresSafeArea()
                )
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.appPrimaryBlue)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Dodaj pobyt")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.appThirdBlue)
                }
            }
        }
    }
    
    // 250: Calculate number of nights
    private func numberOfNights(from start: Date, to end: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: start, to: end)
        return max(1, components.day ?? 1)
    }
    
    // 257: Formatting the date
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pl_PL")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }
    
    // 265: Check, if everything is filled
    private var isFormValid: Bool {
        let isNameFilled = !guestName.trimmingCharacters(
            in: .whitespaces
        ).isEmpty
        let areGuestsSelected = (adultsCount + childrenCount) > 0
        let areDatesSelected = startDate != nil && endDate != nil
        let isHouseSelected = selectedHouseName != nil
        
        return isNameFilled && areGuestsSelected && areDatesSelected && isHouseSelected
    }
    
    // 277: Save stay to SwiftData
    private func saveStay() {
        let finalStart = startDate ?? Date()
        let finalEnd = endDate ?? Calendar.current.date(byAdding: .day, value: 4, to: finalStart)!
        
        // Match house by name or ID string
        let matchedHouse = houses.first(where: { $0.name == selectedHouseName || $0.id == selectedHouseName })
        
        let newStay = Stay(
            guestName: guestName.isEmpty ? "Nowy gość" : guestName,
            adultsCount: adultsCount,
            childrenCount: childrenCount,
            startDate: finalStart,
            endDate: finalEnd,
            notes: notes.isEmpty ? nil : notes,
            house: matchedHouse
        )
        
        modelContext.insert(newStay)
        try? modelContext.save()
        dismiss()
    }
}
