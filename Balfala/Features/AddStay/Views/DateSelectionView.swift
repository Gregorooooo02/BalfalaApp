import SwiftUI

struct DateSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Binding to pass selected dates back to AddStayView
    @Binding var selectedStartDate: Date?
    @Binding var selectedEndDate: Date?
    
    // Internal state for temporary selection and calendar navigation
    @State private var tempStartDate: Date?
    @State private var tempEndDate: Date?
    @State private var displayedMonth: Date = Date()
    
    private let calendar = Calendar.current
    
    init(selectedStartDate: Binding<Date?>, selectedEndDate: Binding<Date?>) {
        self._selectedStartDate = selectedStartDate
        self._selectedEndDate = selectedEndDate
        self._tempStartDate = State(initialValue: selectedStartDate.wrappedValue)
        self._tempEndDate = State(initialValue: selectedEndDate.wrappedValue)
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Background color (warm, sandy yellow)
                Color.appBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Header section: "Do kiedy zostają?"
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Do kiedy zostają?")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.appThirdBlue)
                            
                            Text("Wybierz datę przyjazdu i wyjazdu.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        // Top summary card showing selected arrival and departure
                        selectedRangeCard
                            .padding(.horizontal)
                        
                        // Calendar container card
                        calendarContainerCard
                            .padding(.horizontal)
                        
                        // Bottom summary banner
                        if let start = tempStartDate, let end = tempEndDate {
                            nightsSummaryBanner(start: start, end: end)
                                .padding(.horizontal)
                        }
                        
                        // Bottom spacing to allow content to scroll nicely under the gradient mask
                        Spacer()
                            .frame(height: 110)
                    }
                    .padding(.vertical)
                }
                
                // Bottom confirmation button with background gradient matching appBackground
                VStack {
                    Button(action: {
                        selectedStartDate = tempStartDate
                        selectedEndDate = tempEndDate
                        dismiss()
                    }) {
                        let nights = (tempStartDate != nil && tempEndDate != nil) ? numberOfNights(from: tempStartDate!, to: tempEndDate!) : 0
                        Text(nights > 0 ? "Zatwierdź daty · \(nights) noce" : "Zatwierdź daty")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(tempStartDate != nil && tempEndDate != nil ? Color.appPrimaryBlue : Color.gray.opacity(0.4))
                            .cornerRadius(14)
                            .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: -2)
                    }
                    .disabled(tempStartDate == nil || tempEndDate == nil)
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
            .navigationBarBackButtonHidden(true) // Ukrywamy domyślny przycisk nawigacji, żeby użyć naszego spójnego projektu
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.appPrimaryBlue)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Daty pobytu")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.appThirdBlue)
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    // Top card displaying current check-in and check-out selection
    private var selectedRangeCard: some View {
        HStack(spacing: 12) {
            // Arrival info
            VStack(alignment: .leading, spacing: 2) {
                Text("PRZYJAZD")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                
                Text(tempStartDate != nil ? formatDateShort(tempStartDate!) : "-")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.appThirdBlue)
            }
            
            Spacer()
            
            Image(systemName: "arrow.right")
                .foregroundStyle(.secondary)
                .font(.caption)
            
            Spacer()
            
            // Departure info
            VStack(alignment: .trailing, spacing: 2) {
                Text("WYJAZD")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                
                Text(tempEndDate != nil ? formatDateShort(tempEndDate!) : "-")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.appThirdBlue)
            }
        }
        .padding()
        .background(Color.appCardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appCardBorder, lineWidth: 1)
        )
    }
    
    // Main calendar card with month switcher and grid
    private var calendarContainerCard: some View {
        VStack(spacing: 16) {
            // Month and Year header with navigation arrows
            HStack {
                Text(monthYearString(for: displayedMonth))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appThirdBlue)
                
                Spacer()
                
                HStack(spacing: 20) {
                    Button(action: { changeMonth(by: -1) }) {
                        Image(systemName: "chevron.left")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.appPrimaryBlue)
                    }
                    
                    Button(action: { changeMonth(by: 1) }) {
                        Image(systemName: "chevron.right")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.appPrimaryBlue)
                    }
                }
            }
            
            // Days of the week headers (P, W, Ś, C, P, S, N)
            HStack {
                let symbols = ["P", "W", "Ś", "C", "P", "S", "N"]
                ForEach(symbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Days grid for the current month
            let days = daysInMonth(for: displayedMonth)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 8) {
                ForEach(Array(days.enumerated()), id: \.offset) { index, date in
                    if let date = date {
                        dayCell(for: date)
                    } else {
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }
        }
        .padding()
        .background(Color.appCardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appCardBorder, lineWidth: 1)
        )
    }
    
    // Individual day cell with connected range styling matching Figma
    private func dayCell(for date: Date) -> some View {
        let isSelectedStart = isSameDay(date, tempStartDate)
        let isSelectedEnd = isSameDay(date, tempEndDate)
        let isInRange = isDateInSelectedRange(date)
        let isCurrentMonth = calendar.isDate(date, equalTo: displayedMonth, toGranularity: .month)
        
        let isStartOrEnd = isSelectedStart || isSelectedEnd
        
        return Button(action: {
            handleDateSelection(date)
        }) {
            ZStack {
                // Continuous background highlight for range
                if isSelectedStart && tempEndDate != nil {
                    HStack(spacing: 0) {
                        Spacer()
                        Rectangle()
                            .fill(Color.appSecondaryBlue)
                            .frame(width: 20, height: 36)
                    }
                } else if isSelectedEnd && tempStartDate != nil {
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(Color.appSecondaryBlue)
                            .frame(width: 20, height: 36)
                        Spacer()
                    }
                } else if isInRange {
                    Rectangle()
                        .fill(Color.appSecondaryBlue)
                        .frame(height: 36)
                }
                
                // Circle for selected start/end points
                if isStartOrEnd {
                    Circle()
                        .fill(Color.appPrimaryBlue)
                        .frame(width: 36, height: 36)
                }
                
                // Day number text
                Text("\(calendar.component(.day, from: date))")
                    .font(.subheadline)
                    .fontWeight(isStartOrEnd ? .bold : .regular)
                    .foregroundStyle(isStartOrEnd ? .white : (isCurrentMonth ? Color.appThirdBlue : .secondary.opacity(0.4)))
            }
            .frame(height: 40)
        }
        .buttonStyle(.plain)
    }
    
    // Bottom summary banner matching Figma layout
    private func nightsSummaryBanner(start: Date, end: Date) -> some View {
        let nights = numberOfNights(from: start, to: end)
        
        return HStack(spacing: 12) {
            Image(systemName: "moon.fill")
                .foregroundStyle(Color.appPrimaryBlue)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(nights) noce")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appPrimaryBlue)
                
                Text("\(formatDateFullRange(start: start, end: end))")
                    .font(.caption)
                    .foregroundStyle(Color.appPrimaryBlue)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.appSecondaryBlue.opacity(0.5))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appCardBorder, lineWidth: 1)
        )
    }
    
    // MARK: - Logic & Helpers
    
    private func handleDateSelection(_ date: Date) {
        if tempStartDate == nil || (tempStartDate != nil && tempEndDate != nil) {
            tempStartDate = date
            tempEndDate = nil
        } else if let start = tempStartDate {
            if date < start {
                tempStartDate = date
            } else {
                tempEndDate = date
            }
        }
    }
    
    private func isSameDay(_ date1: Date?, _ date2: Date?) -> Bool {
        guard let d1 = date1, let d2 = date2 else { return false }
        return calendar.isDate(d1, inSameDayAs: d2)
    }
    
    private func isDateInSelectedRange(_ date: Date) -> Bool {
        guard let start = tempStartDate, let end = tempEndDate else { return false }
        return date > start && date < end
    }
    
    private func changeMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: displayedMonth) {
            displayedMonth = newMonth
        }
    }
    
    private func monthYearString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pl_PL")
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date).capitalized
    }

    private func formatDateShort(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pl_PL")
        formatter.dateFormat = "E, d MMMM"
        return formatter.string(from: date)
    }
    
    private func formatDateFullRange(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pl_PL")
        formatter.dateFormat = "d"
        let startDay = formatter.string(from: start)
        
        formatter.dateFormat = "d LLLL yyyy"
        let endString = formatter.string(from: end)
        
        return "\(startDay)–\(endString)"
    }
    
    private func numberOfNights(from start: Date, to end: Date) -> Int {
        let components = calendar.dateComponents([.day], from: start, to: end)
        return max(1, components.day ?? 1)
    }
    
    private func daysInMonth(for date: Date) -> [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: date),
              let firstMonthDay = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: firstMonthDay)
        let adjustedFirstWeekday = (firstWeekday + 5) % 7
        
        var days: [Date?] = []
        
        for i in (0..<adjustedFirstWeekday).reversed() {
            if let prevDate = calendar.date(byAdding: .day, value: -i - 1, to: firstMonthDay) {
                days.append(prevDate)
            }
        }
        
        for day in range {
            if let currentDayDate = calendar.date(byAdding: .day, value: day - 1, to: firstMonthDay) {
                days.append(currentDayDate)
            }
        }
        
        let remainingDays = (7 - (days.count % 7)) % 7
        for i in (0..<remainingDays) {
            if let lastDay = days.compactMap({ $0 }).last,
               let nextDate = calendar.date(byAdding: .day, value: i + 1, to: lastDay) {
                days.append(nextDate)
            }
        }
        
        return days
    }
}
