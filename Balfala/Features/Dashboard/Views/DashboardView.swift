import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Stay.startDate, order: .forward) private var stays: [Stay]
    @Query private var houses: [House]
    
    @StateObject private var weatherService = WeatherService()
    
    @State private var showingAddStay = false
    @State private var selectedTab = 0 // 0: overview, 1: visits, 2: houses

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                ZStack(alignment: .bottom) {
                    
                    Color.appBackground
                        .ignoresSafeArea()
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("DOMKI NAD MORZEM BALFALA")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.appPrimaryBlue)
                                    .tracking(1.2)
                                
                                Text("Cześć, Aniu!")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.appThirdBlue)
                            }
                            .padding(.horizontal)
                            
                            // Weather widget
                            WeatherCardView(weatherService: weatherService)
                                .padding(.horizontal)
                            
                            // House occupancy banner with dynamically calculated count based on active today stays
                            HouseOccupancyBannerView(
                                occupiedCount: occupiedHousesCount,
                                totalCount: max(houses.count, 6)
                            )
                            .padding(.horizontal)
                            
                            // Section - planned visits
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text("Najbliższe pobyty")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.appThirdBlue)
                                        .padding(.top, 12)
                                    
                                    Spacer()
                                    
                                    Button("Więcej") {
                                        selectedTab = 1
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.appPrimaryBlue)
                                }
                                .padding(.horizontal)
                                
                                if stays.isEmpty {
                                    Text("Brak zaplanowanych pobytów")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal)
                                } else {
                                    VStack(spacing: 8) {
                                        ForEach(Array(stays.prefix(4))) { stay in
                                            NavigationLink(destination: Text("Szczegóły pobytu: \(stay.guestName)")) {
                                                StayRowView(stay: stay)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            // Additional spacing between a button and the tab navigation
                            Spacer()
                                .frame(height: 80)
                        }
                        .padding(.vertical)
                    }
                    
                    // Button to add a visit
                    VStack {
                        Button(action: {
                            showingAddStay.toggle()
                        }) {
                            Label("Dodaj pobyt", systemImage: "plus")
                                .font(.headline)
                                .foregroundColor(.white)
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
                .navigationBarHidden(true)
                .sheet(isPresented: $showingAddStay) {
                    AddStayView()
                }
            }
            .tag(0)
            .tabItem {
                Label("Przegląd", systemImage: "square.grid.2x2")
            }
            
            // Tab 2 - visits
            StaysListView()
                .tag(1)
                .tabItem {
                    Label("Pobyty", systemImage: "calendar")
                }
            
            // Tab 3 - map of houses
            Text("Mapa domków")
                .tag(2)
                .tabItem {
                    Label("Domki", systemImage: "map")
                }
        }
        .tint(.appPrimaryBlue)
        .onAppear {
            // Ensure default houses exist in SwiftData database on first launch
            ensureHousesExist(context: modelContext)
        }
    }
    
    // MARK: - Logic & Helpers
    
    // Calculates how many unique houses have active stays today
    private var occupiedHousesCount: Int {
        let today = Date()
        
        // Filter stays that include the current day
        let activeStays = stays.filter { (stay: Stay) in
            today >= stay.startDate && today <= stay.endDate
        }
        
        // Extract unique house IDs from active stays
        let occupiedHouseIds = activeStays.compactMap { (stay: Stay) -> String? in
            return stay.house?.id
        }
        
        return Set(occupiedHouseIds).count
    }
    
    // Seeds default houses if database is empty to support relations
    private func ensureHousesExist(context: ModelContext) {
        let descriptor = FetchDescriptor<House>()
        if let count = try? context.fetchCount(descriptor), count == 0 {
            let defaultHouses = [
                House(id: "01", name: "Bursztyn", capacity: 4, isOccupied: false),
                House(id: "02", name: "Bryza", capacity: 4, isOccupied: false),
                House(id: "03", name: "Mewa", capacity: 4, isOccupied: false),
                House(id: "04", name: "Statua", capacity: 4, isOccupied: false),
                House(id: "05", name: "Fale", capacity: 4, isOccupied: false),
                House(id: "06", name: "Muszla", capacity: 4, isOccupied: false)
            ]
            defaultHouses.forEach { context.insert($0) }
            try? context.save()
        }
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: [Stay.self, House.self], inMemory: true)
}
