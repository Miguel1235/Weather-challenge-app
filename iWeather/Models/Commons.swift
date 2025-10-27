import Foundation

struct Coordinate: Codable {
    let lon, lat: Double
}

struct WeatherCondition: Codable {
    let description: String
    let icon: String
    
    var iconURL: URL {
        return URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")!
    }
}

struct MainWeatherData: Codable {
    let temp: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let pressure: Int
    let humidity: Int
    
    enum CodingKeys: String, CodingKey {
        case temp, pressure, humidity
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
    }
}

struct Wind: Codable {
    let speed: Double
}

struct Sys: Codable {
    let id: Int?
    let country: String?
    let sunrise: Int?
    let sunset: Int?
    
    var sunriseDate: String? {
        guard let sunrise else { return nil }
        let date = Date(timeIntervalSince1970: TimeInterval(sunrise))
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    var sunsetDate: String? {
        guard let sunset else { return nil }
        let date = Date(timeIntervalSince1970: TimeInterval(sunset))
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
