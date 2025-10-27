import Foundation

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    let baseUrl = "https://api.openweathermap.org/data/2.5"
    let apiKey = "YOUR_OPENWEATHERMAP_API_KEY_GOES_HERE"
    
    func getCurrentWeather(of city: String) async -> Result<CurrentWeatherResponse, WeatherApiError> {
        guard let url = URL(string: "\(baseUrl)/weather/?q=\(city)&appid=\(apiKey)&units=metric") else {
            return .failure(.invalidURL)
        }
                
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            let statusCode = (response as? HTTPURLResponse)?.statusCode
                        
            switch statusCode {
            case 401:
                return .failure(.unauthorized)
            case 404:
                return .failure(.cityNotFound)
            case 429:
                return .failure(.tooManyResquests)
            case 200:
                let decodedResponse = try JSONDecoder().decode(CurrentWeatherResponse.self, from: data)
                return .success(decodedResponse)
            default:
                return .failure(.invalidResponse)
            }
        } catch is DecodingError {
            return .failure(.invalidData)
        } catch {
            return .failure(.unableToComplete)
        }
    }
    
    func getForecast(of city: String) async -> Result<ForecastResponse, WeatherApiError> {
        guard let url = URL(string: "\(baseUrl)/forecast/?q=\(city)&appid=\(apiKey)&units=metric") else {
            return .failure(.invalidURL)
        }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            
            switch statusCode {
            case 401:
                return .failure(.unauthorized)
            case 404:
                return .failure(.cityNotFound)
            case 429:
                return .failure(.tooManyResquests)
            case 200:
                let decodedResponse = try JSONDecoder().decode(ForecastResponse.self, from: data)
                return .success(decodedResponse)
            default:
                return .failure(.invalidResponse)
            }
        } catch is DecodingError {
            return .failure(.invalidData)
        } catch {
            return .failure(.unableToComplete)
        }
    }
}

