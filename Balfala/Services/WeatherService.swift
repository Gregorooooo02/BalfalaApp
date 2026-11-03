import Foundation
import Combine

struct WeatherData {
    var airTemperature: String = "--°"
    var waterTemperature: String = "--°"
    var description: String = "Sprawdzanie pogody..."
}

@MainActor
final class WeatherService: ObservableObject {
    @Published var currentWeather = WeatherData()
    
    private let latitude: Double = 54.4416
    private let longitude: Double = 18.3306
    
    func fetchWeather() async {
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&current=temperature_2m,weather_code"
        
        guard let url = URL(string: urlString) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(
                OpenMeteoResponse.self,
                from: data
            )
            
            let tempAir = Int(round(response.current.temperature2m))
            
            let descriptionText = mapWeatherCodeToPhrase(
                response.current.weatherCode, airTemp: tempAir
            )
            
            let waterTemp = max(14, tempAir - 4)
            
            self.currentWeather = WeatherData(
                airTemperature: "\(tempAir)",
                waterTemperature: "\(waterTemp)",
                description: descriptionText
            )
            
        } catch {
            self.currentWeather = WeatherData(
                airTemperature: "--°",
                waterTemperature: "--°",
                description: "--"
            )
        }
    }
    
    private func mapWeatherCodeToPhrase(
        _ code: Int,
        airTemp: Int
    ) -> String {
        switch code {
        case 0: // Clear weather
            let phrases = [
                "Dzisiaj pięknie i słonecznie",
                "Pełne słońce nad Bałtykiem",
                "Krystalicznie czyste niebo i słońce"
            ]
            return phrases.randomElement()!
        case 1, 2, 3: // Partaly cloudy
            let phrases = [
                "Lekkie chmury, idealnie na spacer",
                "Przyjemna, umiarkowana aura",
                "Słońce przebija się przez chmury"
            ]
            return phrases.randomElement()!
        case 51, 53, 55, 61, 63: // Rain
            let phrases = [
                "Lekki deszcz nad morzem",
                "Czas na kawę w domku - mżamka",
                "Klimatyczny, deszczowy dzień"
            ]
            return phrases.randomElement()!
        default:
            if airTemp > 24 {
                return "Gorący, idealny dzień na plażę!"
            } else {
                return "Spokojny dzień nad morzem"
            }
        }
    }
}

struct OpenMeteoResponse: Codable {
    let current: CurrentWeather
    
    struct CurrentWeather: Codable {
        let temperature2m: Double
        let weatherCode: Int
        
        enum CodingKeys: String, CodingKey {
            case temperature2m = "temperature_2m"
            case weatherCode = "weather_code"
        }
    }
}
