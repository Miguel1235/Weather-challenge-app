import Foundation

struct CurrentWeatherResponse: Codable {
    let coord: Coordinate
    let weather: [WeatherCondition]
    let main: MainWeatherData
    let visibility: Int
    let wind: Wind
    let dt: Double
    let sys: Sys
    let timezone: Int
    let id: Int
    let name: String
    let cod: Int
}
