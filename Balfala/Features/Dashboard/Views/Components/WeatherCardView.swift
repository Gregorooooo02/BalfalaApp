import SwiftUI

struct WeatherCardView: View {
    @ObservedObject var weatherService: WeatherService
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background / image or gradient
            LinearGradient(
                colors: [Color.blue.opacity(0.6), Color.teal.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay(
                // Optional: image with transparency
                Color.black.opacity(0.2)
            )
            
            VStack(alignment: .leading, spacing: 8) {
                Text(weatherService.currentWeather.description)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))
                
                HStack (alignment: .bottom) {
                    Text(currentFormattedDate())
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Label(
                            weatherService.currentWeather.waterTemperature,
                            systemImage: "water.waves"
                        )
                        Label(
                            weatherService.currentWeather.airTemperature,
                            systemImage: "sun.max.fill"
                        )
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                }
            }
            .padding(16)
        }
        .frame(height: 140)
        .cornerRadius(16)
    }
    
    private func currentFormattedDate() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pl_PL")
        formatter.dateFormat = "EEEE, d MMMM"
        let dateString = formatter.string(from: Date())
        
        return dateString.capitalized
    }
}

#Preview {
    DashboardView()
}
