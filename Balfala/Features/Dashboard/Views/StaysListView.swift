import SwiftUI
import SwiftData

struct StaysListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Stay.startDate, order: .forward) private var allStays: [Stay]
    
    // Enum for segment selection matching Figma tabs
    enum StayFilterSegment: String, CaseIterable, Identifiable {
        case upcoming = "Najbliższe"
        case ongoing = "W trakcie"
        case history = "Historia"
        
        var id: String { self.rawValue }
    }
    
    @State private var selectedSegment: StayFilterSegment = .upcoming
    @State private var showingAddStay = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.appBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Title section
                    VStack(alignment: .leading, spacing: 4) {
                        Text("DOMKI NAD MORZEM BALFALA")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.appPrimaryBlue)
                            .tracking(1.2)
                        
                        Text("Pobyty")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.appThirdBlue)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // Custom segmented control
                    segmentedPicker
                        .padding(.horizontal)
                    
                    // Sorting and filter action bar
                    filterActionBar
                        .padding(.horizontal)
                    
                    // Grouped list of stays according to selected tab
                    let groupedStays = filteredAndGroupedStays()
                    
                    if groupedStays.isEmpty {
                        emptyStateView
                            .padding(.top, 40)
                    } else {
                        VStack(spacing: 20) {
                            ForEach(groupedStays, id: \.title) { group in
                                stayGroupSection(group: group)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                        .frame(height: 90)
                }
                .padding(.vertical)
            }
            
            // Bottom floating action button
            VStack {
                Button(action: {
                    showingAddStay.toggle()
                }) {
                    Label("Dodaj pobyt", systemImage: "plus")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.appPrimaryBlue)
                        .cornerRadius(14)
                        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: -2)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .background(
                LinearGradient(
                    colors: [Color.appBackground.opacity(0), Color.appBackground],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 90)
                .ignoresSafeArea()
            )
        }
        .sheet(isPresented: $showingAddStay) {
            AddStayView()
        }
    }
    
    // MARK: - Subviews
    
    // Custom segmented picker
    private var segmentedPicker: some View {
        HStack(spacing: 0) {
            ForEach(StayFilterSegment.allCases) { segment in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedSegment = segment
                    }
                }) {
                    Text(segment.rawValue)
                        .font(.subheadline)
                        .fontWeight(
                            selectedSegment == segment ? .bold : .medium
                        )
                        .foregroundStyle(
                            selectedSegment == segment ? Color.appPrimaryBlue
                            : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            selectedSegment == segment ? Color.white : Color.clear
                        )
                        .cornerRadius(10)
                        .shadow(color: selectedSegment == segment ? Color.black.opacity(0.04) : Color.clear, radius: 4, x: 0, y: 2)
                }
            }
        }
        .padding(4)
        .background(Color.appSecondaryBlue)
        .cornerRadius(12)
    }
    
    // Sort & filter options row
    private var filterActionBar: some View {
        HStack {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "line.3.horizontal.decrease")
                        .font(.caption)
                    Text("Najbliższy przyjazd")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .foregroundStyle(Color.appThirdBlue)
                
                Spacer()
                
                Button(action: {
                    // Filter action sheet or modal
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "slider.horizontal.3")
                        Text("Filtry")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.appThirdBlue)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .cornerRadius(10)
                }
            }
        }
    }
    
    private func stayGroupSection(group: (title: String, stays: [Stay])) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(group.title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appThirdBlue)
                
                Spacer()
                
                let count = group.stays.count
                Text("\(count) \(count == 1 ? "pobyt" : "pobyty")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            VStack(spacing: 8) {
                ForEach(group.stays) { stay in
                    NavigationLink(
                        destination: Text("Szczegóły pobytu: \(stay.guestName)")) {
                            StayRowView(stay: stay)
                        }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 8) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            
            Text("Brak pobytów w tej kategorii")
                .font(.headline)
                .foregroundStyle(Color.appThirdBlue)
            
            Text("Nowo dodane pobyty pojawią się tutaj automatycznie.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Logic & Grouping
    
    private func filteredAndGroupedStays() -> [(title: String, stays: [Stay])] {
        let today = Calendar.current.startOfDay(for: Date())
        
        let filteredStays: [Stay]
        
        switch selectedSegment {
        case .upcoming:
            filteredStays = allStays.filter { Calendar.current.startOfDay(for: $0.startDate) >= today
            }
        case .ongoing:
            filteredStays = allStays.filter {
                $0.startDate <= Date() && $0.endDate >= Date()
            }
        case .history:
            filteredStays = allStays.filter {
                Calendar.current.startOfDay(for: $0.endDate) < today
            }
        }
        
        // Grouping by startDate
        let groupedDictionary = Dictionary(grouping: filteredStays) {
            stay -> Date in
            Calendar.current.startOfDay(for: stay.startDate)
        }
        
        // Sorting groups chronologically
        let sortedKeys = groupedDictionary.keys.sorted()
        
        return sortedKeys.map { date in
            let title = formatGroupHeaderDate(date, today: today)
            return (title: title, stays: groupedDictionary[date] ?? [])
        }
    }
    
    private func formatGroupHeaderDate(_ date: Date, today: Date) -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pl_PL")
        
        if calendar.isDateInToday(date) {
            formatter.dateFormat = "d MMMM"
            return "Dzisiaj · \(formatter.string(from: date))"
        } else if calendar.isDateInTomorrow(date) {
            formatter.dateFormat = "d MMMM"
            return "Jutro · \(formatter.string(from: date))"
        } else {
            formatter.dateFormat = "d MMMM"
            return "Później · \(formatter.string(from: date))"
        }
    }
}

#Preview {
    StaysListView()
        .modelContainer(for: [Stay.self, House.self], inMemory: true)
}
