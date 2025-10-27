import Foundation
import SwiftData

@Model
final class FavoriteCity {
    var id: Int
    var name: String
    var country: String?
    var latitude: Double
    var longitude: Double
    var currentWeather: Data?
    var forecast: Data?
    var addedAt: Date
    
    init(id: Int, name: String, country: String?, latitude: Double, longitude: Double,
         currentWeather: Data? = nil, forecast: Data? = nil) {
        self.id = id
        self.name = name
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
        self.currentWeather = currentWeather
        self.forecast = forecast
        self.addedAt = Date()
    }
}

extension FavoriteCity {
    var decodedCurrentWeather: CurrentWeatherResponse? {
        guard let data = currentWeather else { return nil }
        return try? JSONDecoder().decode(CurrentWeatherResponse.self, from: data)
    }
    
    var decodedForecast: ForecastResponse? {
        guard let data = forecast else { return nil }
        return try? JSONDecoder().decode(ForecastResponse.self, from: data)
    }
}
