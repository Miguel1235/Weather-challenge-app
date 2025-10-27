import Foundation
import Observation

enum LoadState: Equatable {
    case idle
    case loading
    case success
    case failure(WeatherApiError)
}

@Observable final class WeatherViewModel {
    var weather: CurrentWeatherResponse?
    var forecast: ForecastResponse?
    
    var weatherState: LoadState = .idle
    var forecastState: LoadState = .idle
    
    func loadWeatherFromCache(weather: CurrentWeatherResponse) {
        self.weather = weather
        weatherState = .success
    }
    
    
    func getCurrentWeather(for city: String) async {
        weatherState = .loading
        let result = await NetworkManager.shared.getCurrentWeather(of: city)
        switch result {
        case .success(let weather):
            self.weather = weather
            weatherState = .success
        case .failure(let error):
            weatherState = .failure(error)
        }
    }
    
    func getForecast(for city: String) async {
        forecastState = .loading
        let result = await NetworkManager.shared.getForecast(of: city)
        forecastState = .success
        switch result {
        case .success(let forecast):
            self.forecast = forecast
            forecastState = .success
        case .failure(let error):
            forecastState = .failure(error)
        }
    }
}
